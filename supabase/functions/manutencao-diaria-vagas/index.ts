import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.8';
Deno.serve(async (req)=>{
  try {
    // Verificar se é uma execução agendada ou manual
    const { scheduled = false } = await req.json().catch(()=>({}));
    // Inicializar cliente Supabase com service_role para bypass RLS
    const supabase = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    console.log(`🚀 Iniciando manutenção diária de vagas - ${scheduled ? 'Agendada' : 'Manual'}`);
    console.log(`📅 Data atual: ${new Date().toISOString()}`);
    // Executar função corrigida de atualização
    const { data, error } = await supabase.rpc('atualizar_status_vagas_expiradas');
    if (error) {
      console.error('❌ Erro na execução:', error);
      return new Response(JSON.stringify({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }
    const result = data[0] || {
      vagas_atualizadas_canceladas: 0,
      vagas_atualizadas_fechadas: 0,
      candidaturas_reprovadas: 0
    };
    console.log('✅ Manutenção concluída com sucesso:');
    console.log(`   📋 Vagas canceladas (sem candidaturas): ${result.vagas_atualizadas_canceladas}`);
    console.log(`   🔒 Vagas fechadas (com candidaturas): ${result.vagas_atualizadas_fechadas}`);
    console.log(`   ❌ Candidaturas reprovadas: ${result.candidaturas_reprovadas}`);
    return new Response(JSON.stringify({
      success: true,
      message: 'Manutenção diária executada com sucesso - Lógica corrigida aplicada',
      resultados: {
        vagas_canceladas_sem_candidaturas: result.vagas_atualizadas_canceladas,
        vagas_fechadas_com_candidaturas: result.vagas_atualizadas_fechadas,
        candidaturas_reprovadas: result.candidaturas_reprovadas,
        total_vagas_processadas: result.vagas_atualizadas_canceladas + result.vagas_atualizadas_fechadas
      },
      timestamp: new Date().toISOString(),
      tipo_execucao: scheduled ? 'agendada' : 'manual',
      versao: 'corrigida_v2.0'
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (error) {
    console.error('❌ Erro geral na Edge Function:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Erro interno na execução da manutenção',
      details: error.message,
      timestamp: new Date().toISOString(),
      versao: 'corrigida_v2.0'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
});
