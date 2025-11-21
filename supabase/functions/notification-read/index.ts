import { createClient } from 'npm:@supabase/supabase-js@2';
import { JWT } from 'npm:google-auth-library@9';

// ATENÇÃO: Service account deve ser movida para secrets em produção
// Use: Deno.env.get('FIREBASE_SERVICE_ACCOUNT') e faça JSON.parse()
const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '{}');

const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

Deno.serve(async (req)=>{
  console.log('🔽 Notification read function started (FIXED)');
  const { user_id } = await req.json();
  try {
    // 1. Buscar FCM token do usuário
    console.log('🔍 Looking for user FCM token:', user_id);
    const { data: userData, error: userError } = await supabase.from('user_profile').select('fcm_token').eq('id', user_id).single();
    if (userError) {
      console.error('❌ Error fetching user:', userError);
      throw userError;
    }
    if (!userData?.fcm_token) {
      console.log('⚠️ No FCM token found for user:', user_id);
      return new Response('No FCM token found', {
        status: 200
      });
    }
    console.log('🔐 FCM token found');
    // 2. Contar notificações ainda não lidas para este usuário
    console.log('📊 Counting remaining unread notifications...');
    const { count: unreadCount, error: countError } = await supabase.from('notifications').select('*', {
      count: 'exact',
      head: true
    }).eq('recipient_id', user_id).eq('is_read', false);
    if (countError) {
      console.error('❌ Error counting notifications:', countError);
      throw countError;
    }
    const newBadgeCount = unreadCount || 0;
    console.log(`🏷️ New badge count: ${newBadgeCount}`);
    // 3. Obter access token do Firebase
    console.log('🔑 Getting Firebase access token...');
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key
    });
    // 4. Enviar notificação silenciosa para atualizar o badge (SEM sound)
    console.log('📱 Sending silent notification to update badge...');
    const response = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`
      },
      body: JSON.stringify({
        message: {
          token: userData.fcm_token,
          data: {
            type: 'badge_update',
            user_id: user_id,
            timestamp: new Date().toISOString()
          },
          apns: {
            payload: {
              aps: {
                badge: newBadgeCount,
                'content-available': 1
              }
            }
          },
          android: {
            priority: 'high',
            data: {
              type: 'badge_update',
              badge_count: newBadgeCount.toString()
            }
          }
        }
      })
    });
    const responseData = await response.json();
    console.log('📥 FCM response status:', response.status);
    console.log('📥 FCM response:', JSON.stringify(responseData, null, 2));
    if (response.status < 200 || response.status > 299) {
      console.error('❌ FCM error:', responseData);
      return new Response(`FCM error: ${JSON.stringify(responseData)}`, {
        status: 500
      });
    }
    console.log('✅ Badge count updated successfully (FIXED VERSION)');
    return new Response(JSON.stringify({
      success: true,
      user_id: user_id,
      new_badge_count: newBadgeCount,
      firebase_response: responseData
    }), {
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (error) {
    console.error('❌ Error in notification-read function:', error);
    return new Response(`Error: ${error.message}`, {
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
