# CLAUDE.md - Supabase Repository

Este arquivo fornece orientações para o Claude Code ao trabalhar com migrações de banco de dados e sincronização com o frontend Houston.

## Contexto do Projeto

### Repositórios Relacionados
- **supabase**: Este repositório - contém migrações de banco de dados
- **houston-III**: Frontend Next.js que deve ser sincronizado com mudanças de schema

### Processo de Sincronização
Quando migrações são criadas neste repositório, elas podem impactar o frontend e exigir atualizações de tipos TypeScript, serviços, hooks e componentes.

## Categorização de Impacto de Migrações

### 🟢 Sem Impacto no Frontend
- Criação de índices
- Alterações de performance
- Funções internas não expostas
- Policies de RLS que não afetam dados expostos
- Triggers internos

### 🟡 Automatizável
- Novas tabelas com estrutura clara
- Novas colunas em tabelas existentes
- Novas funções RPC que seguem padrões
- Alterações em views que mantêm compatibilidade
- Novos tipos ENUM

**Implementação necessária:**
- Atualizar tipos TypeScript
- Criar/atualizar serviços
- Adicionar hooks se necessário

### 🟠 Implementação Parcial
- Mudanças que quebram compatibilidade
- Novas funcionalidades complexas
- Alterações em estruturas de dados existentes
- Remoção de campos

**Implementação necessária:**
- Análise detalhada de impacto
- Refatoração de código existente
- Testes de compatibilidade

### 🔴 Revisão Manual Obrigatória
- Migrações que removem dados
- Alterações de segurança críticas
- Mudanças em autenticação
- Restructuring de schema principal

## Análise de Migrações

### Processo de Análise
1. **Ler arquivo de migração SQL**
2. **Identificar categoria de impacto**
3. **Analisar estruturas criadas/modificadas:**
   - Tabelas e colunas
   - Funções RPC
   - Views
   - Tipos e ENUMs
   - Policies

### Estruturas que Requerem Implementação Frontend

#### Tabelas Novas
- Gerar tipos TypeScript
- Criar serviços CRUD básicos
- Implementar hooks de estado

#### Colunas Novas
- Atualizar interfaces TypeScript
- Verificar formulários existentes
- Atualizar validações

#### Funções RPC
- Criar wrappers em serviços
- Implementar hooks específicos
- Adicionar tratamento de erro

#### Views
- Atualizar tipos baseados na nova estrutura
- Verificar queries existentes

## Padrões de Implementação Houston

### Estrutura de Arquivos
```
services/
  [dominio].ts          # Serviços de API
hooks/
  use[Funcionalidade].ts  # Hooks customizados
components/
  [dominio]/            # Componentes específicos
lib/
  types/               # Definições TypeScript
```

### Padrões de Código

#### Tipos TypeScript
```typescript
// Baseado na estrutura da tabela
export interface UserPreferences {
  id: string;
  user_id: string;
  theme: 'light' | 'dark' | 'system';
  language: 'pt-BR' | 'en-US';
  notifications_enabled: boolean;
  email_notifications: boolean;
  dashboard_layout: Record<string, any>;
  created_at: string;
  updated_at: string;
}
```

#### Serviços
```typescript
import { supabase } from '@/lib/supabaseClient';

export const userPreferencesService = {
  async get(userId: string) {
    const { data, error } = await supabase
      .rpc('get_user_preferences', { p_user_id: userId });

    if (error) throw error;
    return data;
  },

  async update(preferences: Partial<UserPreferences>) {
    const { data, error } = await supabase
      .rpc('update_user_preferences', preferences);

    if (error) throw error;
    return data;
  }
};
```

#### Hooks
```typescript
import { useQuery, useMutation } from '@tanstack/react-query';
import { userPreferencesService } from '@/services/userPreferences';

export function useUserPreferences(userId: string) {
  return useQuery({
    queryKey: ['user-preferences', userId],
    queryFn: () => userPreferencesService.get(userId),
  });
}
```

## Padrões de PR - Revoluna

### Título do PR
```
Feature: Sincronização de [funcionalidade] com migração Supabase
```

