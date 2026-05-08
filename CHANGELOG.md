# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [2.4.2] - 2026-05-07

### Added
- Coluna `closed_at` em `vagas_sync_julia` para rastrear vagas sincronizadas já fechadas
- Índice parcial para acelerar consultas de sync em linhas abertas (`closed_at IS NULL`)
- Operações em lote na Edge Function `julia-sync`
  - `close_vagas_bulk` para fechar até 500 vagas por chamada
  - `find_escalistas_bulk` para buscar até 1000 telefones por chamada

### Changed
- Edge Function `julia-sync`
  - `get_sync_state` passa a retornar apenas syncs abertos por padrão
  - `get_sync_state` aceita `include_closed` para consultas administrativas
  - `close_vaga` passa a ser idempotente e retorna `already_closed`
  - `close_vaga` sempre marca `vagas_sync_julia.closed_at` quando a vaga é fechada

### Fixed
- Backfill de `closed_at` para vagas sincronizadas que já estavam com status `fechada`
- Suporte a `escalistas_externos` na view `vw_vagas_candidaturas`

### Performance
- Redução do volume de sync reprocessado pelo worker Julia ao filtrar vagas já fechadas
- Redução de chamadas repetidas a Edge Function com suporte a operações em lote

### Migrations
Total de 3 migrações nesta versão:
1. `20260507000001` - Adiciona `closed_at` ao sync da Julia
2. `20260507000002` - Preenche `closed_at` das vagas sincronizadas fechadas
3. `20260507000003` - Exibe escalistas externos na view `vw_vagas_candidaturas`

---

## [2.4.1] - 2026-03-23

### Fixed
- Otimização da view `vw_vagas_candidaturas` para retornar resultados filtrados corretamente
- FK `grupo_id` em `escalistas_externos` alterada para `ON DELETE CASCADE`

### Migrations
Total de 2 migrações nesta versão:
1. `20260317200000` - Otimização da view `vw_vagas_candidaturas`
2. `20260317200001` - FK `grupo_id` de `escalistas_externos` em CASCADE

---

## [2.4.0] - 2026-03-16

### Added
- Suporte inicial à integração de vagas externas do Julia
  - Criação de registros fallback para grupo `Vagas Externas (Julia)` e setor `Não informado`
  - Nova tabela `escalistas_externos` para contatos sem vínculo com `auth.users`
  - Tabelas de controle de sincronização `vagas_sync_julia`, `sync_especialidades_map`, `sync_periodos_map` e `sync_setores_map`

### Changed
- Suporte a escalistas externos na tabela `vagas`
  - Nova coluna `escalista_externo_id`
  - `escalista_id` passou a aceitar `NULL` para vagas vindas do Julia
- Atualização da view `vw_vagas_abertas`
  - Passa a exibir nome e telefone de `escalistas_externos` quando não houver escalista autenticado
- Flexibilização das constraints de valor
  - `vagas.valor` agora permite `0`
  - `candidaturas.vaga_valor` agora permite `0`

### Fixed
- Correção das políticas RLS da tabela `candidaturas`
  - Restaurado o acesso de médicos e pré-cadastros às próprias candidaturas no `SELECT`
  - Mantida a leitura de candidaturas de colegas via `pode_ver_candidatura_colega()`
  - Restrição da policy de `UPDATE` para impedir atualização de candidaturas de terceiros

### Security
- RLS habilitado nas tabelas de integração do Julia
  - `escalistas_externos` com leitura para usuários autenticados
  - Tabelas de sync restritas a `service_role`

### Migrations
Total de 6 migrações nesta seção:
1. `20260310000001` - Registros fallback para integração Julia
2. `20260310000002` - Tabela `escalistas_externos`
3. `20260310000003` - Tabelas de controle de sync do Julia
4. `20260310000004` - Suporte a `escalista_externo_id` em vagas e na view `vw_vagas_abertas`
5. `20260310000005` - Permissão para valor zero em vagas e candidaturas
6. `20260316172608` - Correção das políticas RLS de candidaturas

