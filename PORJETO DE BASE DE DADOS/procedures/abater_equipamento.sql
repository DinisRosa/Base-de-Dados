USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `abater_equipamento`;

DELIMITER $$

CREATE PROCEDURE `abater_equipamento`(
    IN p_equipamento_id INT
)
BEGIN
    DECLARE v_exists INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO v_exists
    FROM `equipamento`
    WHERE `id` = p_equipamento_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Equipamento inexistente.';
    END IF;

    START TRANSACTION;

    UPDATE `equipamento`
    SET `estado` = 'Inativo'
    WHERE `id` = p_equipamento_id;

    UPDATE `ordem_servico` os
    JOIN `manutencao` m ON m.`id` = os.`manutencao_id`
    SET os.`estado_atual` = 'Cancelada'
    WHERE m.`equipamento_id` = p_equipamento_id
      AND os.`estado_atual` IN ('Pendente', 'Em Execucao');

    COMMIT;
END$$

DELIMITER ;

