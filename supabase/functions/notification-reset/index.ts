import { createClient } from 'npm:@supabase/supabase-js@2';
import { JWT } from 'npm:google-auth-library@9';

// ATENÇÃO: Service account deve ser movida para secrets em produção
// Use: Deno.env.get('FIREBASE_SERVICE_ACCOUNT') e faça JSON.parse()
const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '{}');

const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

Deno.serve(async (req)=>{
  console.log('🔄 Badge reset function started');
  // Verificar método
  if (req.method !== 'POST') {
    return new Response('Method not allowed', {
      status: 405
    });
  }
  try {
    const { user_id } = await req.json();
    if (!user_id) {
      return new Response('Missing user_id', {
        status: 400
      });
    }
    console.log('🎯 Resetting badge for user:', user_id);
    // 1. Buscar FCM token do usuário
    const { data, error } = await supabase.from('user_profile').select('fcm_token').eq('id', user_id).single();
    if (error) {
      console.error('❌ Supabase error:', error);
      throw error;
    }
    if (!data?.fcm_token) {
      console.error('❌ No FCM token found for user:', user_id);
      return new Response('No FCM token found for user', {
        status: 400
      });
    }
    const fcmToken = data.fcm_token;
    console.log('🔐 FCM token retrieved successfully');
    // 2. Obter access token do Firebase
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key
    });
    console.log('✅ Access token retrieved successfully');
    // 3. Enviar notificação silenciosa para zerar badge
    console.log('📱 Sending badge reset message...');
    const res = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          data: {
            type: 'badge_reset',
            user_id: user_id,
            timestamp: new Date().toISOString()
          },
          apns: {
            payload: {
              aps: {
                badge: 0,
                'content-available': 1 // Notificação silenciosa
              }
            }
          },
          android: {
            priority: 'high',
            data: {
              type: 'badge_reset'
            }
          }
        }
      })
    });
    const resData = await res.json();
    console.log('📥 FCM response status:', res.status);
    console.log('📥 FCM response data:', JSON.stringify(resData, null, 2));
    if (res.status < 200 || res.status > 299) {
      console.error('❌ FCM error response:', resData);
      return new Response(`FCM error: ${JSON.stringify(resData)}`, {
        status: 500
      });
    }
    // 4. Opcional: Marcar todas as notificações do usuário como lidas
    const updateResult = await supabase.from('notifications').update({
      is_read: true,
      read_at: new Date().toISOString()
    }).eq('recipient_id', user_id).eq('is_read', false);
    console.log('✅ Badge reset successful');
    console.log('📊 Notifications marked as read:', updateResult.count || 0);
    return new Response(JSON.stringify({
      success: true,
      message: 'Badge reset successfully',
      firebase_response: resData,
      notifications_marked_read: updateResult.count || 0
    }), {
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (e) {
    console.error('❌ Error resetting badge:', e);
    return new Response(`Error: ${e.message}`, {
      status: 500
    });
  }
});

const getAccessToken = ({ clientEmail, privateKey }: { clientEmail: string; privateKey: string }): Promise<string> =>{
  return new Promise((resolve, reject)=>{
    console.log('🔑 Creating JWT client...');
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: [
        'https://www.googleapis.com/auth/firebase.messaging'
      ]
    });
    jwtClient.authorize((err: Error | null, tokens: { access_token?: string } | null)=>{
      if (err) {
        console.error('❌ JWT authorization error:', err);
        reject(err);
        return;
      }
      console.log('✅ JWT authorization successful');
      resolve(tokens!.access_token!);
    });
  });
};