---

## [2.3.1] - 2025-12-08

### Fixed
- Correção da função `create_user_from_auth()` que falhava ao criar usuários médicos do app mobile
  - A função tentava inserir na tabela `user_profile` com colunas inexistentes (`updated_at`)
  - Corrigido para usar apenas colunas válidas: `id`, `created_at`, `role`
- Simplificação da política RLS `candidaturas_select_policy` para médicos
  - Removidas verificações desnecessárias que causavam complexidade excessiva
  - Otimizada função `pode_ver_candidatura_colega()` para melhor performance
- Padronização de colunas na view `vw_vagas_abertas` para manter consistência com outras views
  - Renomeadas colunas para padrão snake_case: `periodo_id`, `tipos_vaga_id`, `formarecebimento_id`

### Changed
- Role padrão de usuários do app mobile alterado de `'medico'` para `'signup'` na criação inicial

### Removed
- Função obsoleta `pode_ver_candidatura_colega_debug()` (usada apenas para debugging)

### Migrations
Total de 3 migrações nesta versão:
1. `20251208201250` - Correção da criação de usuários médicos
2. `20251208211342` - Simplificação da política RLS de candidaturas
3. `20251208212537` - Padronização de colunas na view vw_vagas_abertas

---

## [2.3.0] - 2026-12-08

### Added
- Enriquecimento do JWT com `grupo_ids` para filtragem multi-tenant nas API routes
- UUIDs especiais do sistema para rastreabilidade de operações automáticas:
  - `aaaaaaaa-0000-aaaa-eeee-000000000001` → Vaga Expirada (cron job)
  - `aaaaaaaa-0000-aa00-0eee-000000000002` → Auto Reprovação (trigger)
  - `aaaaaaaa-0000-aaaa-cccc-000000000003` → Vaga Cancelada (API route)
- Coluna `grupo_id` adicionada às views `vw_folha_pagamento` e `vw_plantoes_pagamentos`
- Nova view `vw_plantoes_pagamentos` com informações completas de check-in/checkout e pagamentos

### Changed
- **Arquitetura RLS para API Routes:** Migração de RLS complexo para filtragem via JWT
  - Políticas RLS simplificadas removendo chamadas a `houston.authorize()` em tabelas principais
  - Houston Web agora usa service_role via API routes (bypassa RLS)
  - Mobile App mantém RLS simplificado baseado em `user_profile`
- **Padronização de Nomenclatura:**
  - Renomeada coluna `houston.user_roles.group_ids` → `grupo_ids` (padrão português)
  - Renomeadas colunas na view `vw_vagas_candidaturas` para snake_case consistente:
    - `vaga_periodo` → `periodo_id`
    - `vaga_tipo` → `tipos_vaga_id`
    - `vaga_formarecebimento` → `forma_recebimento_id`
- **Consolidação de Funções de Autorização:**
  - Unificação em uma única função: `houston.authorize()`
  - Removidas funções wrapper: `authorize_simple()` e `group_authorization()`
- Padronização de `updated_by` de TEXT para UUID em tabelas `candidaturas` e `vagas`
- Atualização das funções paginadas (`get_vagas_paginated`, `get_applications_paginated`) para usar novos nomes de colunas
- Triggers de check-in/checkout atualizados para suportar operações via service_role

### Fixed
- Vulnerabilidade na tabela `houston.user_roles` - política RLS permitia leitura não autorizada
- Remoção de política de acesso público ao bucket de documentos médicos
- Nome da coluna `grupo_ids` na função trigger de criação de usuários
- Ordem de execução das migrações de padronização da função de autorização

