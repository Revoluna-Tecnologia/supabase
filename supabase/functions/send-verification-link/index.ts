// supabase/functions/send-verification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import * as crypto from 'https://deno.land/std@0.167.0/node/crypto.ts';
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
    // Get Supabase project ID from environment
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    // Extract project reference/ID from the URL (format: https://your-project-ref.supabase.co)
    const projectId = supabaseUrl.match(/https:\/\/(.*?)\.supabase\.co/)?.[1];
    if (!projectId) {
      throw new Error('Could not extract project ID from Supabase URL');
    }
    // Generate verification link using the extracted project ID
    //const verificationLink = `https://${projectId}.functions.supabase.co/confirm-verification?token=${token}`;
    const verificationLink = `https://verificacao.revoluna.com.br/api/confirm-verification?token=${token}`;
    // Send email via Resend API
    const htmlContent = `
      <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Link de acesso - Revoluna</title>
            <style type="text/css">
                /* Reset styles */
                body, p, h1, h2, h3, h4, h5, h6, table, td {
                    margin: 0;
                    padding: 0;
                    font-family: 'Arial', sans-serif;
                }
                body {
                    background-color: #f8f8f8;
                    margin: 0;
                    padding: 0;
                    -webkit-text-size-adjust: none;
                    -ms-text-size-adjust: none;
                }
                table {
                    border-spacing: 0;
                    border-collapse: collapse;
                    mso-table-lspace: 0pt;
                    mso-table-rspace: 0pt;
                }
                img {
                    border: 0;
                    line-height: 100%;
                    outline: none;
                    text-decoration: none;
                    -ms-interpolation-mode: bicubic;
                }
                .ReadMsgBody { width: 100%; }
                .ExternalClass { width: 100%; }
                .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div { line-height: 100%; }

                /* Custom styles */
                .button {
                    background-color: #9966FF;
                    border-radius: 30px;
                    color: #ffffff;
                    display: inline-block;
                    font-size: 16px;
                    font-weight: bold;
                    line-height: 50px;
                    text-align: center;
                    text-decoration: none;
                    width: 200px;
                    -webkit-text-size-adjust: none;
                }
                @media only screen and (max-width: 600px) {
                    .container {
                        width: 100% !important;
                    }
                    .content {
                        padding: 10px !important;
                    }
                    .button {
                        width: 100% !important;
                    }
                    .hero-image {
                        height: auto !important;
                    }
                }
            </style>
        </head>
        <body style="margin: 0; padding: 0;">
            <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td style="padding: 20px 0;">
                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.05);" class="container">
                            <!-- Hero image section with white logo -->
                            <tr>
                                <td align="center" bgcolor="#9966FF" style="padding: 80px 0;">
                                    <img src="https://verificacao.revoluna.com.br/img/logo.png" alt="Revoluna" width="300" style="display: block; margin: 0 auto;" />
                                </td>
                            </tr>

                            <!-- Main content -->
                            <tr>
                                <td bgcolor="#ffffff" style="padding: 40px 30px 30px 30px;" class="content">
                                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;">
                                        <tr>
                                            <td style="color: #555555; font-family: Arial, sans-serif; font-size: 16px; line-height: 24px; padding-bottom: 30px; text-align: center;">
                                                <h3 style="padding-bottom: 15px;">Bem-vindos à Revoluna!</h3>
                                                <p>Toque no botão abaixo para prosseguir com seu acesso.</p>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" style="padding-bottom: 20px;">
                                                <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                                    <tr>
                                                        <td align="center" bgcolor="#9966FF" style="border-radius: 30px;">
                                                            <a href="${verificationLink}" target="_blank" style="padding: 15px 40px; border-radius: 30px; color: #ffffff; display: inline-block; font-family: Arial, sans-serif; font-size: 16px; font-weight: bold; text-decoration: none;">ACESSAR O APP</a>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 10px 20px;color: #999999; font-family: Arial, sans-serif; font-size: 12px; line-height: 18px; text-align: center;">
                                                <p style="margin: 0;">Este é um e-mail transacional enviado apenas para confirmar que seu endereço de e-mail é válido. Seus dados não estão sendo compartilhados e você não foi inscrito em nenhuma lista.</p>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <!-- Footer -->
                            <tr>
                                <td bgcolor="#f9f6ff" style="padding: 30px 30px;">
                                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;">
                                        <tr>
                                            <td style="color: #555555; font-family: Arial, sans-serif; font-size: 14px; line-height: 20px; text-align: center;">
                                                <p>&copy; 2025 Revoluna. Todos os direitos reservados.</p>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </body>
      </html>`;
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
