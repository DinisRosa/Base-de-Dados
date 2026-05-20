-- Testes de Triggers
-- ============================================================
--   TESTES TRIGGERS
-- ============================================================

SELECT estado, descricao, fabricante, designacao, data_aquisicao, Equipamento_contacto_id_equipamento_contacto, Departamento_id_departamento, Localizacao_id_localizacao
FROM Equipamento;

-- Teste Trigger 1 (Data incoerente)
INSERT INTO Manutencao (custo, tipo, descricao, data_inicio, data_fim, Peca_id_peca, Equipamento_id_equipamento) 
VALUES (100.00, 'Preventiva', 'Teste de Datas Incoerentes', '2026-10-10', '2026-10-01', 1, 1);

-- Teste Trigger 1 (dupla manutenção)
-- O equipamento 3 já tem uma manutenção aberta (ID 3). Vamos tentar abrir outra.
-- EXPECTATIVA: Erro de equipamento já em manutenção.
INSERT INTO Manutencao (custo, tipo, descricao, data_inicio, data_fim, Peca_id_peca, Equipamento_id_equipamento) 
VALUES (200.00, 'Preventiva', 'Teste', '2026-05-19', NULL, 1, 3);

--  Teste Trigger 2 (Data incoerente)
UPDATE Manutencao 
SET data_fim = '2025-01-10' 
WHERE id_manutencao = 1;

-- Teste Trigger 3 (Automarizar estado para 'Em Manutencao')

-- Vai inserir uma manutenção sem data de fim para o equipamento 2
INSERT INTO Manutencao (custo, tipo, descricao, data_inicio, data_fim, Peca_id_peca, Equipamento_id_equipamento) 
VALUES (50.00, 'Corretiva', 'Substituição de cabo', '2026-05-19', NULL, 2, 2);
-- Podes correr a linha abaixo para confirmar que o estado do id 2 mudou:
SELECT id_equipamento, estado FROM Equipamento WHERE id_equipamento = 2;


-- Teste Trigger 4 (Repor estado para 'Operacional')
-- No teu povoamento, a manutenção 3 (do equipamento 3) não tem data de fim. Vamos concluí-la.
UPDATE Manutencao 
SET data_fim = '2026-05-20' 
WHERE id_manutencao = 3;
-- Podes correr a linha abaixo para confirmar que o estado do id 3 mudou para Operacional:
SELECT id_equipamento, estado FROM Equipamento WHERE id_equipamento = 3;

-- Testar Trigger 4 (Fecho Automático de Ordem de Serviço)
-- A manutenção 3 está ligada à OS 3 (que está 'Em Curso'). Vamos fechar a manutenção.
UPDATE Manutencao SET data_fim = '2026-05-20' WHERE id_manutencao = 3;
-- EXPECTATIVA: A OS 3 deve ter passado automaticamente para 'Concluida'. Confirma com:
SELECT id_ordem, estado_atual FROM Ordem_servico WHERE id_ordem = 3;


-- Tentar inserir com prioridade inventada (espera-se erro de prioridade)
-- ERRO ESPERADO: "Prioridade inválida. Valores permitidos: Baixa, Media, Alta, Normal"
INSERT INTO Ordem_servico (descricao, estado_atual, prioridade, Manutencao_id_manutencao) 
VALUES ('Teste Prioridade', 'Pendente', 'Invalida', 1);

-- Tentar inserir com estado inventado (espera-se erro de estado)
-- ERRO ESPERADO: "Estado inválido. Valores permitidos: Pendente, Em Execução, Concluída, Cancelada"
INSERT INTO Ordem_servico (descricao, estado_atual, prioridade, Manutencao_id_manutencao) 
VALUES ('Teste Estado', 'Invalido', 'Normal', 1);


-- Teste Trigger 5B (Validação de domínios no UPDATE de Ordem de Serviço)
-- Tentar atualizar para uma prioridade que não existe (espera-se erro)
UPDATE Ordem_servico 
SET prioridade = 'Baixissima' 
WHERE id_ordem = 1;


-- Teste Trigger 6A (Validação de domínios no INSERT de Equipamento)
-- Tentar inserir equipamento com estado inválido (espera-se erro)
INSERT INTO Equipamento (estado, descricao, fabricante, designacao, data_aquisicao, Equipamento_contacto_id_equipamento_contacto, Departamento_id_departamento, Localizacao_id_localizacao) 
VALUES ('Impecavel', 'Teste', 'Marca X', 'Modelo Y', '2024-01-01', 1, 1, 1);


-- Teste Trigger 6B (Validação de domínios no UPDATE de Equipamento)
-- Tentar atualizar equipamento para estado inválido (espera-se erro)
UPDATE Equipamento 
SET estado = 'Desconhecido' 
WHERE id_equipamento = 1;


