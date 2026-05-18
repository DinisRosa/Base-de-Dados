USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `adicionar_tecnico`;

DELIMITER $$

CREATE PROCEDURE `adicionar_tecnico`(
    IN p_data_inicio_carreira VARCHAR(45),
    IN p_nome VARCHAR(45),
    IN p_especialidade VARCHAR(45),
    IN p_telefone VARCHAR(15),
    IN p_email VARCHAR(45)
)
BEGIN
    DECLARE v_tecnico_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO `tecnico` (`data_inicio_carreira`, `nome`, `especialidade`)
    VALUES (p_data_inicio_carreira, p_nome, p_especialidade);

    SET v_tecnico_id = LAST_INSERT_ID();

    INSERT INTO `contacto_tecnico` (`telefone`, `email`, `tecnico_id`)
    VALUES (p_telefone, p_email, v_tecnico_id);

    COMMIT;

    SELECT v_tecnico_id AS tecnico_id, 'Tecnico e contacto criados.' AS mensagem;
END$$

DELIMITER ;

