USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `abater_pecas`;

DELIMITER $$

CREATE PROCEDURE `abater_pecas`()
BEGIN
    DELETE FROM `peca` p
    WHERE p.`garantia` < CURDATE()
      AND NOT EXISTS (
          SELECT 1
          FROM `manutencao` m
          WHERE m.`peca_id` = p.`id`
      );

    SELECT ROW_COUNT() AS pecas_abatidas, 'Abate de pecas concluido.' AS mensagem;
END$$

DELIMITER ;

