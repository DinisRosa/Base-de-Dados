USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `adicionar_peca`;

DELIMITER $$

CREATE PROCEDURE `adicionar_peca`(
    IN p_preco DECIMAL(10,2),
    IN p_designacao VARCHAR(45),
    IN p_garantia DATE
)
BEGIN
    IF p_preco < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Preco invalido.';
    END IF;

    INSERT INTO `peca` (`preco`, `designacao`, `garantia`)
    VALUES (p_preco, p_designacao, p_garantia);

    SELECT LAST_INSERT_ID() AS peca_id, 'Peca adicionada.' AS mensagem;
END$$

DELIMITER ;

