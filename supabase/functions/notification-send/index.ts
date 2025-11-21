import { createClient } from 'npm:@supabase/supabase-js@2';
import { JWT } from 'npm:google-auth-library@9';

// ATENÇÃO: Service account deve ser movida para secrets em produção
// Use: Deno.env.get('FIREBASE_SERVICE_ACCOUNT') e faça JSON.parse()
const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '{}');

const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

Deno.serve(async (req)=>{
  console.log('🚀 Function started');
  let fcmToken;
  let accessToken;
  const payload = await req.json();
  console.log('📦 Payload received:', {
    type: payload.type,
    table: payload.table,
    id: payload.record.id,
    recipient_id: payload.record.recipient_id,
    title: payload.record.title
  });
  // 1. Buscar FCM token do usuário
  try {
    console.log('🔍 Looking for user data for:', payload.record.recipient_id);
    const { data, error } = await supabase.from('user_profile').select('fcm_token').eq('id', payload.record.recipient_id).single();
    if (error) {
      console.error('❌ Supabase error:', error);
      throw error;
    }
    if (!data?.fcm_token) {
      console.error('❌ No FCM token found for user:', payload.record.recipient_id);
      return new Response('No FCM token found for user', {
        status: 400
      });
    }
    fcmToken = data.fcm_token;
    console.log('🔐 FCM token retrieved successfully');
    // 2. Obter access token do Firebase
    accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key
    });
    console.log('✅ Access token retrieved successfully');
  } catch (e) {
    console.error('❌ Error in initial setup:', e);
    return new Response(e.message, {
      status: 500
    });
  }
  // 3. Calcular badge atual (notificações não lidas + esta nova)
  try {
    console.log('📊 Calculating current badge count...');
    const { count: currentUnreadCount } = await supabase.from('notifications').select('*', {
      count: 'exact',
      head: true
    }).eq('recipient_id', payload.record.recipient_id).eq('is_read', false);
    const badgeCount = currentUnreadCount || 0;
    console.log(`🏷️ Current unread: ${currentUnreadCount || 0}, setting badge to: ${badgeCount}`);
    // 4. Enviar notificação via Firebase
    console.log('📱 Sending FCM message...');
    const res = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: {
            title: payload.record.title,
            body: payload.record.body
          },
          data: {
            id: payload.record.id,
            user_id: payload.record.recipient_id,
            timestamp: new Date().toISOString(),
            badge_count: badgeCount.toString(),
            route: payload.record.route || '',
            extra_data: JSON.stringify(payload.record.extra_data || {})
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: badgeCount
              }
            }
          },
          android: {
            priority: 'high',
            notification: {
              title: payload.record.title,
              body: payload.record.body,
              sound: 'default'
            },
            data: {
              id: payload.record.id,
              user_id: payload.record.recipient_id,
              badge_count: badgeCount.toString(),
              timestamp: new Date().toISOString(),
              route: payload.record.route || '',
              extra_data: JSON.stringify(payload.record.extra_data || {})
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
    // 5. Sucesso - Atualizar notificação com o message ID do Firebase
    const firebaseMessageId = resData.name;
    console.log('✅ Firebase message ID:', firebaseMessageId);
    const updateResult = await supabase.from('notifications').update({
      message_id: firebaseMessageId,
      created_at: new Date().toISOString()
    }).eq('id', payload.record.id);
    if (updateResult.error) {
      console.error('❌ Failed to update notification record:', updateResult.error);
    } else {
      console.log('✅ Notification record updated with Firebase message ID');
    }
    return new Response(JSON.stringify({
      success: true,
      firebase_response: resData,
      firebase_message_id: firebaseMessageId,
      id: payload.record.id,
      badge_count: badgeCount
    }), {
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (e) {
    console.error('❌ Error sending FCM message:', e);
    return new Response(`FCM error: ${e.message}`, {
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
