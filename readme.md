# Documentação do Projeto Supabase

Este documento descreve os passos necessários para configurar e executar este projeto Supabase em um ambiente de desenvolvimento local.

## Pré-requisitos

Antes de começar, certifique-se de que tem as seguintes ferramentas instaladas na sua máquina:

1.  **Docker:** A CLI do Supabase utiliza o Docker para executar os serviços localmente.
    - [Instalar Docker](https://docs.docker.com/get-docker/)
2.  **Supabase CLI:** A ferramenta de linha de comando para gerir o seu projeto Supabase.
    - [Instalar Supabase CLI](https://supabase.com/docs/guides/cli/getting-started)

## Instalação

### 1. Instalar a Supabase CLI

Você pode instalar a CLI através de vários gestores de pacotes. Escolha o que preferir:

**Via npm:**

```bash
npm install supabase --save-dev
```

**Via Homebrew (macOS/Linux):**

```bash
brew install supabase/tap/supabase
```

### 2. Iniciar o Supabase

Navegue até a pasta raiz do projeto `supabase` e inicie os serviços locais:

```bash
cd supabase
supabase start
```

Este comando irá descarregar as imagens Docker necessárias e iniciar o ambiente local do Supabase. Ao final, ele irá exibir as informações de conexão, incluindo:

- **API URL**
- **Anon Key** (Chave anônima)
- **Service Role Key** (Chave de serviço)
- **URL do Supabase Studio** (para aceder à interface gráfica local)

Guarde estas informações, pois serão necessárias para conectar a sua aplicação frontend ao Supabase local.

## Gestão da Base de Dados

**Nota:** Para algumas operações avançadas, certifique-se de que o seu projeto local está conectado ao projeto remoto através do comando:

```bash
npx supabase link --project-ref <project-id>
```

### Aplicar as Migrações

Para criar a estrutura da base de dados (tabelas, funções, triggers) no seu ambiente local, execute o seguinte comando. Ele aplicará todos os ficheiros de migração que estão na pasta `supabase/migrations`.

```bash
npx supabase db reset
```

Este comando irá apagar os dados existentes na base de dados local e recriar tudo do zero, garantindo um ambiente limpo e atualizado.

### Criar uma Nova Migração

Quando fizer alterações na estrutura da base de dados (por exemplo, através do Supabase Studio local), você pode criar um novo ficheiro de migração para registar essas alterações:

```bash
npx supabase migration new <nome_descritivo_da_migracao>
```

Isto irá gerar um novo ficheiro SQL na pasta `supabase/migrations` com as diferenças entre o estado atual da sua base de dados local e a última migração.

### Inserir Dados Iniciais (Seed)

Para popular a base de dados com dados iniciais ou de teste, utilize o ficheiro `seed.sql`. Para gerar um dump dos dados atuais da sua base de dados local para o ficheiro de seed:

```bash
npx supabase db dump -f supabase/seed.sql
```

Este comando irá exportar todos os dados das tabelas da sua base de dados local para o ficheiro `supabase/seed.sql`. Quando executar `npx supabase db reset`, estes dados serão automaticamente inseridos após a aplicação das migrações.

## Comandos Úteis

- **Iniciar o ambiente local:**

  ```bash
  npx supabase start
  ```

  - Abaixo está um exemplo do resultado esperado:

  ```bash
  supabase local development setup is running.

           API URL: http://127.0.0.1:54321
       GraphQL URL: http://127.0.0.1:54321/graphql/v1
    S3 Storage URL: http://127.0.0.1:54321/storage/v1/s3
            DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
        Studio URL: http://127.0.0.1:54323
      Inbucket URL: http://127.0.0.1:54324
        JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
          anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
  service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
  ```

- **Parar o ambiente local:**
  ```bash
  npx supabase stop
  ```
- **Verificar o estado dos serviços:**
  ```bash
  npx supabase status
  ```

## Conectar ao Projeto Remoto (Produção/Staging)

Para sincronizar o seu ambiente local com o projeto remoto no Supabase Cloud:

1.  **Faça login na sua conta Supabase:**

    ```bash
    npx supabase login
    ```

2.  **Vincule o seu projeto local ao projeto remoto:**
    ```bash
    npx supabase link --project-ref <project-id>
    ```
    Você pode encontrar o `<project-id>` no URL do seu projeto no painel do Supabase (ex: `https://app.supabase.com/project/<project-id>`).
