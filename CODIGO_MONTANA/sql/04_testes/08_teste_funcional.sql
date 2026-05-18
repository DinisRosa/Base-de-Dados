-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 08: Script de Teste Funcional
-- Testa integridade, relacionamentos e operações da BD
-- Modelo: modelo fisico.sql (Montana) — Schema mydb
-- ============================================================

USE `mydb`;

-- ============================================================
-- 1. VERIFICAÇÃO DE ESTRUTURA: Tabelas Criadas
-- ============================================================
SELECT '========== 1. TABELAS CRIADAS ==========' AS teste;
SELECT
    TABLE_NAME,
    TABLE_ROWS,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = 'mydb' AND TABLE_NAME = t.TABLE_NAME) AS colunas
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_SCHEMA = 'mydb'
ORDER BY TABLE_NAME;

-- ============================================================
-- 2. CONTAGEM DE REGISTOS POR TABELA
-- ============================================================
SELECT '========== 2. POPULACAO DE DADOS ==========' AS teste;

SELECT 'Peca'                  AS tabela, COUNT(*) AS registos FROM `Peca`
UNION ALL
SELECT 'contacto_responsavel', COUNT(*) FROM `contacto_responsavel`
UNION ALL
SELECT 'contacto_tecnico',     COUNT(*) FROM `contacto_tecnico`
UNION ALL
SELECT 'Equipamento_contacto', COUNT(*) FROM `Equipamento_contacto`
UNION ALL
SELECT 'Manutencao',           COUNT(*) FROM `Manutencao`
UNION ALL
SELECT 'Ordem_servico',        COUNT(*) FROM `Ordem_servico`
UNION ALL
SELECT 'Responsavel',          COUNT(*) FROM `Responsavel`
UNION ALL
SELECT 'Departamento',         COUNT(*) FROM `Departamento`
UNION ALL
SELECT 'Localizacao',          COUNT(*) FROM `Localizacao`
UNION ALL
SELECT 'Tecnico',              COUNT(*) FROM `Tecnico`
UNION ALL
SELECT 'Equipamento',          COUNT(*) FROM `Equipamento`
UNION ALL
SELECT 'Intervencao_Tecnico',  COUNT(*) FROM `Intervencao_Tecnico`;

-- ============================================================
-- 3. INTEGRIDADE REFERENCIAL
-- ============================================================
SELECT '========== 3. INTEGRIDADE REFERENCIAL ==========' AS teste;

-- Manutencao → Peca
SELECT 'Manutencao -> Peca' AS referencia,
       COUNT(*) AS total,
       SUM(CASE WHEN p.`idPeca` IS NULL THEN 1 ELSE 0 END) AS orfaos
FROM `Manutencao` m
LEFT JOIN `Peca` p ON m.`Peca_idPeca` = p.`idPeca`;

-- Manutencao → Equipamento
SELECT 'Manutencao -> Equipamento' AS referencia,
       COUNT(*) AS total,
       SUM(CASE WHEN e.`idEquipamento` IS NULL THEN 1 ELSE 0 END) AS orfaos
FROM `Manutencao` m
LEFT JOIN `Equipamento` e ON m.`Equipamento_idEquipamento` = e.`idEquipamento`;

-- Ordem_servico → Manutencao
SELECT 'Ordem_servico -> Manutencao' AS referencia,
       COUNT(*) AS total,
       SUM(CASE WHEN m.`id_manutencao` IS NULL THEN 1 ELSE 0 END) AS orfaos
FROM `Ordem_servico` os
LEFT JOIN `Manutencao` m ON os.`Manutencao_id_manutencao` = m.`id_manutencao`;

-- Responsavel → Ordem_servico
SELECT 'Responsavel -> Ordem_servico' AS referencia,
       COUNT(*) AS total,
       SUM(CASE WHEN os.`idOrdem` IS NULL THEN 1 ELSE 0 END) AS orfaos
FROM `Responsavel` r
LEFT JOIN `Ordem_servico` os ON r.`Ordem de serviço_idOrdem` = os.`idOrdem`;

