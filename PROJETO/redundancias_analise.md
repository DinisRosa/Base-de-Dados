# Análise de Redundâncias: Funções, Triggers e Procedures

Após uma análise detalhada do código SQL (`0_full_database.sql`), identifiquei várias redundâncias significativas entre as *Procedures* e os *Triggers*. Em muitos casos, a lógica está duplicada, o que significa que o sistema executa a mesma ação duas vezes ou tem o código de validação repetido em locais diferentes.

Abaixo estão os casos mais críticos encontrados, juntamente com a minha avaliação e recomendação do que deve ser mantido ou eliminado:

## 1. Redundância na Abertura de Manutenções (Procedure vs Trigger)
**Onde ocorre:** Procedure `registar_avaria` (ou `abrir_manutencao`) vs Trigger `trg_manutencao_estado_equipamento_insert`.

- **O que a Procedure faz:** Quando se regista uma nova manutenção, a procedure insere o registo e depois faz um `UPDATE` à tabela `Equipamento` para mudar o estado para "Em Manutenção".
- **O que o Trigger faz:** Este trigger está configurado para disparar `AFTER INSERT ON Manutencao`. Sempre que uma manutenção é inserida, o trigger vai *automaticamente* procurar o equipamento associado e fazer um `UPDATE` do estado para "Em Manutencao".
- **Problema:** A mesma ação de atualização do estado do equipamento está a ser feita duas vezes no mesmo fluxo de dados. Bastava a procedure inserir a manutenção, e deixar o trigger tratar da atualização do estado do equipamento.
- **👉 Minha Opinião e Recomendação:** **Eliminar o UPDATE da Procedure.** Deve manter-se a lógica no Trigger. Os Triggers são mais fiáveis para garantir a consistência dos dados, pois ativam-se sempre, mesmo que um administrador insira uma manutenção manualmente na base de dados (sem usar a procedure). A procedure `registar_avaria` deve ficar mais limpa e fazer apenas o `INSERT`.

## 2. Redundância no Fecho de Manutenções (Procedure vs Trigger)
**Onde ocorre:** Procedure `concluir_manutencao` vs Trigger `trg_manutencao_estado_equipamento_update`.

- **O que a Procedure faz:** 
  1. Atualiza a `Manutencao` preenchendo a `data_fim`.
  2. Atualiza a `Ordem_servico` mudando o estado para "Concluída".
  3. Atualiza o `Equipamento` mudando o estado para "Operacional".
- **O que o Trigger faz:** Este trigger dispara `AFTER UPDATE ON Manutencao`. Se detetar que a `data_fim` foi preenchida, ele **automaticamente**:
  1. Atualiza a `Ordem_servico` mudando o estado para "Concluida".
  2. Atualiza o `Equipamento` mudando o estado para "Operacional".
- **Problema:** Ao fazer o passo 1 da Procedure, o Trigger é disparado e executa os passos 2 e 3 de forma oculta. Depois, a Procedure continua e executa *novamente* os passos 2 e 3 explicitamente. É uma duplicação completa de esforço.
- **👉 Minha Opinião e Recomendação:** **Eliminar os UPDATEs adicionais da Procedure.** A procedure `concluir_manutencao` deve APENAS preencher a `data_fim` da manutenção. O Trigger fará automaticamente as atualizações em cascata, fechando a ordem e ativando o equipamento. Isto evita anomalias e código esparguete.

## 3. Duplicação Exata entre Procedures
**Onde ocorre:** Procedure `registar_avaria` vs Procedure `abrir_manutencao`.

- **Problema:** Ambas as procedures fazem exatamente a mesma coisa e recebem os mesmos parâmetros: validam o equipamento e a peça, inserem na `Manutencao`, inserem na `Ordem_servico` e atualizam o estado do `Equipamento`. O código é praticamente uma cópia exata, o que torna uma delas desnecessária.
- **👉 Minha Opinião e Recomendação:** **Eliminar completamente a Procedure `abrir_manutencao`.** Devemos manter apenas a `registar_avaria`. Ter duas rotinas diferentes que fazem a mesma coisa cria confusão e duplica o esforço de manutenção do código no futuro.

## 4. Validações de Domínio Duplicadas (Procedure vs Trigger)
**Onde ocorre:** Procedure `alterar_prioridade_ordem` e `validar_estado_ordem` vs Triggers de validação de domínios (`trg_ordem_servico_validar_dominios_update`).

- **O que a Procedure faz:** A procedure `alterar_prioridade_ordem` faz um `IF` para verificar se a prioridade enviada é válida ('Baixa', 'Media', 'Alta', 'Normal') antes de tentar fazer o `UPDATE`.
- **O que o Trigger faz:** O trigger que corre antes do `UPDATE` faz exatamente o mesmo `IF` para verificar se os valores pertencem ao domínio aceitável.
- **Problema:** O código de validação está duplicado. Se no futuro o hospital decidir adicionar uma nova prioridade (ex: 'Urgente'), terá de alterar o código em múltiplos locais (na Procedure e no Trigger), aumentando o risco de bugs.
- **👉 Minha Opinião e Recomendação:** **Eliminar a validação IF das Procedures.** É preferível delegar a responsabilidade da integridade dos domínios inteiramente à base de dados através dos Triggers. A procedure apenas tenta o `UPDATE` e, se for inválido, o Trigger rebenta o erro (Signal SQLSTATE).

## 5. Lógica Sobreposta (Function vs Trigger)
**Onde ocorre:** Function `equipamento_tem_manutencao_ativa` vs Trigger `trg_manutencao_validar_datas_insert`.

- **Sobreposição:** O trigger bloqueia a inserção de uma nova manutenção se o equipamento já tiver uma em curso (onde `data_fim IS NULL`). A função `equipamento_tem_manutencao_ativa` faz essencialmente a mesma verificação lógica (mas através da Ordem de Serviço). 
- **👉 Minha Opinião e Recomendação:** **Manter ambas, mas Refatorar.** Ambas são precisas para funções distintas (o Trigger atua como defesa passiva contra erros, enquanto a Função é usada ativamente por vistas e aplicações). **No entanto**, o Trigger deve ser atualizado para invocar a função. Em vez de reescrever o código no Trigger, o Trigger deveria apenas fazer: `IF equipamento_tem_manutencao_ativa(NEW.Equipamento_id_equipamento) THEN SIGNAL...`. Isto centraliza a regra de negócio num só sítio!

---

## 🎯 Veredito Final
O principal problema atual é a mistura de padrões: tentou-se criar uma "Smart DB" (base de dados inteligente movida a Triggers) e ao mesmo tempo um "Orquestrador Controlador" (movido a Procedures que forçam os passos todos).
**Devemos apostar nos Triggers para manter a base de dados robusta e simplificar drasticamente as Procedures para que apenas sejam o ponto de entrada ("interfaces" simples).**
