USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `adicionar_intervencao_tecnico`;

DELIMITER $$

CREATE PROCEDURE `adicionar_intervencao_tecnico`(
    IN p_tecnico_id INT,
    IN p_manutencao_id INT,
    IN p_cargo VARCHAR(45),
    IN p_horas_trabalho INT,
    IN p_mudar_ordem_execucao TINYINT
)
BEGIN
    DECLARE v_exists INT;
    DECLARE v_intervencao_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_horas_trabalho <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Horas de trabalho tem de ser maior que zero.';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM `tecnico`
    WHERE `id` = p_tecnico_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tecnico inexistente.';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM `manutencao`
    WHERE `id` = p_manutencao_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Manutencao inexistente.';
    END IF;

    START TRANSACTION;

    INSERT INTO `intervencao_tecnico` (`cargo`, `horas_trabalho`, `tecnico_id`, `manutencao_id`)
    VALUES (p_cargo, p_horas_trabalho, p_tecnico_id, p_manutencao_id);

    SET v_intervencao_id = LAST_INSERT_ID();

    IF p_mudar_ordem_execucao = 1 THEN
        UPDATE `ordem_servico`
        SET `estado_atual` = 'Em Execucao'
        WHERE `manutencao_id` = p_manutencao_id
          AND `estado_atual` = 'Pendente';
    END IF;

    COMMIT;

    SELECT v_intervencao_id AS intervencao_id, 'Intervencao registada.' AS mensagem;
END$$

DELIMITER ;

