USE `mydb_uniforme`;

DROP PROCEDURE IF EXISTS `listar_alertas`;

DELIMITER $$

CREATE PROCEDURE `listar_alertas`(
    IN p_dias_manutencao_aberta INT,
    IN p_dias_ordem_pendente INT
)
BEGIN
    IF p_dias_manutencao_aberta <= 0 OR p_dias_ordem_pendente <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Os limites de dias devem ser maiores que zero.';
    END IF;

    SELECT
        'MANUTENCAO_ABERTA_ANTIGA' AS alerta,
        m.`id` AS manutencao_id,
        e.`id` AS equipamento_id,
        e.`nome` AS equipamento_nome,
        m.`data_inicio`,
        DATEDIFF(CURDATE(), m.`data_inicio`) AS dias_aberta
    FROM `manutencao` m
    JOIN `equipamento` e ON e.`id` = m.`equipamento_id`
    WHERE m.`data_fim` IS NULL
      AND DATEDIFF(CURDATE(), m.`data_inicio`) >= p_dias_manutencao_aberta
    ORDER BY dias_aberta DESC;

    SELECT
        'ORDEM_PENDENTE_ANTIGA' AS alerta,
        os.`id` AS ordem_id,
        os.`prioridade`,
        m.`id` AS manutencao_id,
        e.`id` AS equipamento_id,
        DATEDIFF(CURDATE(), m.`data_inicio`) AS dias_desde_abertura
    FROM `ordem_servico` os
    JOIN `manutencao` m ON m.`id` = os.`manutencao_id`
    JOIN `equipamento` e ON e.`id` = m.`equipamento_id`
    WHERE os.`estado_atual` = 'Pendente'
      AND DATEDIFF(CURDATE(), m.`data_inicio`) >= p_dias_ordem_pendente
    ORDER BY dias_desde_abertura DESC;

    SELECT
        'EQUIPAMENTO_NAO_OPERACIONAL' AS alerta,
        e.`id` AS equipamento_id,
        e.`nome` AS equipamento_nome,
        e.`estado`
    FROM `equipamento` e
    WHERE e.`estado` IN ('Em Manutencao', 'Inativo')
    ORDER BY e.`id`;
END$$

DELIMITER ;