### Removed
- Trigger obsoleto `vagas_1_reprovar_candidaturas_ao_cancelar` (lógica movida para API routes)
- Função `atualizar_candidaturas_vaga_cancelada()` (substituída por cancelamento explícito via API)
- Funções wrapper redundantes: `houston.authorize_simple()` e `houston.group_authorization()`

### Performance
- **Queries de 8s+ reduzidas para ~100ms** com migração de RLS complexo para filtragem JWT
- Otimização de políticas RLS utilizando short-circuit para administradores via JWT
- Redução de overhead com consolidação de 3 funções de autorização em 1

### Security
- Correção de política RLS em `houston.user_roles` que permitia leitura não autorizada
- Remoção de acesso público indevido ao bucket de documentos médicos
- Proteção adicional em triggers de check-in/checkout para operações via service_role

### Breaking Changes

⚠️ **Mudanças que requerem atualização nos clients:**

1. **Houston Web - Queries Diretas Bloqueadas:**
   ```
   ❌ ANTES: Queries diretas ao Supabase via anon key
   ✅ DEPOIS: Todas as queries via API routes com service_role
   ```

2. **Funções de Autorização Removidas:**
   ```sql
   -- ❌ ANTES
   houston.authorize_simple('vagas.select')
   houston.group_authorization('grupos.update', grupo_id)

   -- ✅ DEPOIS
   houston.authorize('vagas.select')
   houston.authorize('grupos.update', NULL, NULL, grupo_id)
   ```

3. **Nomenclatura de Colunas na View:**
   ```sql
   -- ❌ ANTES
   SELECT vaga_periodo, vaga_tipo, vaga_formarecebimento FROM vw_vagas_candidaturas

   -- ✅ DEPOIS
   SELECT periodo_id, tipos_vaga_id, forma_recebimento_id FROM vw_vagas_candidaturas
   ```

4. **Coluna Renomeada em houston.user_roles:**
   ```sql
   -- ❌ ANTES
   SELECT group_ids FROM houston.user_roles

   -- ✅ DEPOIS
   SELECT grupo_ids FROM houston.user_roles
   ```

### Migrations
Total de 4 migrações nesta versão:
1. `20251205171355` - Migração de RLS complexo para filtragem via JWT
2. `20251206092405` - Padronização de schema e suporte para API routes
3. `20251207035652` - Padronização completa da gestão de grupos
4. `20251207213424` - Correção de vulnerabilidade na tabela user_roles

---

## [2.2.0] - 2025-12-04

### Added
- Sistema de pagamentos completo integrado ao RBAC
- Permissões granulares para tabela `pagamentos` por role
- View `vw_folha_pagamento` para relatórios de pagamento
- Políticas RLS para tabela `pagamentos` baseadas em `houston.authorize()`
- Triggers automáticos para atualização de timestamps em `pagamentos`

### Changed
- Otimização de políticas RLS com uso de JWT para redução de ~50% em queries
- Remoção de coluna `medicos_favoritos` da view `vw_vagas_candidaturas`
- Refatoração de políticas da tabela `candidaturas` para melhor performance

### Fixed
- Função de autorização `houston.authorize()` para políticas RLS do RBAC
- Políticas para tabela `houston.user_roles`
- Função de exclusão de vagas com validação adequada
- Função trigger de atualizar status de vaga ao aprovar candidatura
- URLs de redirecionamento adicionais para criação de senha
- Erros de acentuação e ortografia em comentários e documentação
- Nomes de tabela antigos em função de verificação de conflitos
- Nome de coluna errado em função trigger da tabela `medicos`
- Acesso público habilitado na view `vw_vagas_abertas`
- Configuração de timezone e conversão para `timestamptz` em colunas temporais
- Remoção de adição automática do código de área '55' na criação de usuário escalista

### Performance
- Otimização de políticas RLS utilizando informações do JWT (redução de 50% em queries)
- Remoção de índices duplicados e nunca usados para ganhos de performance
- Otimização e limpeza geral de políticas para melhor performance

