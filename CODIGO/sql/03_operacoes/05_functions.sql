-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 05: Functions
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: mod_conceptual_novas_modificacoes (versão revista - Novas Modificações)
-- ============================================================

USE gestao_equipamentos;

DELIMITER $$

-- ============================================================
-- FN 1: Calcular idade do equipamento em anos (atributo derivado)
-- ============================================================
DROP FUNCTION IF EXISTS fn_calcular_idade_equipamento $$
CREATE FUNCTION fn_calcular_idade_equipamento(p_id_equipamento INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_data DATE;
    SELECT data_aquisicao INTO v_data FROM EQUIPAMENTO WHERE id_equipamento = p_id_equipamento;
    IF v_data IS NULL THEN RETURN NULL; END IF;
    RETURN TIMESTAMPDIFF(YEAR, v_data, CURDATE());
END $$

-- ============================================================
-- FN 2: Calcular anos de experiência do técnico
-- Agora também considera o campo anos_experiencia da tabela
-- ============================================================
DROP FUNCTION IF EXISTS fn_calcular_anos_experiencia $$
CREATE FUNCTION fn_calcular_anos_experiencia(p_id_tecnico INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_data DATE;
    DECLARE v_anos_config INT;
    SELECT data_inicio_carreira, anos_experiencia INTO v_data, v_anos_config 
    FROM TECNICO WHERE id_tecnico = p_id_tecnico;
    IF v_data IS NULL THEN RETURN NULL; END IF;
    -- Se configurado na tabela, usar esse valor; senão calcular
    IF v_anos_config > 0 THEN
        RETURN v_anos_config;
    ELSE
        RETURN TIMESTAMPDIFF(YEAR, v_data, CURDATE());
    END IF;
END $$

-- ============================================================
-- FN 3: Calcular duração de uma manutenção em dias (atributo derivado)
-- Agora também considera o campo duracao da tabela
-- ============================================================
DROP FUNCTION IF EXISTS fn_calcular_duracao_manutencao $$
CREATE FUNCTION fn_calcular_duracao_manutencao(p_id_manutencao INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_inicio DATE;
    DECLARE v_fim    DATE;
    DECLARE v_duracao INT;
    SELECT data_inicio, data_fim, duracao INTO v_inicio, v_fim, v_duracao
    FROM MANUTENCAO WHERE id_manutencao = p_id_manutencao;
    IF v_duracao > 0 THEN
        RETURN v_duracao;
    ELSEIF v_fim IS NULL THEN
        RETURN NULL;
    ELSE
        RETURN DATEDIFF(v_fim, v_inicio);
    END IF;
END $$

-- ============================================================
-- FN 4: Custo total de todas as manutenções de um equipamento
-- ============================================================
DROP FUNCTION IF EXISTS fn_custo_total_manutencoes $$
CREATE FUNCTION fn_custo_total_manutencoes(p_id_equipamento INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT COALESCE(SUM(custo), 0.00) INTO v_total
    FROM MANUTENCAO WHERE id_equipamento = p_id_equipamento;
    RETURN v_total;
END $$

-- ============================================================
-- FN 5: Contar intervenções realizadas por um técnico
-- ============================================================
DROP FUNCTION IF EXISTS fn_contar_intervencoes_tecnico $$
CREATE FUNCTION fn_contar_intervencoes_tecnico(p_id_tecnico INT)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total
    FROM INTERVENCAO_TECNICO WHERE id_tecnico = p_id_tecnico;
    RETURN v_total;
END $$

-- ============================================================
-- FN 6: Verificar se um equipamento está atualmente em manutenção
-- Retorna 1 (sim) ou 0 (não)
-- ============================================================
DROP FUNCTION IF EXISTS fn_equipamento_em_manutencao $$
CREATE FUNCTION fn_equipamento_em_manutencao(p_id_equipamento INT)
RETURNS TINYINT(1)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM MANUTENCAO
    WHERE id_equipamento = p_id_equipamento AND data_fim IS NULL;
    RETURN IF(v_count > 0, 1, 0);
END $$

-- ============================================================
-- FN 7: Calcular horas totais de trabalho em manutencoes de um tecnico
-- ============================================================
DROP FUNCTION IF EXISTS fn_total_horas_tecnico $$
CREATE FUNCTION fn_total_horas_tecnico(p_id_tecnico INT)
RETURNS DECIMAL(8,1)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(8,1);
    SELECT COALESCE(SUM(horas_trabalho), 0.0) INTO v_total
    FROM INTERVENCAO_TECNICO WHERE id_tecnico = p_id_tecnico;
    RETURN v_total;
END $$

-- ============================================================
-- FN 8: Calcular custo total de peças usadas numa manutenção
-- ============================================================
DROP FUNCTION IF EXISTS fn_custo_pecas_manutencao $$
CREATE FUNCTION fn_custo_pecas_manutencao(p_id_manutencao INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT COALESCE(SUM(mp.quantidade * p.custo), 0.00) INTO v_total
    FROM MANUTENCAO_PECA mp
    JOIN PECA p ON mp.id_peca = p.id_peca
    WHERE mp.id_manutencao = p_id_manutencao;
    RETURN v_total;
END $$

DELIMITER ;

-- ============================================================
-- Exemplos de chamada:
-- SELECT fn_calcular_idade_equipamento(1);
-- SELECT fn_calcular_anos_experiencia(1);
-- SELECT fn_calcular_duracao_manutencao(1);
-- SELECT fn_custo_total_manutencoes(2);
-- SELECT fn_contar_intervencoes_tecnico(1);
-- SELECT fn_equipamento_em_manutencao(2);
-- SELECT fn_total_horas_tecnico(1);
-- SELECT fn_custo_pecas_manutencao(1);
-- ============================================================

-- ============================================================
-- FIM DO FICHEIRO 05_functions.sql
-- ============================================================
