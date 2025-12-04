# Correções de Sincronização e Políticas

## Problemas Corrigidos

### 1. Problema das Políticas (Splash Screen)
**Problema**: Toda vez que o usuário fazia login, aparecia a tela `/policies` mesmo já tendo aceito.

**Solução**: 
- Corrigida a lógica de verificação de políticas no `splash_screen.dart`
- Agora verifica corretamente se as políticas foram aceitas e se a versão é atual
- Adicionados logs de debug para facilitar troubleshooting

**Arquivos modificados**:
- `lib/screens/splash_screen.dart`

### 2. Problema de Sincronização com Supabase
**Problema**: Provas, disciplinas e metas criadas não estavam sincronizando com o Supabase.

**Causa**: 
- As tabelas do Supabase não tinham o campo `user_id`
- As políticas RLS permitiam acesso a todos os usuários autenticados, sem filtrar por usuário
- Os datasources não estavam incluindo `user_id` nas queries e inserts

**Solução**:
1. Adicionado campo `user_id` nas tabelas do Supabase (provas, disciplinas, tarefas)
2. Atualizadas as políticas RLS para filtrar por `user_id`
3. Atualizados os DTOs para incluir `user_id`
4. Atualizados os datasources remotos para incluir `user_id` nas queries e inserts
5. Atualizados os mappers para incluir `user_id` ao converter de Entity para DTO

**Arquivos modificados**:
- `docs/supabase_tables.sql` - Adicionado `user_id` e políticas RLS atualizadas
- `docs/supabase_migration_add_user_id.sql` - Script de migração para tabelas existentes
- `lib/data/models/prova_dto.dart` - Adicionado campo `userId`
- `lib/data/models/disciplina_dto.dart` - Adicionado campo `userId`
- `lib/data/datasources/prova_remote_datasource.dart` - Filtro por `user_id` e inclusão em inserts
- `lib/data/datasources/disciplina_remote_datasource.dart` - Filtro por `user_id` e inclusão em inserts
- `lib/data/mappers/prova_mapper.dart` - Inclusão de `user_id` ao converter para DTO
- `lib/data/mappers/disciplina_mapper.dart` - Inclusão de `user_id` ao converter para DTO

## Como Aplicar as Correções

### 1. Atualizar o Banco de Dados do Supabase

#### Opção A: Tabelas Novas (Recomendado para desenvolvimento)
Execute o script `docs/supabase_tables.sql` atualizado no SQL Editor do Supabase.

#### Opção B: Migração de Tabelas Existentes
Se você já tem dados nas tabelas, execute:
1. Primeiro, execute `docs/supabase_migration_add_user_id.sql` no SQL Editor do Supabase
2. **IMPORTANTE**: Se você tem dados antigos sem `user_id`, você precisa:
   - Deletar os dados antigos (recomendado para desenvolvimento)
   - OU atribuir manualmente cada registro ao usuário correto

### 2. Testar a Sincronização

1. Faça login no app
2. Crie uma nova disciplina
3. Crie uma nova prova
4. Crie uma nova meta diária
5. Verifique no Supabase se os dados foram salvos com o `user_id` correto

### 3. Verificar as Políticas

1. Faça login no app
2. Verifique se não aparece mais a tela de políticas (se já aceitou anteriormente)
3. Se aparecer, aceite as políticas novamente
4. Faça logout e login novamente
5. Verifique se não aparece mais a tela de políticas

## Notas Importantes

1. **Dados Antigos**: Se você tem dados antigos sem `user_id`, eles não serão sincronizados corretamente. Recomenda-se deletar os dados antigos ou atribuí-los manualmente ao usuário correto.

2. **Políticas RLS**: As novas políticas RLS garantem que cada usuário só vê e modifica seus próprios dados. Isso é importante para segurança e privacidade.

3. **Sincronização Offline-First**: O app continua funcionando offline. Os dados são salvos localmente primeiro e sincronizados com o Supabase quando possível.

4. **Logs de Debug**: Foram adicionados logs de debug no `splash_screen.dart` para facilitar o troubleshooting. Você pode verificar os logs no console do Flutter.

## Próximos Passos

- [ ] Executar o script de migração no Supabase
- [ ] Testar a criação de provas, disciplinas e metas
- [ ] Verificar se os dados aparecem corretamente no Supabase
- [ ] Testar a sincronização entre dispositivos (se aplicável)

