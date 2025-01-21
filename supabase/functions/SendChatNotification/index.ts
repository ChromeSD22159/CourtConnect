// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from '../SendChatNotification/service-account.json' with { type: 'json' } 

interface Apns {
  alert: {
    title: string
    body: string
  }
  sound: string
}

interface ApnsNotification {
  aps: Apns
}

interface Messages {
  id: string
  senderId: string
  recipientId: string
  message: string
  token: string
}

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: Messages
  schema: 'public'
  old_record: null | Messages
}

const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
) 

Deno.serve(async (req) => {
    const payload: WebhookPayload = await req.json()
 
      try {
        const { data: sender } = await supabase
          .from('UserProfile')
          .select('firstName')
          .eq('userId', payload.record.senderId as string)
          .single(); 
      
        const { data: recipient } = await supabase
          .from('UserProfile')
          .select('*')
          .eq('userId', payload.record.recipientId as string)
          .single()  

        const accessToken = await getAccessToken({
            clientEmail: serviceAccount.client_email,
            privateKey: serviceAccount.private_key,
        })
          
        const res = await fetch(
          `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${accessToken}`,
            }, 
            body: JSON.stringify({
              message: {
                token: recipient.fcmToken,
                notification: {
                  title: "Neue Nachricht von " + sender.firstName,
                  body: payload.record.message,
                },
              },
            }),
          }
        )
        
        const resData = await res.json()
        if (res.status < 200 || 299 < res.status) {
            return new Response("User is Online")
        }
        
        return new Response(JSON.stringify(resData), {
            headers: { 'Content-Type': 'application/json' },
        }) 
        
      } catch (error) {
          return new Response(JSON.stringify(error), {
              headers: { 'Content-Type': 'application/json' },
          })
      } 
})  

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }
      resolve(tokens!.access_token!)
    })
  })
}