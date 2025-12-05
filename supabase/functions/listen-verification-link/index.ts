// supabase/functions/listen-verification-link/index.ts
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
    const { email } = await req.json();
    if (!email) {
      throw new Error('Email is required');
    }
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    // Get the most recent row for this email regardless of verification status
    const { data, error } = await supabaseClient.from('email_verification_tokens').select('id, created_at, email, verified, token').eq('email', email).order('created_at', {
      ascending: false
    }) // Order by creation date descending
    .limit(1); // Limit to just the most recent record
    if (error) {
      console.error('Error fetching verification status:', error);
      throw error;
    }
    // Return only the verified status from the most recent token
    const mostRecentToken = data && data.length > 0 ? data[0] : null;
    const verifiedStatus = mostRecentToken ? mostRecentToken.verified : false;
    return new Response(JSON.stringify({
      verified: verifiedStatus
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  } catch (error) {
    console.error('Error:', error);
    return new Response(JSON.stringify({
      error: error.message,
      verified: false
    }), {
      status: 400,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  }
});
