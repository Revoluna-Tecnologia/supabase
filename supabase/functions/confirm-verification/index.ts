// supabase/functions/confirm-verification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};
serve(async (req)=>{
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    // Get token from URL query parameters
    const url = new URL(req.url);
    const token = url.searchParams.get('token');
    if (!token) {
      throw new Error('Nenhum token de verificação fornecido');
    }
    console.log('Verifying token:', token);
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    // Get the token record
    const { data, error } = await supabaseClient.from('email_verification_tokens').select('*').eq('token', token).single();
    if (error) {
      console.error('Error fetching token:', error);
      throw new Error('Token de verificação inválido');
    }
    if (!data) {
      throw new Error('Token de verificação inválido');
    }
    const now = new Date();
    if (new Date(data.expires_at) < now) {
      throw new Error('O token de verificação expirou');
    }
    if (data.verified) {
      // Redirect to already verified page
      return new Response(null, {
        status: 302,
        headers: {
          ...corsHeaders,
          'Location': 'https://v0-revoluna-email-page-6othym.vercel.app/'
        }
      });
    }
    console.log('Valid token found for email:', data.email);
    // Mark token as verified
    const { error: updateError } = await supabaseClient.from('email_verification_tokens').update({
      verified: true
    }).eq('token', token);
    if (updateError) {
      console.error('Error updating verification status:', updateError);
      throw updateError;
    }
    // Redirect to success page
    return new Response(null, {
      status: 302,
      headers: {
        ...corsHeaders,
        'Location': 'https://v0-revoluna-email-page-6othym.vercel.app/'
      }
    });
  } catch (error) {
    console.error('Verification error:', error);
    // Redirect to error page with error message as parameter
    return new Response(null, {
      status: 302,
      headers: {
        ...corsHeaders,
        'Location': `https://v0-revoluna-page-fwvdp7.vercel.app/error?message=${encodeURIComponent(error.message)}`
      }
    });
  }
});
