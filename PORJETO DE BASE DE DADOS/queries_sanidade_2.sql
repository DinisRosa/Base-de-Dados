-- Queries de sanidade 2: testes funcionais de procedures (mydb_uniforme)
USE `mydb_uniforme`;

-- Identificadores unicos para esta execucao
SET @tag = DATE_FORMAT(NOW(6), '%Y%m%d%H%i%s%f');
SET @nome_peca_teste = CONCAT('SAN_Peca_', @tag);
SET @nome_peca_expirada = CONCAT('SAN_Peca_Expirada_', @tag);
SET @nome_tecnico_teste = CONCAT('SAN_Tecnico_', @tag);
SET @email_tecnico_teste = CONCAT('san.tecnico.', @tag, '@mail.test');
SET @nome_responsavel_teste = CONCAT('SAN_Responsavel_', @tag);
SET @email_responsavel_teste = CONCAT('san.responsavel.', @tag, '@mail.test');
SET @desc_manutencao_aberta = CONCAT('SAN_Abertura_', @tag);
SET @desc_avaria = CONCAT('SAN_Avaria_', @tag);

-- 1) adicionar_peca (peca de teste)
CALL `adicionar_peca`(99.90, @nome_peca_teste, DATE_ADD(CURDATE(), INTERVAL 365 DAY));
SELECT id INTO @peca_teste_id
FROM `peca`
WHERE `designacao` = @nome_peca_teste COLLATE utf8mb4_0900_ai_ci
ORDER BY id DESC
LIMIT 1;
SELECT 'T1_adicionar_peca' AS teste, @peca_teste_id AS peca_id_criada;

-- 2) adicionar_peca (peca expirada sem uso para teste de abater_pecas)
CALL `adicionar_peca`(5.00, @nome_peca_expirada, DATE_SUB(CURDATE(), INTERVAL 30 DAY));
SELECT id INTO @peca_expirada_id
FROM `peca`
WHERE `designacao` = @nome_peca_expirada COLLATE utf8mb4_0900_ai_ci
ORDER BY id DESC
LIMIT 1;
SELECT 'T2_peca_expirada_criada' AS teste, @peca_expirada_id AS peca_expirada_id;

-- 3) adicionar_tecnico
CALL `adicionar_tecnico`('2022-01-10', @nome_tecnico_teste, 'Geral', '930000001', @email_tecnico_teste);
SELECT id INTO @tecnico_teste_id
FROM `tecnico`
WHERE `nome` = @nome_tecnico_teste COLLATE utf8mb4_0900_ai_ci
ORDER BY id DESC
LIMIT 1;
SELECT 'T3_adicionar_tecnico' AS teste, @tecnico_teste_id AS tecnico_id_criado;

-- 4) abrir_manutencao
CALL `abrir_manutencao`(1, @peca_teste_id, 'Preventiva', 120.00, @desc_manutencao_aberta, 'Media');
SELECT m.id INTO @manutencao_aberta_id
FROM `manutencao` m
WHERE m.`equipamento_id` = 1
  AND m.`peca_id` = @peca_teste_id
  AND m.`descricao` = @desc_manutencao_aberta COLLATE utf8mb4_0900_ai_ci
  AND m.`data_fim` IS NULL
ORDER BY m.id DESC
LIMIT 1;
SELECT os.id INTO @ordem_aberta_id
FROM `ordem_servico` os
WHERE os.`manutencao_id` = @manutencao_aberta_id
ORDER BY os.id DESC
LIMIT 1;
SELECT 'T4_abrir_manutencao' AS teste, @manutencao_aberta_id AS manutencao_id, @ordem_aberta_id AS ordem_id;

-- 5) alterar_prioridade_ordem
CALL `alterar_prioridade_ordem`(@ordem_aberta_id, 'Alta');
SELECT 'T5_alterar_prioridade_ordem' AS teste, `id`, `prioridade`
FROM `ordem_servico`
WHERE `id` = @ordem_aberta_id;