### Removed
- Função redundante de autorização (substituída por `houston.authorize()`)
- Recriação desnecessária de políticas da tabela candidaturas

### Security
- Melhoria na validação de permissões em políticas RLS
- Proteção adicional em funções de autorização

---

## [2.1.0] - 2025-11-28

### Added
- Coluna `ordem` à tabela `grades` para controle de exibição customizado
- Suporte a ordenação drag-and-drop de grades
- Sistema unificado de edge functions com proteção de secrets
- Templates HTML padronizados para e-mails transacionais
- URLs de redirecionamento unificadas para todos os ambientes

### Changed
- Otimização da view `vw_vagas_candidaturas` com uso de CTEs
- Unificação de configurações do Supabase no arquivo `config.toml`
- Estrutura aprimorada do `config.toml` com suporte a múltiplos ambientes
- Padronização completa de templates de e-mail (confirmation, email_change, invite, magic_link, recovery, reauthentication)

### Fixed
- Remoção de trigger fora de padrão da tabela `grades`
- Correção do nome da coluna de especialidades na view `vw_folha_pagamento`
- Remoção de inserção automática de usuário quando não encontrado em `user_roles`
- Adição de permissões faltantes para gestão de médicos no Houston

### Removed
- Edge function obsoleta `confirm-verification`
- Arquivo backup da migração inicial

### Configuration
- Configuração unificada para ambientes local, staging e production
- Schema `houston` adicionado aos schemas expostos na API
- Storage buckets configurados corretamente
- Auth hooks ativados para custom access token

### Performance

#### Otimizações Implementadas
- **Queries de Autorização:** Redução de 50-66% (JWT-first approach)
- **View vw_vagas_candidaturas:** 70% mais rápida com CTEs otimizadas
- **Índices:** 30% mais rápido em INSERTs/UPDATEs após limpeza
- **Tamanho do Banco:** Backups 60% mais rápidos após limpeza
- **RLS Policies:** Short-circuit para administradores
- **JWT-First Approach:** Permissões lidas do JWT antes do banco

---

## [2.0.0] - 2025-11-21

### Refatoração Arquitetural Completa

Esta versão marca uma **refatoração massiva** do banco de dados com foco em segurança, performance, escalabilidade e manutenibilidade. Total de 19 migrações consolidadas.

### Added

#### Sistema RBAC (Role-Based Access Control)
- **Schema Houston:** Schema dedicado para controle de acesso
- **5 Roles Hierárquicas:**
  - `administrador` (nível 1) - acesso total
  - `moderador` (nível 2) - gestão completa
  - `gestor` (nível 3) - gestão de unidades e escalas
  - `coordenador` (nível 4) - coordenação de equipes
  - `escalista` (nível 5) - operação de escalas
- **50+ Permissões Granulares:** Sistema `{recurso}.{ação}`
- **Funções Core:**
  - `houston.authorize()` - verificação de permissões
  - `houston.get_user_complete_data()` - dados completos do usuário
  - `houston.custom_access_token_hook()` - injeção de role/permissões no JWT
  - `houston.role_level()` - nível hierárquico da role
- **Tabelas:**
  - `houston.user_roles` - vínculo usuário-role
  - `houston.role_permissions` - mapeamento role-permissões
  - `houston.user_groups` - usuários em múltiplos grupos
  - `houston.user_hospitals` - usuários em múltiplos hospitais

#### Políticas RLS Completas
- 100+ políticas RLS implementadas
- Cobertura de 30+ tabelas sensíveis
- Todas as políticas usam `houston.authorize()` para verificação
- Políticas separadas por ação (SELECT, INSERT, UPDATE, DELETE)
- Filtros adicionais por contexto (grupo, hospital, setor)

