USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `adicionar_responsavel`;

DELIMITER $$

CREATE PROCEDURE `adicionar_responsavel`(
    IN p_nome VARCHAR(45),
    IN p_data_nascimento DATE,
    IN p_ordem_servico_id INT,
    IN p_telefone VARCHAR(45),
    IN p_email VARCHAR(45)
)
BEGIN
    DECLARE v_exists INT;
    DECLARE v_responsavel_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO v_exists
    FROM `ordem_servico`
    WHERE `id` = p_ordem_servico_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
    END IF;

    START TRANSACTION;

    INSERT INTO `responsavel` (`nome`, `data_nascimento`, `ordem_servico_id`)
    VALUES (p_nome, p_data_nascimento, p_ordem_servico_id);

    SET v_responsavel_id = LAST_INSERT_ID();

    INSERT INTO `contacto_responsavel` (`telefone`, `email`, `responsavel_id`)
    VALUES (p_telefone, p_email, v_responsavel_id);

    COMMIT;

    SELECT v_responsavel_id AS responsavel_id, 'Responsavel e contacto criados.' AS mensagem;
END$$

DELIMITER ;

