# Especificações do Projeto - Daily Goals com IA

Este arquivo contém o enunciado original do projeto fornecido pelo professor.

## Enunciado: Implementação e apresentação — Features com apoio de IA

### Objetivo

Partindo da feature implementada em sala no projeto da Emily — que já oferece a tela de listagem com FAB (microanimação), tip bubble e overlay de tutorial, além da dialog de criação/edição que retorna a entidade escolhida pronta — você deve completar e demonstrar duas features para melhorar a experiência com daily goals.

**Importante**: A IA é um recurso opcional que você pode empregar para apoiar o desenvolvimento (p.ex., transformação de linguagem natural, mensagens, resumos) e/ou a documentação. Prompts de referência estão disponíveis no repositório para quem desejar utilizá-los.

### Base já implementada em sala

Partiremos da feature implementada em sala. Essa base já entrega:

- Tela de listagem de metas diárias com estado vazio acolhedor, FAB com microanimação, tip bubble e overlay de tutorial (sem sobrepor modais após confirmação).
- Dialog de criação/edição que coleta dados do usuário, aplica validação mínima na UI e retorna **a entidade escolhida** pronta.
- Um esqueleto de persistência local conceitual (DTO + armazenamento chave/valor serializado) suficiente para conectar as próximas etapas quando evoluirmos do layout‑only para dados reais.

### Requisitos principais (contrato)

**Entrada**: base existente da feature implementada em sala. Não altere contratos públicos já usados pela tela/dialog sem documentar claramente o motivo e o impacto.

**Saída**: duas features (IA opcional) e um documento explicativo no repositório. O projeto deve compilar (ou, no mínimo, não quebrar contratos/importações existentes) e estar claramente documentado.

**Entrega**: o repositório com prompts/especificacoes.md (este enunciado), as implementações das features e o documento de apresentação docs/apresentacao.md (detalhado abaixo). O aluno enviará o repositório ao professor via WhatsApp.

### Observações sobre uso de IA

- Você pode usar qualquer serviço de LLM (OpenAI, Anthropic, Claude, LLM local, etc.). Se usar um serviço pago, explique a alternativa (ex.: prompts + mocks) para a avaliação offline.
- Inclua os prompts exatos usados (texto) no documento de entrega. Explique as decisões de design do prompt e as tentativas de refinamento.

### Documentação obrigatória (entrega principal)

Crie `docs/apresentacao.md` contendo:

1. **Sumário executivo** (máx. 1 página): o que foi implementado e resultados.
2. **Arquitetura e fluxo de dados**: diagrama simples (ASCII ou imagem) e explicação curta de onde (se houver) a IA entra no fluxo (inputs/outputs).
3. **Para cada feature implementada**:
   - Objetivo
   - (Se usar IA) Prompt(s) usados e comentários sobre cada parte
   - Exemplos de entrada e saída (pelo menos 3 casos com variação)
   - Como testar localmente (passo a passo)
   - Limitações e riscos (ex.: vieses, privacidade)
   - Código gerado pela IA (se aplicável): trechos relevantes e explicação linha a linha do porquê são corretos/necessários.
   - Logs de experimentos (opcional): iterações de prompt/resposta que levaram à solução final.
4. **Roteiro de apresentação oral**: como a IA ajudou (se usada), decisões de design, por que a solução é segura/ética, quais testes foram feitos.
5. **Política de branches e commits** (obrigatória): descreva como você trabalhou com controle de versão — crie uma branch nova para cada feature e registre um commit a cada objetivo concluído, com mensagens claras.

### Formato de submissão

- Inclua o arquivo `docs/apresentacao.md` na raiz docs/.
- Garanta que qualquer código novo esteja dentro do repositório e com imports relativos corretos.
- Se for enviar por WhatsApp: compacte o repositório na raiz (zip) ou envie apenas a pasta com código e docs/. Recomenda-se criar um .zip e enviar.

### Critérios de avaliação (peso)

- **Funcionalidade das features (40%)**: correção, robustez, testes mínimos.
- **Uso responsável da IA (20%)**: documentação dos prompts, modos mock/live, justificativas sobre privacidade e vieses.
- **Qualidade do documento (20%)**: clareza, exemplos e explicações da operação do código/IA.
- **Apresentação e entendimento (20%)**: a capacidade de explicar como a IA foi usada, detalhar o código gerado e responder perguntas técnicas.

### Entrega final

- Código no repositório com commits claros.
- `docs/apresentacao.md` contendo tudo solicitado.
- (Opcional) Arquivos de teste em `test/` que verifiquem o comportamento básico.
- O aluno deverá estar pronto para apresentar: mostrar os prompts, o funcionamento, explicar cada trecho de código gerado pela IA, e discutir limitações.

### Boas práticas e observações finais

- Anote todas as chamadas ao modelo em docs/ (se usar serviço externo, NÃO comite chaves/segredos). Use variáveis de ambiente para chaves e documente como setá-las.
- Considere privacidade: explique no documento se algum dado sensível foi enviado ao provedor de IA.
- Seja crítico com resultados da IA: sempre valide/normalize valores retornados antes de persistir.

