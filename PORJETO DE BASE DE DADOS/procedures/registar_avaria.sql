USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `registar_avaria`;

DELIMITER $$

CREATE PROCEDURE `registar_avaria`(
    IN p_equipamento_id INT,
    IN p_peca_id INT,
    IN p_tipo_manutencao VARCHAR(45),
    IN p_custo_estimado DECIMAL(10,2),
    IN p_descricao VARCHAR(45),
    IN p_prioridade VARCHAR(45)
)
BEGIN
    DECLARE v_manutencao_id INT;
    DECLARE v_exists INT;

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

    -- 1. Regista a manutenção com a data de início atual
    INSERT INTO `manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `peca_id`, `equipamento_id`)
    VALUES (p_custo_estimado, p_tipo_manutencao, p_descricao, CURDATE(), p_peca_id, p_equipamento_id);
    
    -- Captura o ID da manutenção que acabou de ser inserida
    SET v_manutencao_id = LAST_INSERT_ID();

    -- 2. Cria automaticamente a Ordem de Serviço ligada a essa manutenção
    INSERT INTO `ordem_servico` (`descricao`, `estado_atual`, `prioridade`, `manutencao_id`)
    VALUES (p_descricao, 'Pendente', p_prioridade, v_manutencao_id);

    -- 3. Atualiza o estado do equipamento para avisar que ele não está operacional
    UPDATE `equipamento` 
    SET `estado` = 'Em Manutencao' 
    WHERE `id` = p_equipamento_id;

END$$

DELIMITER ;


