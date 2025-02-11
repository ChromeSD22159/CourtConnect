// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'npm:@supabase/supabase-js@2' 
import { getAccessToken, InsertWebhookPayload } from '../FirebaseOAuth.ts'
import serviceAccount from '../service-account.json' with { type: 'json' }
 
interface Termin {
  id: string
  teamId: string 
  typeString: string
  startTime: string
  endTime: string
  terminType: string
  title: string
  place: string
  infomation: string
  durationMinutes: number
  createdByUserAccountId: string
  createdAt: string
  updatedAt: string
  deletedAt: string
}  
   
const supabase = createClient( 
    Deno.env.get('SUPABASE_URL')!, 
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  const payload: InsertWebhookPayload<Termin> = await req.json();

  const oldRecord = payload.old;
  const newRecord = payload.new;

  try {
      console.log(payload.record) 
      const { data: allMember } = await supabase 
        .from('TeamMember')
        .select('*')  
        .eq('teamId', payload.record.teamId)

      if (allMember && allMember.length > 0) {
          for (const member of allMember) {
              const { data: userAccount } = await supabase 
                  .from('UserAccount')
                  .select('*')
                  .eq('id', member.userAccountId)
                  .single(); 

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

                  const notificationTitle = `Termin Update: ${payload.record.title}`;
                  const notificationBody = `Der Termin für dein Team wurde aktualisiert. ${payload.record.startTime} - ${payload.record.endTime}`; 

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
                              }    
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
              }
          }
      } else {
          console.error("User or Termin not found");
          return new Response(JSON.stringify({ error: "User or Termin not found" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/SendNotificationToTeamMembersByUpdateTermin' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}' 
*/