-- 6) validar_estado_ordem (Pendente -> Em Execucao)
CALL `validar_estado_ordem`(@ordem_aberta_id, 'Em Execucao');
SELECT 'T6_validar_estado_ordem' AS teste, `id`, `estado_atual`
FROM `ordem_servico`
WHERE `id` = @ordem_aberta_id;

-- 7) adicionar_intervencao_tecnico
CALL `adicionar_intervencao_tecnico`(@tecnico_teste_id, @manutencao_aberta_id, 'Tecnico de Teste', 3, 0);
SELECT 'T7_adicionar_intervencao_tecnico' AS teste, COUNT(*) AS total_intervencoes
FROM `intervencao_tecnico`
WHERE `tecnico_id` = @tecnico_teste_id
  AND `manutencao_id` = @manutencao_aberta_id;

-- 8) concluir_manutencao
CALL `concluir_manutencao`(@manutencao_aberta_id);
SELECT 'T8_concluir_manutencao' AS teste, m.`id`, m.`data_fim`, os.`estado_atual` AS estado_ordem
FROM `manutencao` m
JOIN `ordem_servico` os ON os.`manutencao_id` = m.`id`
WHERE m.`id` = @manutencao_aberta_id;
SELECT 'T8_equipamento_operacional' AS teste, `id`, `estado`
FROM `equipamento`
WHERE `id` = 1;

-- 9) registar_avaria
CALL `registar_avaria`(2, @peca_teste_id, 'Corretiva', 250.00, @desc_avaria, 'Alta');
SELECT m.id INTO @manutencao_avaria_id
FROM `manutencao` m
WHERE m.`equipamento_id` = 2
  AND m.`peca_id` = @peca_teste_id
  AND m.`descricao` = @desc_avaria COLLATE utf8mb4_0900_ai_ci
  AND m.`data_fim` IS NULL
ORDER BY m.id DESC
LIMIT 1;
SELECT os.id INTO @ordem_avaria_id
FROM `ordem_servico` os
WHERE os.`manutencao_id` = @manutencao_avaria_id
ORDER BY os.id DESC
LIMIT 1;
SELECT 'T9_registar_avaria' AS teste, @manutencao_avaria_id AS manutencao_id, @ordem_avaria_id AS ordem_id;
SELECT 'T9_equipamento_em_manutencao' AS teste, `id`, `estado`
FROM `equipamento`
WHERE `id` = 2;

-- 10) adicionar_responsavel (usa ordem criada em T9)
CALL `adicionar_responsavel`(@nome_responsavel_teste, '1988-01-01', @ordem_avaria_id, '910000002', @email_teste);
SELECT 'T10_adicionar_responsavel' AS teste, r.`id`, r.`nome`, cr.`email`
FROM `responsavel` r
JOIN `contacto_responsavel` cr ON cr.`responsavel_id` = r.`id`
WHERE r.`nome` = @nome_responsavel_teste COLLATE utf8mb4_0900_ai_ci
ORDER BY r.`id` DESC
LIMIT 1;

-- 11) abater_equipamento (cancela ordens pendentes/em execucao do equipamento)
CALL `abater_equipamento`(2);
SELECT 'T11_abater_equipamento_estado' AS teste, `id`, `estado`
FROM `equipamento`
WHERE `id` = 2;
SELECT 'T11_ordem_cancelada' AS teste, `id`, `estado_atual`
FROM `ordem_servico`
WHERE `id` = @ordem_avaria_id;

-- 12) listar_alertas (deve devolver 3 result sets)
CALL `listar_alertas`(1, 1);

-- 13) abater_pecas (remove pecas com garantia expirada e sem uso)
SELECT 'T13_pre_abater_pecas' AS teste, COUNT(*) AS total
FROM `peca`
WHERE `id` = @peca_expirada_id;
CALL `abater_pecas`();
SELECT 'T13_pos_abater_pecas' AS teste, COUNT(*) AS total
FROM `peca`
WHERE `id` = @peca_expirada_id;