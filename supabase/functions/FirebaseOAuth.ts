import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import serviceAccount from './service-account.json' with { type: 'json' } 
import { JWT } from 'npm:google-auth-library@9'

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

interface InsertWebhookPayload<T> {
  type: 'INSERT'
  table: string
  record: T
  schema: 'public'
  old_record: null | T
}

interface UpdateWebhookPayload<T> {
  type: 'UPDATE'
  table: string
  record: T
  schema: 'public'
  old_record: T
}

export { getAccessToken, InsertWebhookPayload, UpdateWebhookPayload };