-- Teste Trigger 7 (Proteger eliminação de equipamentos ativos)
-- Tentar apagar o equipamento 5, que tem a manutenção pendente nº 5 (espera-se erro)
DELETE FROM Equipamento 
WHERE id_equipamento = 5;

-- Testar Validação Financeira (Trigger 8)
-- A peça 1 custa 85.00€. Vamos tentar inserir uma manutenção que custa 50.00€.
-- EXPECTATIVA: Erro Financeiro (50 < 85).
INSERT INTO Manutencao (custo, tipo, descricao, data_inicio, data_fim, Peca_id_peca, Equipamento_id_equipamento) 
VALUES (50.00, 'Preventiva', 'Teste Custo', '2026-05-19', '2026-05-20', 1, 1);

-- Testar Validação financeira quando não tem peça associada a manutenção (não há efeito do trigger)
INSERT INTO Manutencao (custo, tipo, descricao, data_inicio, data_fim, Peca_id_peca, Equipamento_id_equipamento) 
VALUES (50.00, 'Preventiva', 'Teste Custo', '2026-05-19', '2026-05-20', null, 1);





-- Testes de Procedures
-- ============================================================
-- SCRIPT DE TESTE DE PROCEDURES
-- Executar após: modelo lógico, procedures e povoamento
-- Recomendação: Executar os blocos um a um para observar os erros.
-- ============================================================

USE `mydb`;

-- ------------------------------------------------------------
-- 1. registar_avaria
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Equipamento 1 e Peça 1 existem. Deve criar Manutenção, Ordem e mudar estado para "Em Manutenção".
CALL registar_avaria(1, 1, 'Corretiva', 150.00, 'Falha no visor (Teste)', 'Alta');

-- CASO DE ERRO: O Equipamento 999 não existe na base de dados.
-- ERRO ESPERADO: "Equipamento inexistente."
CALL registar_avaria(999, 1, 'Corretiva', 150.00, 'Falha', 'Alta');


-- ------------------------------------------------------------
-- 2. concluir_manutencao
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Concluir a manutenção que acabámos de criar no passo 1.
-- O ID gerado provavelmente foi o 4 (já que o povoamento inseriu 3 manutenções).
CALL concluir_manutencao(1);

-- CASO DE ERRO: Tentar concluir a manutenção 1 do povoamento, que já tem `data_fim` preenchida ('2025-05-03').
-- ERRO ESPERADO: "Manutencao ja concluida."
CALL concluir_manutencao(1);


-- ------------------------------------------------------------
-- 3. adicionar_intervencao_tecnico
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Técnico 1 trabalha 8 horas na Manutenção 2 e muda a ordem para "Em Execução".
CALL adicionar_intervencao_tecnico(1, 2, 'Técnico Especialista', 8, 1);

-- CASO DE ERRO: Inserir um número de horas negativo ou zero.
-- ERRO ESPERADO: "Horas de trabalho tem de ser maior que zero."
CALL adicionar_intervencao_tecnico(1, 2, 'Técnico', 0, 1);


-- ------------------------------------------------------------
-- 4. abater_equipamento
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Abater o equipamento 3 (muda estado para Inativo e cancela ordens pendentes/em execução).
CALL abater_equipamento(3);

-- CASO DE ERRO: Tentar abater um equipamento que não existe (ID 888).
-- ERRO ESPERADO: "Equipamento inexistente."
CALL abater_equipamento(888);


-- ------------------------------------------------------------
-- 5. alterar_prioridade_ordem
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Alterar a prioridade da Ordem 1 para "Alta".
CALL alterar_prioridade_ordem(1, 'Alta');

-- CASO DE ERRO: Passar um valor de prioridade que não é permitido.
-- ERRO ESPERADO: "Prioridade inválida. Valores permitidos: Baixa, Media, Alta, Normal"
CALL alterar_prioridade_ordem(1, 'Critica');



-- ------------------------------------------------------------
-- 6. listar_alertas
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Listar alertas com limites de dias válidos (10 dias).
CALL listar_alertas(10, 10);

-- CASO DE ERRO: Passar dias negativos ou zero.
-- ERRO ESPERADO: "Os limites de dias devem ser maiores que zero."
CALL listar_alertas(0, 5);


-- ------------------------------------------------------------
-- 7. validar_estado_ordem
-- ------------------------------------------------------------
-- Nota: A Ordem 1 foi criada como 'Pendente' no povoamento.
-- CASO DE SUCESSO: Mover a Ordem 1 de 'Pendente' para 'Em Execução' (transição válida).
CALL validar_estado_ordem(1, 'Em Execução');

