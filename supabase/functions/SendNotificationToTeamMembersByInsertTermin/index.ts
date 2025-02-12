// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'npm:@supabase/supabase-js@2' 
import { getAccessToken, InsertWebhookPayload } from '../FirebaseOAuth.ts'
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
  const payload: InsertWebhookPayload<Attendance> = await req.json();

  try {
      console.log(payload.record)

        console.log("payload.record.startTime:", payload.record.startTime);
        console.log("payload.record.endTime:", payload.record.endTime);

        const startTimeUTC = new Date(payload.record.startTime).toISOString();
        const endTimeUTC = new Date(payload.record.endTime).toISOString();

        console.log("startTimeUTC:", startTimeUTC);
        console.log("endTimeUTC:", endTimeUTC);


      const { data: absence } = await supabase 
            .from('Absence')
            .select('*')
            .eq('userAccountId', payload.record.userAccountId)
            .gte('startDate', payload.record.startTime)
            .lte('endDate', payload.record.endTime) 
            .is('deletedAt', null)

    console.log(absence.length)

      const { data: userAccount } = await supabase 
          .from('UserAccount')
          .select('*')
          .eq('id', payload.record.userAccountId)
          .is('deletedAt', null)
          .single();

      const { data: termin } = await supabase 
          .from('Termin')
          .select('*')
          .eq('id', payload.record.terminId)
          .is('deletedAt', null)
          .single(); 

    if(absence.length > 0) {
        console.error("you have an absence");
        return new Response(JSON.stringify({ error: "you have an absence" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
    } else {

        if (userAccount && termin) {
            const { data: userProfile } = await supabase 
                .from('UserProfile')
                .select('*')
                .eq('userId', userAccount.userId)
                .is('deletedAt', null)
                .single();
  
            if (userProfile && userProfile.fcmToken) { 
                const { data: team } = await supabase
                    .from('Team')
                    .select('teamName')
                    .eq('id', termin.teamId as string)
                    .is('deletedAt', null)
                    .single();
  
                if (team) {
                    const accessToken = await getAccessToken({
                        clientEmail: serviceAccount.client_email,
                        privateKey: serviceAccount.private_key,
                    });
                 
                    const notificationTitle = `Neuer Termin: ${termin.title}`;
                    const notificationBody = `Ein neuer Termin für dein Team ${team.teamName} wurde erstellt. Bitte überprüfe deine Attendance.`; 
  
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
                                    body: notificationBody,
                                },
                            },
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
                    console.error("Team not found");
                    return new Response(JSON.stringify({ error: "Team not found" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
                }
            } else {
                console.error("FCM token not found");
                return new Response(JSON.stringify({ error: "FCM token not found" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
            }
        } else {
            console.error("User or Termin not found");
            return new Response(JSON.stringify({ error: "User or Termin not found" }), { status: 404, headers: { 'Content-Type': 'application/json' } });
        }

    }

      
  } catch (error) {
      console.error("General Error:", error);
      return new Response(JSON.stringify({ error: "General error", details: error.message }), {
          status: 500, // Return error status code
          headers: { 'Content-Type': 'application/json' },
      });
  }
});