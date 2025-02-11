// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import { createClient } from 'npm:@supabase/supabase-js@2' 
import { getAccessToken, UpdateWebhookPayload } from '../FirebaseOAuth.ts'
import serviceAccount from '../service-account.json' with { type: 'json' }

interface Attendance {
  id: string
  userAccountId: string
  terminId: string
  startTime: string
  endTime: string
  createdAt: string
  updatedAt: string
  deletedAt: string
  attendanceStatus: string
} 
 
const supabase = createClient( 
    Deno.env.get('SUPABASE_URL')!, 
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  const payload: UpdateWebhookPayload<Attendance> = await req.json();

  try { 
      const { data: termin } = await supabase 
          .from('Termin')
          .select('*')
          .eq('id', payload.record.terminId)
          .single();


      const { data: sender } = await supabase 
          .from('UserAccount')
          .select('*')
          .eq('id', payload.record.userAccountId)
          .single(); 

      if (termin && sender) {  
          const { data: trainers } = await supabase 
              .from('TeamMember')
              .select('*') 
              .eq('role', 'Trainer')
              .eq('teamId', termin.teamId)

          const { data: senderUserProfile } = await supabase 
              .from('UserProfile')
              .select('*')
              .eq('userId', sender.userId)
              .single();

          if (trainers && senderUserProfile && trainers.length > 0) {
              for (const trainer of trainers) {
                  const { data: userAccount } = await supabase 
                    .from('UserAccount')
                    .select('*')
                    .eq('id', trainer.userAccountId)
                    .single(); 

                    console.log("userAccount: ", userAccount)

                  if (userAccount) {
                      const { data: userProfile } = await supabase 
                          .from('UserProfile')
                          .select('*')
                          .eq('userId', userAccount.userId)
                          .single();

                      const accessToken = await getAccessToken({
                            clientEmail: serviceAccount.client_email,
                            privateKey: serviceAccount.private_key,
                      });

                      const notificationTitle = `Teilnahme-Update: ${termin.title}`; 
                    
                      const status = payload.record.attendanceStatus === "Confirmed" ? "bestätigt" : 
                                     payload.record.attendanceStatus === "Declined" ? "abgelehnt" :
                                     payload.record.attendanceStatus;

                      const notificationBody = `${senderUserProfile.firstName} hat seine Teilnahme für ${termin.title} auf ${status} geändert.`;

                      const res = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
                          method: 'POST',
                          headers: {
                              'Content-Type': 'application/json',
                              Authorization: `Bearer ${accessToken}`,
                          },
                          body: JSON.stringify({
                              message: {
                                  token: userProfile.fcmToken,
                                  notification: {
                                      title: notificationTitle,
                                      body: notificationBody
                                  }, 
                                  apns: {  
                                      payload: {
                                        aps: {
                                          badge: 0,
                                          sound: "trainer-whistle.mp3"
                                        } 
                                      }
                                  },
                                  /* BACKGROUND NOTIFICATION
                                  data: {
                                    customKey: "refetch"
                                  },
                                  apns: { 
                                      payload: {
                                        aps: {
                                          badge: 0, 
                                          //"content_available" : 1
                                        } 
                                      }
                                  },
                                  */     
                              }
                          }),
                      });

                      const resData = await res.json();
                      if (!res.ok) { 
                          console.error("FCM Error:", res.status, resData);
                          return new Response(JSON.stringify({ error: "FCM Error", details: resData }), {
                              status: res.status, // Return error status code
                              headers: { 'Content-Type': 'application/json' },
                          });
                      }

                      return new Response(JSON.stringify(resData), {
                          headers: { 'Content-Type': 'application/json' },
                      });
                  } else {
                    console.error("UserAccount not found");
                    return new Response(JSON.stringify({ error: "UserAccount not found" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
                  }
              } 
          } else {
              console.error("No Trainer not found");
              return new Response(JSON.stringify({ error: "No Trainer not found" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
          }
      } else {
        console.error("Termin not found");
        return new Response(JSON.stringify({ error: "Termin not found" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
      }
  } catch (error) {
      console.error("General Error:", error);
      return new Response(JSON.stringify({ error: "General error", details: error.message }), {
          status: 500, // Return error status code
          headers: { 'Content-Type': 'application/json' },
      });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/SendNotificationToTeamTrainerByUpdateAttendance' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