**Tipos válidos:**
- **Feature**: Nova funcionalidade
- **Refactor**: Refatoração sem mudança de funcionalidade
- **Bug**: Correção de bug
- **Chore**: Tarefas de manutenção
- **Test**: Implementação de testes
- **Doc**: Documentação

### Descrição do PR
```markdown
## Resumo

- Sincronização automática com migração Supabase
- Implementação de tipos TypeScript para novas estruturas
- Criação de serviços e hooks para integração frontend

## Detalhes das mudanças

### ✨ Sincronização de Migração
- **Migração**: `20250927000000_user_preferences.sql`
- **Impacto**: 🟡 Automatizável - requer implementação frontend
- **Estruturas**: Tabela `user_preferences`, funções RPC

### ✨ Implementação Frontend
- **Tipos**: Interfaces TypeScript para `UserPreferences`
- **Serviços**: Wrappers para funções RPC do Supabase
- **Hooks**: Hooks customizados para gerenciamento de estado
- **Componentes**: Componentes de interface (se aplicável)

### 📝 Documentação
- **CLAUDE.md**: Orientações atualizadas para futuras implementações
- **Tipos**: Documentação inline dos tipos TypeScript

## Como testar
- [ ] Executar `npm run build` - verificar compilação TypeScript
- [ ] Executar `npm run lint` - verificar padrões ESLint
- [ ] Testar hooks em componente de desenvolvimento
- [ ] Verificar chamadas RPC no Supabase Dashboard
- [ ] Validar tipos com intellisense do editor

---
🤖 Implementação automática via Claude Code

**PR Supabase relacionada**: [Link da PR de origem]

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Padrão de Branch
```
feature/{issue-number}-sync-{descricao-curta}
```

Exemplo: `feature/123-sync-user-preferences`

## Instruções para Claude Code

### Quando Mencionado em PR do Supabase:
1. **Analisar migração** usando as categorias de impacto
2. **Identificar necessidades** de implementação frontend
3. **Criar branch** seguindo padrão Revoluna
4. **Implementar mudanças** necessárias:
   - Tipos TypeScript
   - Serviços
   - Hooks
   - Componentes (se necessário)
5. **Criar PR** no Houston seguindo template
6. **Comentar na PR original** com link da implementação

### Comandos de Desenvolvimento Houston
- `npm run dev` - Servidor de desenvolvimento
- `npm run build` - Build de produção
- `npm run lint` - Verificação ESLint
- `npm run type-check` - Verificação TypeScript

### Verificações Obrigatórias
Antes de criar PR, executar:
```bash
npm run build
npm run lint
```

### Cliente Supabase
Use sempre a instância configurada em `/lib/supabaseClient.ts` para manter consistência de configuração e headers de segurança.

## Exemplos de Implementação

### Migração de Tabela Nova
```sql
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  theme VARCHAR(20) DEFAULT 'system',
  -- ...
);
```

**Implementação necessária:**
1. Interface TypeScript
2. Serviço CRUD
3. Hook de estado
4. Componente de configurações (opcional)

### Migração de Função RPC
```sql
CREATE OR REPLACE FUNCTION get_user_stats(p_user_id UUID)
RETURNS JSON
-- ...
```

**Implementação necessária:**
1. Tipo para parâmetros e retorno
2. Wrapper no serviço
3. Hook específico

### Migração de View
```sql
CREATE OR REPLACE VIEW vw_dashboard_metrics AS
SELECT
  hospital_id,
  total_vagas,
  -- nova coluna
  pending_applications
FROM ...
```

**Implementação necessária:**
1. Atualizar interface da view
2. Verificar componentes que usam a view
3. Atualizar queries se necessário

## Casos Especiais

### Migrações de Segurança
- Sempre categorizar como 🔴
- Solicitar revisão manual
- Não implementar automaticamente

### Migrações que Removem Campos
- Categorizar como 🟠 ou 🔴
- Verificar impacto em código existente
- Implementar deprecation se necessário

### Migrações de Performance
- Geralmente 🟢 (sem impacto)
- Verificar se afetam queries existentes

---

**Nota**: Este arquivo deve ser consultado sempre que Claude Code for mencionado em PRs de migração do Supabase para garantir implementação consistente e seguindo padrões Revoluna.