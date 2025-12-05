// supabase/functions/send-verification/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import * as crypto from 'https://deno.land/std@0.167.0/node/crypto.ts';
import { emailTemplate } from './email-template.ts';

function getEmailTemplate(verificationLink: string): string {
  return emailTemplate.replace(/\{\{VERIFICATION_LINK\}\}/g, verificationLink);
}

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
    // Create Supabase client
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    // Generate verification token
    const token = crypto.randomBytes(16).toString('hex');
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getSeconds() + 75); // Token valid for 75 seconds
    // Store token in your email_verification_tokens table
    const { error } = await supabaseClient.from('email_verification_tokens').insert({
      email,
      token,
      expires_at: expiresAt.toISOString(),
      verified: false
    });
    if (error) throw error;
  
    const verificationLink = `https://verificacao.revoluna.com.br/api/confirm-verification?token=${token}`;
    // Send email via Resend API
    const htmlContent = await getEmailTemplate(verificationLink);
    const textContent = `Bem-vindo(a) à Revoluna!

Para prosseguir com seu acesso, copie e cole o link abaixo no seu navegador.

Link de Acesso:
${verificationLink}

---

O que você pode fazer com o Revoluna:
- Encontrar oportunidades personalizadas
- Gerenciar sua agenda de plantões
- Receber pagamentos de forma segura
- Conectar-se com instituições de saúde

---

© 2025 Revoluna. Todos os direitos reservados.
`;
    const resendRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`
      },
      body: JSON.stringify({
        from: 'Revoluna <nao-responda@revoluna.com.br>',
        to: email,
        subject: 'Verificação de email - Revoluna',
        html: htmlContent,
        text: textContent
      })
    });
    if (!resendRes.ok) {
      const errorData = await resendRes.json();
      throw new Error(`Failed to send email: ${JSON.stringify(errorData)}`);
    }
    return new Response(JSON.stringify({
      success: true,
      message: "Verification email sent successfully"
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  } catch (error) {
    console.error('Error:', error);
    return new Response(JSON.stringify({
      error: error.message
    }), {
      status: 400,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  }
});
