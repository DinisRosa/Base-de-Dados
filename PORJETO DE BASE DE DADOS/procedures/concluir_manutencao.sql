USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `concluir_manutencao`;

DELIMITER $$

CREATE PROCEDURE `concluir_manutencao`(
    IN p_manutencao_id INT
)
BEGIN
    DECLARE v_equipamento_id INT;
    DECLARE v_data_fim DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT `equipamento_id`, `data_fim`
    INTO v_equipamento_id, v_data_fim
    FROM `manutencao`
    WHERE `id` = p_manutencao_id;

    IF v_equipamento_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Manutencao inexistente.';
    END IF;

    IF v_data_fim IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Manutencao ja concluida.';
    END IF;

    START TRANSACTION;

    -- 1. Fecha a manutencao na data atual
    UPDATE `manutencao`
    SET `data_fim` = CURDATE()
    WHERE `id` = p_manutencao_id;

    -- 2. Fecha a(s) ordem(ns) de servico associada(s)
    UPDATE `ordem_servico`
    SET `estado_atual` = 'Concluida'
    WHERE `manutencao_id` = p_manutencao_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ordem de servico inexistente para a manutencao.';
    END IF;

    -- 3. Volta o equipamento para operacional
    UPDATE `equipamento`
    SET `estado` = 'Operacional'
    WHERE `id` = v_equipamento_id;

    COMMIT;
END$$

DELIMITER ;

-- Exemplo de uso (executar manualmente, se necessário):
-- CALL `concluir_manutencao`(2);
