import { serve } from "https://deno.land/std@0.170.0/http/server.ts";
serve(async (req)=>{
  // Handle CORS preflight OPTIONS request
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
        "Access-Control-Max-Age": "86400" // 24 hours cache for preflight
      }
    });
  }
  // Set CORS headers for the actual response
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  };
  try {
    // Lê o corpo da requisição e extrai phoneNumber e code
    const { phoneNumber, code } = await req.json();
    console.log("Dados recebidos:", {
      phoneNumber,
      code
    });
    if (!phoneNumber || !code) {
      return new Response(JSON.stringify({
        error: "Número de telefone e código são obrigatórios"
      }), {
        status: 400,
        headers: corsHeaders
      });
    }
    // Formata o telefone para garantir que comece com '+'
    let formattedPhone = phoneNumber;
    if (!formattedPhone.startsWith("+")) {
      formattedPhone = `+${formattedPhone}`;
    }
    // Recupera as credenciais do Twilio
    const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID");
    const authToken = Deno.env.get("TWILIO_AUTH_TOKEN");
    const serviceSid = Deno.env.get("TWILIO_VERIFY_SERVICE_SID");
    if (!accountSid || !authToken || !serviceSid) {
      return new Response(JSON.stringify({
        error: "Credenciais do Twilio não configuradas."
      }), {
        status: 500,
        headers: corsHeaders
      });
    }
    // Monta o header de autenticação
    const authHeader = "Basic " + btoa(`${accountSid}:${authToken}`);
    // URL correta para a API Verify
    const url = `https://verify.twilio.com/v2/Services/${serviceSid}/VerificationCheck`;
    console.log("Realizando requisição para:", url);
    console.log("Parâmetros:", {
      To: formattedPhone,
      Code: code.toString()
    });
    // Chama o endpoint do Twilio para verificar o código
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({
        "To": formattedPhone,
        "Code": code.toString() // Garante que o código seja enviado como string
      })
    });
    console.log("Status da resposta:", response.status);
    // Tenta fazer o parse do JSON com tratamento de erro
    let data;
    try {
      const responseText = await response.text();
      console.log("Resposta em texto:", responseText);
      try {
        data = JSON.parse(responseText);
      } catch (parseError) {
        console.error("Erro ao analisar JSON:", parseError);
        return new Response(JSON.stringify({
          error: "Erro ao processar resposta do Twilio",
          rawResponse: responseText
        }), {
          status: 500,
          headers: corsHeaders
        });
      }
    } catch (textError) {
      console.error("Erro ao ler corpo da resposta:", textError);
      return new Response(JSON.stringify({
        error: "Erro ao ler resposta do Twilio"
      }), {
        status: 500,
        headers: corsHeaders
      });
    }
    if (!response.ok) {
      // Log detalhado para depuração
      console.error("Erro na API do Twilio:", {
        status: response.status,
        data: data
      });
      // Extrai mensagem de erro de forma segura
      const errorMessage = data && data.message ? data.message : data && data.error_message ? data.error_message : "Erro ao validar o código";
      return new Response(JSON.stringify({
        error: errorMessage,
        details: data // Inclui detalhes completos para depuração
      }), {
        status: response.status,
        headers: corsHeaders
      });
    }
    // Retorna o status da verificação (ex: approved, pending, etc.)
    return new Response(JSON.stringify({
      status: data.status,
      valid: data.status === "approved",
      details: data // Para fornecer mais informações durante os testes
    }), {
      status: 200,
      headers: corsHeaders
    });
  } catch (error) {
    console.error("Erro na função:", error);
    return new Response(JSON.stringify({
      error: error.message,
      stack: error.stack // Inclui stack trace para depuração
    }), {
      status: 500,
      headers: corsHeaders
    });
  }
});
