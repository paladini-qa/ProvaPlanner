# Troubleshooting - Sincronização com Supabase

## Problema: Disciplina/Prova/Meta não sincroniza

### 1. Verificar se a migração foi executada

**Sintoma**: Erro ao salvar indicando que a coluna `user_id` não existe.

**Solução**: Execute o script de migração no Supabase:
```sql
-- Execute docs/supabase_migration_add_user_id.sql no SQL Editor do Supabase
```

### 2. Verificar se o Supabase está inicializado

**Sintoma**: Logs mostram "remoteDataSource é null - Supabase não está inicializado"

**Solução**: 
- Verifique se o arquivo `.env` existe e tem as credenciais corretas
- Verifique se `SupabaseConfig.initialize()` foi chamado no `main.dart`

### 3. Verificar se o usuário está autenticado

**Sintoma**: Erro "Usuário não autenticado"

**Solução**:
- Faça login no app antes de criar disciplinas/provas
- Verifique se o `AuthService.currentUserId` retorna um valor

### 4. Verificar políticas RLS no Supabase

**Sintoma**: Erro de permissão ao inserir/atualizar

**Solução**: Execute as políticas RLS corretas:
```sql
-- Verifique se as políticas foram criadas corretamente
SELECT * FROM pg_policies WHERE tablename = 'disciplinas';
```

### 5. Verificar logs de debug

**Como verificar**:
1. Abra o console do Flutter/Dart
2. Procure por logs que começam com:
   - `DisciplinaRepository:`
   - `DisciplinaRemoteDataSource:`
   - `ProvaRepository:`
   - `ProvaRemoteDataSource:`

**Logs esperados ao salvar**:
```
DisciplinaRepository: Tentando salvar disciplina no Supabase: [id]
DisciplinaRemoteDataSource: userId: [uuid]
DisciplinaRemoteDataSource: JSON a ser inserido: {...}
DisciplinaRemoteDataSource: Resposta do Supabase: [...]
DisciplinaRepository: Disciplina salva com sucesso no Supabase: [id]
```

**Se houver erro**, você verá:
```
DisciplinaRepository: Erro ao salvar disciplina no Supabase: [erro]
DisciplinaRemoteDataSource: Erro ao salvar: [erro]
```

### 6. Verificar estrutura da tabela no Supabase

Execute no SQL Editor do Supabase:
```sql
-- Verificar se a coluna user_id existe
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'disciplinas' AND column_name = 'user_id';

-- Verificar se há dados sem user_id
SELECT COUNT(*) FROM disciplinas WHERE user_id IS NULL;
```

### 7. Testar conexão com Supabase manualmente

Execute no SQL Editor do Supabase:
```sql
-- Verificar se consegue inserir manualmente
INSERT INTO disciplinas (id, user_id, nome, professor, periodo, descricao, cor, dataCriacao)
VALUES (
  'test-' || extract(epoch from now())::text,
  auth.uid(),
  'Teste',
  'Professor Teste',
  '1º Período',
  'Descrição teste',
  4280391411,
  now()::text
);
```

### 8. Verificar formato do user_id

O `user_id` deve ser um UUID válido. Verifique:
```dart
final userId = AuthService.currentUserId;
print('User ID: $userId'); // Deve ser um UUID como: 123e4567-e89b-12d3-a456-426614174000
```

### 9. Limpar dados locais e tentar novamente

Se os dados locais estão corrompidos:
1. Desinstale e reinstale o app
2. OU limpe os dados do app nas configurações do dispositivo

### 10. Verificar se a tabela existe

Execute no SQL Editor do Supabase:
```sql
-- Verificar se a tabela existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_name = 'disciplinas'
);
```

## Checklist de Verificação

- [ ] Migração executada no Supabase
- [ ] Supabase inicializado no app
- [ ] Usuário autenticado
- [ ] Políticas RLS configuradas
- [ ] Coluna `user_id` existe na tabela
- [ ] Logs de debug habilitados
- [ ] Sem erros no console
- [ ] Dados aparecem no Supabase após salvar

## Próximos Passos

Se após verificar todos os itens acima o problema persistir:

1. Copie os logs completos do console
2. Verifique o erro específico no Supabase (Logs > API Logs)
3. Verifique se há constraints ou triggers que podem estar bloqueando a inserção

