USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `validar_estado_ordem`;

DELIMITER $$

CREATE PROCEDURE `validar_estado_ordem`(
    IN p_ordem_id INT,
    IN p_novo_estado VARCHAR(45)
)
BEGIN
    DECLARE v_estado_atual VARCHAR(45);
    DECLARE v_transicao_valida TINYINT DEFAULT 0;

    IF p_novo_estado NOT IN ('Pendente', 'Em Execucao', 'Concluida', 'Cancelada') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estado invalido.';
    END IF;

    SELECT `estado_atual`
    INTO v_estado_atual
    FROM `ordem_servico`
    WHERE `id` = p_ordem_id;

    IF v_estado_atual IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
    END IF;

    IF v_estado_atual = p_novo_estado THEN
        SET v_transicao_valida = 1;
    ELSEIF v_estado_atual = 'Pendente' AND p_novo_estado IN ('Em Execucao', 'Cancelada') THEN
        SET v_transicao_valida = 1;
    ELSEIF v_estado_atual = 'Em Execucao' AND p_novo_estado IN ('Concluida', 'Cancelada') THEN
        SET v_transicao_valida = 1;
    END IF;

    IF v_transicao_valida = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transicao de estado invalida para a ordem.';
    END IF;

    UPDATE `ordem_servico`
    SET `estado_atual` = p_novo_estado
    WHERE `id` = p_ordem_id;
END$$

DELIMITER ;

