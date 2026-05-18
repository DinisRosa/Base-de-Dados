USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `alterar_prioridade_ordem`;

DELIMITER $$

CREATE PROCEDURE `alterar_prioridade_ordem`(
    IN p_ordem_id INT,
    IN p_nova_prioridade VARCHAR(45)
)
BEGIN
    IF p_nova_prioridade NOT IN ('Baixa', 'Media', 'Alta') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prioridade invalida. Valores permitidos: Baixa, Media, Alta.';
    END IF;

    UPDATE `ordem_servico`
    SET `prioridade` = p_nova_prioridade
    WHERE `id` = p_ordem_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
    END IF;
END$$

DELIMITER ;

