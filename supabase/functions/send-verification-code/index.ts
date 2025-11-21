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
    const { phoneNumber } = await req.json();
    // Adiciona o '+' se ele não estiver presente
    let formattedPhone = phoneNumber;
    if (!formattedPhone.startsWith("+")) {
      formattedPhone = `+${formattedPhone}`;
    }
    const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID");
    const authToken = Deno.env.get("TWILIO_AUTH_TOKEN");
    const serviceSid = Deno.env.get("TWILIO_VERIFY_SERVICE_SID");
    // Log para depuração (remova em produção!)
    console.log("Secrets carregados:", {
      accountSid: accountSid ? "ok" : "falta",
      authToken: authToken ? "ok" : "falta",
      serviceSid: serviceSid ? "ok" : "falta"
    });
    if (!accountSid || !authToken || !serviceSid) {
      return new Response(JSON.stringify({
        error: "Credenciais do Twilio não configuradas."
      }), {
        status: 500,
        headers: corsHeaders
      });
    }
    const authHeader = "Basic " + btoa(`${accountSid}:${authToken}`);
    const url = `https://verify.twilio.com/v2/Services/${serviceSid}/Verifications`;
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({
        "To": formattedPhone,
        "Channel": "sms"
      })
    });
    const data = await response.json();
    if (!response.ok) {
      return new Response(JSON.stringify({
        error: data.message || "Erro ao enviar o código"
      }), {
        status: response.status,
        headers: corsHeaders
      });
    }
    return new Response(JSON.stringify({
      status: data.status
    }), {
      status: 200,
      headers: corsHeaders
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: error.message
    }), {
      status: 500,
      headers: corsHeaders
    });
  }
});