#### Funções de Paginação
- `get_vagas_paginated()` - paginação de vagas com filtros
- `get_applications_paginated()` - paginação de candidaturas
- `get_medicos_paginated()` - paginação de médicos
- 15+ funções especializadas de paginação
- Suporte a ordenação dinâmica e filtros compostos
- SECURITY INVOKER para usar permissões do usuário

#### Views Otimizadas
- `vw_vagas_candidaturas` - view central com dados completos
- `vw_vagas_abertas` - vagas públicas para médicos (acesso público)
- `vw_folha_pagamento` - relatórios de pagamento

#### Funções Utilitárias Mobile
- `get_medico_profile()` - perfil completo do médico
- `get_vagas_disponiveis()` - vagas disponíveis
- `candidatar_vaga()` - candidatura simplificada
- 10+ funções específicas para app mobile

#### Triggers Padronizados
- Sistema de triggers para `updated_at` automático (15+ tabelas)
- Triggers de atualização de status de vagas
- Validações de conflitos de horário
- Logs de auditoria para mudanças críticas

### Changed

#### Padronização Completa de Schema
- **Convenção snake_case:** Todas as tabelas e colunas
- **Pluralização:** Nomes de tabelas no plural (`vagas`, `medicos`, `candidaturas`)
- **Foreign Keys Padronizadas:** Padrão `{tabela}_id`
- **Timezone Global:** `America/Sao_Paulo` configurado
- **Timestamps:** Conversão de `timestamp` para `timestamptz` em todas as colunas temporais
- **Exemplos de Renomeações:**
  - `Vaga` → `vagas`
  - `Medico` → `medicos`
  - `medicoId` → `medico_id`
  - `createdAt` → `created_at`

#### Arquitetura de Escalistas
- Escalistas migrados de tabela separada para sistema RBAC
- Usuários com role `escalista` em `houston.user_roles`
- Suporte a múltiplos grupos via `houston.user_groups`
- Dados migrados automaticamente preservando relacionamentos

#### Sistema de Criação de Usuários
- Refatoração completa do fluxo de criação
- Validação de telefone melhorada
- Padronização de emails
- Suporte a múltiplos grupos
- Criação atômica (tudo ou nada)

### Removed

#### Limpeza Massiva
- 8 tabelas obsoletas removidas
- 12 views não utilizadas removidas
- 15+ funções redundantes removidas
- 30+ índices duplicados removidos
- 5 triggers fora de padrão removidos
- 92.000+ linhas do `seed.sql` (dados de teste obsoletos)
- Tabela `escalista` (migrada para RBAC)

### Security

#### Melhorias de Segurança
- RBAC completo com controle granular
- RLS ativado em todas as tabelas sensíveis
- JWT otimizado com role e permissões no token
- Proteção contra SQL injection com prepared statements
- Funções com SECURITY DEFINER quando necessário
- Secrets management aprimorado

### Fixed
- Correção de triggers após padronização de schema
- Correção de nomes de colunas em múltiplas funções
- Padrão híbrido para candidaturas implementado
- Validação de conflitos de horário melhorada

### Configuration
- Arquivo `config.toml` completamente refatorado
- Suporte a múltiplos ambientes (local, staging, production)
- Configurações compartilhadas entre ambientes
- Schema Houston exposto na API

### Migrations
Total de 19 migrações consolidadas (~8.000 linhas de SQL):
1. `20251117000001` - Migração de dados de escalistas
2. `20251117000002` - Schema RBAC Houston completo (702 linhas)
3. `20251117000003` - Remoção de tabelas/views não utilizadas
4. `20251117000004` - Padronização de schema completa (1197 linhas)
5. `20251117000005` - Refatoração arquitetura de escalistas (429 linhas)
6. `20251117000006` - RLS policies completas (1098 linhas)
7. `20251117000007` - Funções de paginação completas (1091 linhas)
8. `20251117000008` - Funções de recorrência completas (499 linhas)
9. `20251117000009` - Outras funções complementares
10. `20251117000010` - Triggers completos
11. `20251117000011` - Views completas (329 linhas)
12. `20251121171652` - Refatoração criação de usuários (185 linhas)
13. `20251121202433` - Funções utilitárias mobile (129 linhas)

