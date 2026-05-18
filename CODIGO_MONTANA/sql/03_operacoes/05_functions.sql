-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 03.05: Functions
-- ============================================================

USE `mydb`;

-- ============================================================
-- Function: Calcular Idade do Técnico
-- ============================================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS fn_dias_carreira(
    p_data_inicio_carreira DATE
) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(NOW(), p_data_inicio_carreira);
END$$
DELIMITER ;

-- ============================================================
-- Function: Calcular Dias desde Aquisição
-- ============================================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS fn_dias_desde_aquisicao(
    p_data_aquisicao DATE
) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(NOW(), p_data_aquisicao);
END$$
DELIMITER ;

-- ============================================================
-- Function: Obter Status Equipamento com Código
-- ============================================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS fn_status_equipamento_codigo(
    p_estado VARCHAR(45)
) RETURNS CHAR(1)
DETERMINISTIC
BEGIN
    DECLARE v_codigo CHAR(1);
    CASE p_estado
        WHEN 'Operacional' THEN SET v_codigo = 'O';
        WHEN 'Manutenção Preventiva' THEN SET v_codigo = 'P';
        WHEN 'Manutenção Corretiva' THEN SET v_codigo = 'C';
        WHEN 'Inativo' THEN SET v_codigo = 'I';
        ELSE SET v_codigo = 'X';
    END CASE;
    RETURN v_codigo;
END$$
DELIMITER ;

-- ============================================================
-- Function: Calcular Custo Médio de Manutenção por Equipamento
-- ============================================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS fn_custo_medio_manutencao(
    p_equipamento_id INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_custo_medio DECIMAL(10,2);
    SELECT COALESCE(AVG(`custo`), 0) INTO v_custo_medio
    FROM `Manutencao`
    WHERE `Equipamento_idEquipamento` = p_equipamento_id;
    RETURN v_custo_medio;
END$$
DELIMITER ;

-- ============================================================
-- Function: Dias sem Manutenção
-- ============================================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS fn_dias_sem_manutencao(
    p_equipamento_id INT
) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_dias INT;
    SELECT COALESCE(
        DATEDIFF(NOW(), MAX(`data_fim`)), 
        DATEDIFF(NOW(), `data_aquisicao`)
    ) INTO v_dias
    FROM (
        SELECT 
            MAX(m.`data_fim`) as data_fim,
            e.`data_aquisicao`
        FROM `Manutencao` m
        RIGHT JOIN `Equipamento` e ON m.`Equipamento_idEquipamento` = e.`idEquipamento`
        WHERE e.`idEquipamento` = p_equipamento_id
        LIMIT 1
    ) as t;
    RETURN COALESCE(v_dias, 0);
END$$
DELIMITER ;

-- ============================================================
-- Function: Verificar se Equipamento precisa Manutenção Preventiva
-- ============================================================
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS fn_necessita_manutencao_preventiva(
    p_equipamento_id INT,
    p_intervalo_dias INT
) RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_dias_sem_manutencao INT;
    SET v_dias_sem_manutencao = fn_dias_sem_manutencao(p_equipamento_id);
    RETURN IF(v_dias_sem_manutencao >= p_intervalo_dias, TRUE, FALSE);
END$$
DELIMITER ;

-- ============================================================
-- End of Functions
-- ============================================================
