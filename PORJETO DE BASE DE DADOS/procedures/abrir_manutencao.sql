USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `abrir_manutencao`;

DELIMITER $$

CREATE PROCEDURE `abrir_manutencao`(
    IN p_equipamento_id INT,
    IN p_peca_id INT,
    IN p_tipo_manutencao VARCHAR(45),
    IN p_custo_estimado DECIMAL(10,2),
    IN p_descricao VARCHAR(45),
    IN p_prioridade VARCHAR(45)
)
BEGIN
    DECLARE v_exists INT;
    DECLARE v_manutencao_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_prioridade NOT IN ('Baixa', 'Media', 'Alta') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prioridade invalida. Valores permitidos: Baixa, Media, Alta.';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM `equipamento`
    WHERE `id` = p_equipamento_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Equipamento inexistente.';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM `peca`
    WHERE `id` = p_peca_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Peca inexistente.';
    END IF;

    START TRANSACTION;

    INSERT INTO `manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `peca_id`, `equipamento_id`)
    VALUES (p_custo_estimado, p_tipo_manutencao, p_descricao, CURDATE(), p_peca_id, p_equipamento_id);

    SET v_manutencao_id = LAST_INSERT_ID();

    INSERT INTO `ordem_servico` (`descricao`, `estado_atual`, `prioridade`, `manutencao_id`)
    VALUES (p_descricao, 'Pendente', p_prioridade, v_manutencao_id);

    UPDATE `equipamento`
    SET `estado` = 'Em Manutencao'
    WHERE `id` = p_equipamento_id;

    COMMIT;

    SELECT v_manutencao_id AS manutencao_id, 'Manutencao aberta.' AS mensagem;
END$$

DELIMITER ;

