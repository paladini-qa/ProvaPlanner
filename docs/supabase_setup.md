# Configuração do Supabase

Este documento descreve como configurar o Supabase para o ProvaPlanner.

## 1. Criar Projeto no Supabase

1. Acesse [https://supabase.com](https://supabase.com)
2. Crie uma conta ou faça login
3. Crie um novo projeto
4. Anote a **URL do projeto** e a **chave anônima (anon key)**

## 2. Configurar Variáveis de Ambiente

Adicione as seguintes variáveis ao arquivo `.env` na raiz do projeto:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-key-aqui
```

## 3. Criar Tabela no Supabase

Execute o seguinte SQL no SQL Editor do Supabase:

```sql
-- Criar tabela daily_goals
CREATE TABLE IF NOT EXISTS daily_goals (
  id TEXT PRIMARY KEY,
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  data TEXT NOT NULL,
  concluida BOOLEAN NOT NULL DEFAULT false,
  prioridade TEXT NOT NULL DEFAULT 'media',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índice para melhorar performance nas consultas por data
CREATE INDEX IF NOT EXISTS idx_daily_goals_data ON daily_goals(data);

-- Habilitar Row Level Security (RLS)
ALTER TABLE daily_goals ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura e escrita para usuários autenticados
-- (Ajuste conforme sua estratégia de autenticação)
CREATE POLICY "Permitir acesso completo para usuários autenticados"
  ON daily_goals
  FOR ALL
  USING (auth.role() = 'authenticated');

-- Política alternativa: permitir acesso público (apenas para desenvolvimento)
-- ATENÇÃO: Remova esta política em produção!
CREATE POLICY "Permitir acesso público"
  ON daily_goals
  FOR ALL
  USING (true);
```

## 4. Estrutura da Tabela

| Coluna       | Tipo      | Descrição                                                        |
| ------------ | --------- | ---------------------------------------------------------------- |
| `id`         | TEXT      | Identificador único da meta (chave primária)                     |
| `titulo`     | TEXT      | Título da meta diária                                            |
| `descricao`  | TEXT      | Descrição detalhada da meta                                      |
| `data`       | TEXT      | Data da meta no formato ISO8601                                  |
| `concluida`  | BOOLEAN   | Status de conclusão (padrão: false)                              |
| `prioridade` | TEXT      | Prioridade da meta: 'alta', 'media' ou 'baixa' (padrão: 'media') |
| `created_at` | TIMESTAMP | Data de criação do registro                                      |
| `updated_at` | TIMESTAMP | Data da última atualização                                       |

## 5. Funcionalidades Implementadas

A integração com Supabase fornece:

- ✅ **Sincronização offline-first**: Os dados são salvos localmente primeiro e sincronizados com o Supabase quando possível
- ✅ **Fallback automático**: Se o Supabase não estiver disponível, a aplicação continua funcionando apenas com armazenamento local
- ✅ **Sincronização bidirecional**: Dados do servidor são sincronizados com o armazenamento local
- ✅ **Operações CRUD completas**: Criar, ler, atualizar e deletar metas diárias

## 6. Autenticação (Opcional)

Para implementar autenticação de usuários:

1. Configure autenticação no Supabase (Email, OAuth, etc.)
2. Atualize as políticas RLS para usar `auth.uid()`
3. Adicione coluna `user_id` na tabela para associar dados ao usuário

Exemplo de política com autenticação:

```sql
CREATE POLICY "Usuários podem ver apenas suas próprias metas"
  ON daily_goals
  FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Usuários podem criar apenas suas próprias metas"
  ON daily_goals
  FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);
```

## 7. Troubleshooting

### Erro: "Supabase não inicializado"

- Verifique se as variáveis `SUPABASE_URL` e `SUPABASE_ANON_KEY` estão no arquivo `.env`
- Verifique se o arquivo `.env` está na raiz do projeto
- Verifique se as credenciais estão corretas

### Erro: "Erro ao buscar metas diárias"

- Verifique se a tabela `daily_goals` foi criada no Supabase
- Verifique as políticas RLS (Row Level Security)
- Verifique se a estrutura da tabela corresponde ao esperado

### Dados não sincronizam

- Verifique a conexão com a internet
- Verifique os logs do Supabase no dashboard
- A aplicação continuará funcionando localmente mesmo sem sincronização