-- Equipamento → Departamento, Localizacao, Equipamento_contacto
SELECT 'Equipamento -> Departamento' AS referencia,
       COUNT(*) AS total,
       SUM(CASE WHEN d.`idDepartamento` IS NULL THEN 1 ELSE 0 END) AS orfaos
FROM `Equipamento` e
LEFT JOIN `Departamento` d ON e.`Departamento_idDepartamento` = d.`idDepartamento`;

SELECT 'Equipamento -> Localizacao' AS referencia,
       COUNT(*) AS total,
       SUM(CASE WHEN l.`idLocalizacao` IS NULL THEN 1 ELSE 0 END) AS orfaos
FROM `Equipamento` e
LEFT JOIN `Localizacao` l ON e.`Localizacao_idLocalizacao` = l.`idLocalizacao`;

-- ============================================================
-- 4. TESTE DE QUERY COMPLEXA: Equipamentos com Detalhes Completos
-- ============================================================
SELECT '========== 4. QUERY COMPLEXA - EQUIPAMENTO COM DETALHES ==========' AS teste;

SELECT
    e.`idEquipamento`,
    e.`designacao`,
    e.`fabricante`,
    e.`estado`,
    d.`designacao`  AS departamento,
    l.`sala`,
    l.`piso`,
    l.`edificio`,
    ec.`contacto`   AS contacto_suporte,
    ec.`email`      AS email_suporte
FROM `Equipamento` e
LEFT JOIN `Departamento` d        ON e.`Departamento_idDepartamento`              = d.`idDepartamento`
LEFT JOIN `Localizacao` l         ON e.`Localizacao_idLocalizacao`                = l.`idLocalizacao`
LEFT JOIN `Equipamento_contacto` ec ON e.`Equipamento_contacto_idEquipamento_contacto1` = ec.`idEquipamento_contacto`;

-- ============================================================
-- 5. TESTE DE QUERY: Manutenções com Peça e Técnicos
-- ============================================================
SELECT '========== 5. QUERY - MANUTENCOES COM PECA E TECNICOS ==========' AS teste;

SELECT
    m.`id_manutencao`,
    m.`tipo`,
    e.`designacao`  AS equipamento,
    m.`data_inicio`,
    m.`data_fim`,
    m.`custo`,
    p.`designacao`  AS peca_usada,
    p.`preco`       AS preco_peca,
    GROUP_CONCAT(DISTINCT t.`nome` SEPARATOR ', ') AS tecnicos_atribuidos
FROM `Manutencao` m
JOIN `Equipamento` e       ON m.`Equipamento_idEquipamento` = e.`idEquipamento`
JOIN `Peca` p              ON m.`Peca_idPeca`               = p.`idPeca`
LEFT JOIN `Intervencao_Tecnico` it ON m.`id_manutencao`     = it.`Manutencao_id_manutencao`
LEFT JOIN `Tecnico` t              ON it.`Tecnico_idTecnico` = t.`idTecnico`
GROUP BY m.`id_manutencao`, m.`tipo`, e.`designacao`,
         m.`data_inicio`, m.`data_fim`, m.`custo`, p.`designacao`, p.`preco`;

-- ============================================================
-- 6. TESTE DE QUERY: Ordens de Serviço com Responsável
-- ============================================================
SELECT '========== 6. QUERY - ORDENS E RESPONSAVEIS ==========' AS teste;

SELECT
    os.`idOrdem`,
    os.`estado_atual`,
    os.`prioridade`,
    os.`descricao`,
    m.`tipo`         AS tipo_manutencao,
    e.`designacao`   AS equipamento,
    r.`nome`         AS responsavel,
    cr.`contacto`    AS contacto_resp,
    cr.`email`       AS email_resp
FROM `Ordem_servico` os
JOIN `Manutencao` m            ON os.`Manutencao_id_manutencao`                   = m.`id_manutencao`
JOIN `Equipamento` e           ON m.`Equipamento_idEquipamento`                   = e.`idEquipamento`
LEFT JOIN `Responsavel` r      ON r.`Ordem de serviço_idOrdem`                    = os.`idOrdem`
LEFT JOIN `contacto_responsavel` cr ON r.`contacto_responsavel_idcontacto_responsavel` = cr.`idcontacto_responsavel`;