### Breaking Changes

⚠️ **Mudanças que requerem atualização nos clients:**

1. **Nomes de Tabelas e Colunas:**
   ```sql
   -- ❌ ANTES
   SELECT * FROM Vaga WHERE medicoId = '...'

   -- ✅ DEPOIS
   SELECT * FROM vagas WHERE medico_id = '...'
   ```

2. **Estrutura de Escalistas:**
   ```sql
   -- ❌ ANTES
   SELECT * FROM escalista WHERE id = '...'

   -- ✅ DEPOIS
   SELECT * FROM houston.user_roles
   WHERE user_id = '...' AND role = 'escalista'
   ```

3. **Autorização:** Todas as queries agora passam pelo RBAC e são filtradas por RLS

4. **Timestamps:** Todas as colunas agora são `timestamptz` com timezone

5. **JWT Claims:** Novos claims disponíveis (`user_role`, `permissions`, `group_ids`, `hospital_ids`)

---

## [1.0.0]

### Versão Inicial do Sistema

#### Added

##### Tabelas Principais
- `Vaga` - Gestão de vagas médicas
- `Medico` - Cadastro de médicos
- `Candidatura` - Candidaturas de médicos a vagas
- `CheckinCheckout` - Registro de entrada/saída de médicos
- `escalista` - Gestão de escalistas (tabela separada)
- `grupo` - Grupos de hospitais
- `hospital` - Cadastro de hospitais
- `setor` - Setores hospitalares
- `especialidade` - Especialidades médicas
- `grade` - Grades de plantão
- `pagamentos` - Registro de pagamentos (versão inicial)

##### Sistema de Paginação (v1)
- `get_vagas_paginated()` - versão inicial
- `get_applications_paginated()` - versão inicial
- Suporte a filtros básicos
- Ordenação simples

##### Views Iniciais
- `vw_vagas_candidaturas` - versão inicial
- `vagas_completo` - view completa de vagas

##### Funções de Conflito
- Verificação de conflitos de horário para médicos
- Suporte a turnos noturnos
- Prevenção de candidaturas em datas passadas

##### Funções de Exclusão
- `bulk_delete_function()` - exclusão em lote de registros
- Suporte a múltiplas entidades

##### Dados Bancários
- Suporte a informações bancárias de médicos
- Campos para pagamento

##### View de Vagas Abertas
- `vw_vagas_abertas` - vagas públicas para médicos
- Acesso sem autenticação

#### Funções de Recorrência
- Sistema completo para gestão de vagas recorrentes
- Suporte a recorrência diária, semanal e mensal
- Atualização em cascata de séries
- Validação de conflitos de horário
- Exclusão inteligente de séries

##### Políticas RLS Básicas
- RLS habilitado em tabelas principais
- Políticas baseadas em auth.uid()
- Acesso público a `clean_hospital` (sanitização de nomes)
- Acesso público a contato de WhatsApp

##### Documentação
- README.md com instruções de setup
- Fluxo de branches e ambientes documentado
- Guia de linking com projeto remoto

### Security
- SECURITY INVOKER em funções de paginação
- RLS habilitado em tabelas sensíveis
- Políticas básicas de acesso por usuário

### Configuration
- Configuração inicial do Supabase
- Setup de ambientes de desenvolvimento
- Configuração de storage buckets
- Hooks básicos configurados

---

## Convenções de Commit

Este projeto utiliza [Conventional Commits](https://www.conventionalcommits.org/pt-br/):

- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `refactor:` - Refatoração de código
- `perf:` - Melhorias de performance
- `docs:` - Documentação
- `build:` - Mudanças no sistema de build
- `chore:` - Tarefas de manutenção
- `test:` - Testes