-- CASO DE ERRO: Tentar mover a Ordem 1 (que agora está 'Em Execução') de volta para 'Pendente'.
-- ERRO ESPERADO: "Transicao de estado invalida para a ordem."
CALL validar_estado_ordem(1, 'Pendente');


-- ------------------------------------------------------------
-- 8. adicionar_responsavel
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Criar um contacto e o respetivo responsável associado à Ordem 2.
CALL adicionar_responsavel('Novo Diretor', '1980-01-01', 2, '912345678', 'diretor@hospital.pt');

-- CASO DE ERRO: Tentar associar o responsável a uma Ordem de Serviço que não existe (ID 999).
-- ERRO ESPERADO: "Ordem de servico inexistente."
CALL adicionar_responsavel('Diretor Fantasma', '1980-01-01', 999, '910000000', 'fantasma@hospital.pt');


-- ------------------------------------------------------------
-- 9. adicionar_tecnico
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Adicionar o técnico e o respetivo contacto com sucesso.
CALL adicionar_tecnico('2020-01-01', 'João Mecânico', 'Mecânica Fina', '919999888', 'joao.mec@empresa.pt');

-- CASO DE ERRO: Tentar inserir um técnico sem nome (NULL viola a constraint de NOT NULL da tabela Tecnico).
-- ERRO ESPERADO: Error Code: 1048. Column 'nome' cannot be null.
CALL adicionar_tecnico('2020-01-01', NULL, 'Mecânica Fina', '919999888', 'joao.mec2@empresa.pt');


-- ------------------------------------------------------------
-- 10. adicionar_peca
-- ------------------------------------------------------------
-- CASO DE SUCESSO: Adicionar uma peça com preço válido.
CALL adicionar_peca(45.50, 'Sensor de Temperatura', '2028-12-31');

-- CASO DE ERRO: Tentar adicionar uma peça com preço negativo.
-- ERRO ESPERADO: "Preco invalido."
CALL adicionar_peca(-10.00, 'Peça Defeituosa', '2028-12-31');


-- ------------------------------------------------------------
-- 11. abater_pecas
-- ------------------------------------------------------------
-- PREPARAÇÃO: Inserir manualmente uma peça com garantia já expirada (no passado) para que o script a possa abater.
INSERT INTO `Peca` (`preco`, `designacao`, `garantia`) VALUES (10.00, 'Peça Obsoleta', '2020-01-01');

CALL abater_pecas();

-- ============================================================
--   TESTES FUNCTIONS
-- ============================================================

-- Teste Função 1: calcular_idade_equipamento
SELECT id_equipamento, designacao, calcular_idade_equipamento(id_equipamento) AS idade_anos 
FROM Equipamento LIMIT 3;

-- Teste Função 2: calcular_duracao_manutencao
SELECT id_manutencao, data_inicio, data_fim, calcular_duracao_manutencao(id_manutencao) AS duracao_dias 
FROM Manutencao WHERE data_fim IS NOT NULL LIMIT 3;

-- Teste Função 3: calcular_experiencia_tecnico
SELECT id_tecnico, nome, calcular_experiencia_tecnico(id_tecnico) AS experiencia_anos 
FROM Tecnico LIMIT 3;

-- Teste Função 4: equipamento_tem_manutencao_ativa
SELECT id_equipamento, designacao, equipamento_tem_manutencao_ativa(id_equipamento) AS ativa 
FROM Equipamento LIMIT 3;

-- Teste Função 5: obter_localizacao_equipamento
SELECT id_equipamento, obter_localizacao_equipamento(id_equipamento) AS localizacao 
FROM Equipamento LIMIT 3;

-- Teste Função 6: custo_total_manutencoes
SELECT id_equipamento, custo_total_manutencoes(id_equipamento) AS custo_total 
FROM Equipamento LIMIT 3;

-- ============================================================
--   TESTES VIEWS
-- ============================================================

-- Teste View 1: Custo total por equipamento
SELECT * FROM vw_custo_total_equipamento LIMIT 3;

-- Teste View 2: Garantia das peças
SELECT * FROM vw_garantia_pecas LIMIT 3;

-- Teste View 3: Rastreabilidade
SELECT * FROM vw_rastreabilidade_intervencoes LIMIT 3;

-- Teste View 4: Downtime
SELECT * FROM vw_downtime_equipamentos LIMIT 3;

-- Teste View 5: Localização
SELECT * FROM vw_localizacao_equipamentos LIMIT 3;

-- Teste View 6: Ordens abertas
SELECT * FROM vw_ordens_abertas LIMIT 3;

-- Teste View 7: Resumo de técnicos
SELECT * FROM vw_tecnico_resumo LIMIT 3;

-- Teste View 8: Custos por departamento
SELECT * FROM vw_custos_por_departamento LIMIT 3;