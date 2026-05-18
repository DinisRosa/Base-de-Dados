-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 05: Functions
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: modelo fisico.sql (Montana)
-- ============================================================

USE `mydb`;

DELIMITER $$

-- ============================================================
-- FN 1: Calcular idade do equipamento em anos (atributo derivado)
-- ============================================================
DROP FUNCTION IF EXISTS fn_calcular_idade_equipamento $$
CREATE FUNCTION fn_calcular_idade_equipamento(p_idEquipamento INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_data DATE;
    SELECT `data_aquisicao` INTO v_data
    FROM `Equipamento` WHERE `idEquipamento` = p_idEquipamento;
    IF v_data IS NULL THEN RETURN NULL; END IF;
    RETURN TIMESTAMPDIFF(YEAR, v_data, CURDATE());
END $$

-- ============================================================
-- FN 2: Calcular anos de carreira de um técnico
-- ============================================================
DROP FUNCTION IF EXISTS fn_calcular_anos_carreira $$
CREATE FUNCTION fn_calcular_anos_carreira(p_idTecnico INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_data VARCHAR(45);
    SELECT `data_início_carreira` INTO v_data
    FROM `Tecnico` WHERE `idTecnico` = p_idTecnico;
    IF v_data IS NULL THEN RETURN NULL; END IF;
    RETURN TIMESTAMPDIFF(YEAR, STR_TO_DATE(v_data, '%Y-%m-%d'), CURDATE());
END $$

-- ============================================================
-- FN 3: Calcular duração de uma manutenção em dias
-- ============================================================
DROP FUNCTION IF EXISTS fn_calcular_duracao_manutencao $$
CREATE FUNCTION fn_calcular_duracao_manutencao(p_id_manutencao INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_inicio DATE;
    DECLARE v_fim    DATE;
    SELECT `data_inicio`, `data_fim` INTO v_inicio, v_fim
    FROM `Manutencao` WHERE `id_manutencao` = p_id_manutencao;
    IF v_inicio IS NULL OR v_fim IS NULL THEN RETURN NULL; END IF;
    RETURN DATEDIFF(v_fim, v_inicio);
END $$

-- ============================================================
-- FN 4: Custo total das manutenções de um equipamento
-- ============================================================
DROP FUNCTION IF EXISTS fn_custo_total_manutencoes $$
CREATE FUNCTION fn_custo_total_manutencoes(p_idEquipamento INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT COALESCE(SUM(`custo`), 0.00) INTO v_total
    FROM `Manutencao` WHERE `Equipamento_idEquipamento` = p_idEquipamento;
    RETURN v_total;
END $$

-- ============================================================
-- FN 5: Contar intervenções realizadas por um técnico
-- ============================================================
DROP FUNCTION IF EXISTS fn_contar_intervencoes_tecnico $$
CREATE FUNCTION fn_contar_intervencoes_tecnico(p_idTecnico INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total
    FROM `Intervencao_Tecnico` WHERE `Tecnico_idTecnico` = p_idTecnico;
    RETURN v_total;
END $$

-- ============================================================
-- FN 6: Verificar se equipamento está em manutenção ativa
-- Retorna 1 (sim) ou 0 (não) — baseado no campo estado
-- ============================================================
DROP FUNCTION IF EXISTS fn_equipamento_em_manutencao $$
CREATE FUNCTION fn_equipamento_em_manutencao(p_idEquipamento INT)
RETURNS TINYINT(1)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_estado VARCHAR(45);
    SELECT `estado` INTO v_estado
    FROM `Equipamento` WHERE `idEquipamento` = p_idEquipamento;
    RETURN IF(v_estado = 'Em Manutenção', 1, 0);
END $$

-- ============================================================
-- FN 7: Total de horas de trabalho de um técnico
-- ============================================================
DROP FUNCTION IF EXISTS fn_total_horas_tecnico $$
CREATE FUNCTION fn_total_horas_tecnico(p_idTecnico INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COALESCE(SUM(`horas_trabalho`), 0) INTO v_total
    FROM `Intervencao_Tecnico` WHERE `Tecnico_idTecnico` = p_idTecnico;
    RETURN v_total;
END $$

-- ============================================================
-- FN 8: Custo total de peças usadas numa manutenção
-- (Peca ligada diretamente a Manutencao por FK)
-- ============================================================
DROP FUNCTION IF EXISTS fn_preco_peca_manutencao $$
CREATE FUNCTION fn_preco_peca_manutencao(p_id_manutencao INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    SELECT p.`preco` INTO v_preco
    FROM `Manutencao` m
    JOIN `Peca` p ON m.`Peca_idPeca` = p.`idPeca`
    WHERE m.`id_manutencao` = p_id_manutencao;
    RETURN COALESCE(v_preco, 0.00);
END $$

DELIMITER ;

-- ============================================================
-- Exemplos de chamada:
-- SELECT fn_calcular_idade_equipamento(1);
-- SELECT fn_calcular_anos_carreira(1);
-- SELECT fn_calcular_duracao_manutencao(1);
-- SELECT fn_custo_total_manutencoes(1);
-- SELECT fn_contar_intervencoes_tecnico(1);
-- SELECT fn_equipamento_em_manutencao(1);
-- SELECT fn_total_horas_tecnico(1);
-- SELECT fn_preco_peca_manutencao(1);
-- ============================================================

-- ============================================================
-- FIM DO FICHEIRO 05_functions.sql
-- ============================================================
