# Configuração da API do Google Gemini

Este guia explica como configurar a API do Google Gemini para usar as funcionalidades de IA no ProvaPlanner.

## Passo 1: Obter a Chave da API

1. Acesse o [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Faça login com sua conta Google
3. Clique em "Get API Key" ou "Criar chave de API"
4. Se solicitado, crie um novo projeto Google Cloud ou selecione um existente
5. Copie a chave de API gerada

## Passo 2: Configurar o Arquivo .env

1. Na raiz do projeto, crie um arquivo chamado `.env` (se não existir)
2. Copie o conteúdo de `.env.example` para `.env`
3. Cole sua chave de API no lugar de `sua_chave_aqui`:

```env
GEMINI_API_KEY=SUA_CHAVE_AQUI
USE_MOCK_AI=false
```

## Passo 3: Adicionar .env ao .gitignore

Certifique-se de que o arquivo `.env` está no `.gitignore` para não commitar sua chave:

```
.env
```

## Modo Mock (Sem API)

Se você não quiser usar a API real (útil para testes ou avaliação offline):

```env
USE_MOCK_AI=true
```

Quando `USE_MOCK_AI=true`, o aplicativo usará respostas simuladas sem fazer chamadas à API do Gemini.

## Verificação

Após configurar, execute o aplicativo. Se a configuração estiver correta:
- O resumo diário será gerado automaticamente
- As sugestões de metas funcionarão corretamente

Se houver erro, verifique:
- Se a chave está correta no arquivo `.env`
- Se o arquivo `.env` está na raiz do projeto
- Se o arquivo foi carregado corretamente (verifique os logs)

## Limites e Custos

A API do Gemini tem limites de uso gratuito. Consulte a [documentação oficial](https://ai.google.dev/pricing) para mais informações sobre limites e custos.

## Segurança

⚠️ **IMPORTANTE**: Nunca commite o arquivo `.env` com sua chave de API no repositório. Isso pode expor sua chave e resultar em uso não autorizado e custos inesperados.