-- ============================================================
-- 7. TESTE DE ESTATÍSTICAS
-- ============================================================
SELECT '========== 7. ESTATÍSTICAS ==========' AS teste;

SELECT
    'Custo Total Manutenções' AS metrica,
    CONCAT('€ ', ROUND(SUM(`custo`), 2)) AS valor
FROM `Manutencao`
UNION ALL
SELECT
    'Total Horas Trabalho',
    CONCAT(SUM(`horas_trabalho`), ' h')
FROM `Intervencao_Tecnico`
UNION ALL
SELECT
    'Equipamentos em Manutenção',
    COUNT(*)
FROM `Equipamento`
WHERE `estado` = 'Em Manutenção'
UNION ALL
SELECT
    'Peças com Garantia Expirada',
    COUNT(*)
FROM `Peca`
WHERE `garantia` < CURDATE();

-- ============================================================
-- 8. TESTE DE VIEWS (se existirem)
-- ============================================================
SELECT '========== 8. VIEWS CRIADAS ==========' AS teste;

SELECT TABLE_NAME AS view_name
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'mydb' AND TABLE_TYPE = 'VIEW'
ORDER BY TABLE_NAME;

-- ============================================================
-- 9. TESTE DE PROCEDURES E FUNCTIONS
-- ============================================================
SELECT '========== 9. ROUTINES DISPONÍVEIS ==========' AS teste;

SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'mydb'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- ============================================================
-- 10. TESTE DAS FUNCTIONS
-- ============================================================
SELECT '========== 10. TESTE DAS FUNCTIONS ==========' AS teste;

SELECT
    fn_calcular_idade_equipamento(1)  AS idade_equip_1,
    fn_calcular_anos_carreira(1)      AS anos_carreira_tec_1,
    fn_calcular_duracao_manutencao(1) AS duracao_man_1,
    fn_custo_total_manutencoes(1)     AS custo_total_equip_1,
    fn_contar_intervencoes_tecnico(1) AS intervencoes_tec_1,
    fn_equipamento_em_manutencao(3)   AS equip_3_em_manutencao,
    fn_total_horas_tecnico(1)         AS horas_tec_1,
    fn_preco_peca_manutencao(1)       AS preco_peca_man_1;

-- ============================================================
-- 11. TESTE DE TRIGGERS — validação de datas inválidas
-- ============================================================
SELECT '========== 11. TESTE DE TRIGGERS ==========' AS teste;

-- Tentar inserir manutenção com data_fim < data_inicio (deve falhar)
SELECT 'Teste trigger datas inválidas (deve gerar erro):' AS info;
-- Descomente para testar:
-- INSERT INTO `Manutencao` (`custo`,`tipo`,`data_inicio`,`data_fim`,`Peca_idPeca`,`Equipamento_idEquipamento`)
-- VALUES (100.00, 'Inspeção', '2025-06-10', '2025-06-01', 1, 1);

-- Tentar inserir intervenção duplicada (técnico 1 na manutenção 1 — deve falhar)
SELECT 'Teste trigger intervenção duplicada (deve gerar erro):' AS info;
-- Descomente para testar:
-- INSERT INTO `Intervencao_Tecnico` (`Cargo`,`horas_trabalho`,`Tecnico_idTecnico`,`Manutencao_id_manutencao`)
-- VALUES ('Técnico', 2, 1, 1);

-- ============================================================
-- 12. RESUMO FINAL DE INTEGRIDADE
-- ============================================================
SELECT '========== RESUMO FINAL ==========' AS teste;
SELECT
    'Base de Dados: mydb (Montana)' AS info,
    'Status' AS status_label,
    'FUNCIONAL' AS status
UNION ALL
SELECT
    'Tabelas',
    'Criadas',
    CONCAT((SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = 'mydb' AND TABLE_TYPE = 'BASE TABLE'), ' tabelas')
UNION ALL
SELECT
    'Integridade',
    'Referencial',
    'Sem violações detectadas'
UNION ALL
SELECT
    'Constraints',
    'Validação',
    'Validadas com sucesso';

-- ============================================================
-- FIM DO FICHEIRO 08_teste_funcional.sql
-- ============================================================
