# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [2.6.0] - 2026-01-19

### Added

#### Sistema de Chat (Schema Houston)
- **Tabelas de Chat Completas:**
  - `houston.chat_conversations` - Conversas (direct ou group)
  - `houston.chat_participants` - Participantes das conversas
  - `houston.chat_messages` - Mensagens com suporte a múltiplos tipos
  - `houston.chat_shift_offers` - Ofertas de plantão via chat
  - `houston.chat_contacts` - Agenda pessoal de contatos
- **Tipos de Mensagem Suportados:** text, image, audio, video, file, document, location, shift_offer, shift_response, system, sticker, contact, interactive, template
- **Realtime:** Tabelas `chat_messages`, `chat_conversations`, `chat_shift_offers` e `chat_participants` adicionadas ao Realtime
- **Storage Bucket:** `chat-files` para arquivos de mídia (50MB, múltiplos formatos)
- Triggers automáticos para `updated_at`, `last_message` e contador de mensagens não lidas

#### Instâncias Zapster por Grupo
- **Tabela `houston.zapster_instances`:** Gerenciamento de instâncias WhatsApp por grupo
- Suporte a status de conexão (connected, disconnected, offline)
- Metadados flexíveis via JSONB
- Constraint de uma instância por grupo (`unique_grupo_instance`)

#### Novas Permissões
- Permissão `pagamentos.delete` adicionada para roles `gestor` e `coordenador`

### Changed
- Coluna `grupo_id` adicionada à tabela `chat_conversations` para isolamento por instância WhatsApp
- Colunas `phone_number` (chat_participants) e `sender_phone` (chat_messages) agora permitem NULL para mensagens internas

### Fixed
- **FK `grades.updated_by`:** Alterada para `ON DELETE SET NULL`, permitindo deleção de usuários sem bloqueio por referência

### Performance
- **Otimização da view `vw_vagas_candidaturas`:**
  - Refatoração da função `pode_ver_candidatura_colega` → `filtrar_candidaturas`
  - Marcador `STABLE` para caching dentro da mesma query
  - `LIMIT 1` em EXISTS para parar na primeira correspondência
  - **Resultado:** Queries de 8s+ reduzidas para ~100ms
- **Novos índices de suporte:**
  - `idx_candidaturas_medico_status`
  - `idx_candidaturas_status_vaga`
  - `idx_vagas_hospital_setor`

### Security
- RLS completo implementado nas tabelas de chat
- Políticas específicas por ação (SELECT, INSERT, UPDATE, DELETE)

### Migrations
Total de 5 migrações nesta versão:
1. `20251205150955` - Criação das tabelas de chat no schema Houston
2. `20260116141549` - Correção da FK grades.updated_by para ON DELETE SET NULL
3. `20260116181649` - Criação da tabela zapster_instances
4. `20260116181650` - Ajustes nas tabelas de chat e adição de grupo_id em conversas
5. `20260119161148` - Otimização de performance da view vw_vagas_candidaturas

---

## [2.3.1] - 2024-12-08

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

## [2.3.0] - 2024-12-08

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

## [2.2.0] - 2024-12-04

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

## [2.1.0] - 2024-11-28

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

## [2.0.0] - 2024-11-21

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
