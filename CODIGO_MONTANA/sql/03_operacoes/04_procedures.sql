-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 04: Stored Procedures de Negócio
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: modelo fisico.sql (Montana)
-- ============================================================

USE `mydb`;

DELIMITER $$

-- ============================================================
-- SP 1: Registar manutenção completa numa transação
-- (cria manutenção + ordem de serviço numa só operação atómica)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_registar_manutencao_completa $$
CREATE PROCEDURE sp_registar_manutencao_completa(
    IN p_custo              DECIMAL(10,2),
    IN p_tipo               VARCHAR(45),
    IN p_descricao          VARCHAR(45),
    IN p_data_inicio        DATE,
    IN p_data_fim           DATE,
    IN p_idPeca             INT,
    IN p_idEquipamento      INT,
    IN p_descricao_os       VARCHAR(45),
    IN p_estado_os          VARCHAR(45),
    IN p_prioridade         VARCHAR(45)
)
BEGIN
    DECLARE v_id_manutencao INT;
    DECLARE v_id_ordem      INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro ao registar manutenção. Operação revertida.';
    END;

    START TRANSACTION;

    -- 1. Criar a manutenção
    INSERT INTO `Manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `data_fim`,
                               `Peca_idPeca`, `Equipamento_idEquipamento`)
    VALUES (p_custo, p_tipo, p_descricao, p_data_inicio, p_data_fim, p_idPeca, p_idEquipamento);
    SET v_id_manutencao = LAST_INSERT_ID();

    -- 2. Criar a ordem de serviço associada
    INSERT INTO `Ordem_servico` (`descricao`, `estado_atual`, `prioridade`,
                                  `Manutencao_id_manutencao`)
    VALUES (p_descricao_os, p_estado_os, p_prioridade, v_id_manutencao);
    SET v_id_ordem = LAST_INSERT_ID();

    -- 3. Atualizar estado do equipamento
    UPDATE `Equipamento` SET `estado` = 'Em Manutenção'
    WHERE `idEquipamento` = p_idEquipamento;

    COMMIT;

    SELECT v_id_manutencao AS id_manutencao,
           v_id_ordem      AS id_ordem,
           'Manutenção e Ordem de Serviço registadas com sucesso' AS mensagem;
END $$

-- ============================================================
-- SP 2: Alocar técnico a uma manutenção existente
-- ============================================================
DROP PROCEDURE IF EXISTS sp_alocar_tecnico_manutencao $$
CREATE PROCEDURE sp_alocar_tecnico_manutencao(
    IN p_id_manutencao  INT,
    IN p_id_tecnico     INT,
    IN p_cargo          VARCHAR(45),
    IN p_horas_trabalho INT
)
BEGIN
    DECLARE v_count INT;

    -- Validar existência da manutenção
    SELECT COUNT(*) INTO v_count FROM `Manutencao` WHERE `id_manutencao` = p_id_manutencao;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Manutenção não encontrada.';
    END IF;

    -- Validar existência do técnico
    SELECT COUNT(*) INTO v_count FROM `Tecnico` WHERE `idTecnico` = p_id_tecnico;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Técnico não encontrado.';
    END IF;

    INSERT INTO `Intervencao_Tecnico` (`Cargo`, `horas_trabalho`,
                                        `Tecnico_idTecnico`, `Manutencao_id_manutencao`)
    VALUES (p_cargo, p_horas_trabalho, p_id_tecnico, p_id_manutencao);

    SELECT LAST_INSERT_ID() AS idIntervencao, 'Técnico alocado com sucesso' AS mensagem;
END $$

-- ============================================================
-- SP 3: Fechar ordem de serviço e marcar equipamento operacional
-- ============================================================
DROP PROCEDURE IF EXISTS sp_fechar_ordem_servico $$
CREATE PROCEDURE sp_fechar_ordem_servico(
    IN p_id_ordem INT
)
BEGIN
    DECLARE v_id_manutencao INT;
    DECLARE v_id_equipamento INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao fechar ordem de serviço.';
    END;

    START TRANSACTION;

    -- Obter a manutenção associada à ordem
    SELECT `Manutencao_id_manutencao` INTO v_id_manutencao
    FROM `Ordem_servico` WHERE `idOrdem` = p_id_ordem;

    -- Obter o equipamento associado à manutenção
    SELECT `Equipamento_idEquipamento` INTO v_id_equipamento
    FROM `Manutencao` WHERE `id_manutencao` = v_id_manutencao;

    -- Marcar ordem como concluída
    UPDATE `Ordem_servico` SET `estado_atual` = 'Concluída' WHERE `idOrdem` = p_id_ordem;

    -- Marcar equipamento como operacional
    UPDATE `Equipamento` SET `estado` = 'Operacional' WHERE `idEquipamento` = v_id_equipamento;

    COMMIT;

    SELECT 'Ordem fechada e equipamento marcado como Operacional' AS mensagem;
END $$

-- ============================================================
-- SP 4: Relatório de equipamentos por departamento
-- ============================================================
DROP PROCEDURE IF EXISTS sp_relatorio_equipamentos_dept $$
CREATE PROCEDURE sp_relatorio_equipamentos_dept(IN p_idDepartamento INT)
BEGIN
    SELECT
        e.`idEquipamento`,
        e.`designacao`,
        e.`fabricante`,
        e.`estado`,
        e.`data_aquisicao`,
        TIMESTAMPDIFF(YEAR, e.`data_aquisicao`, CURDATE()) AS idade_anos,
        l.`sala`,
        l.`piso`,
        l.`edificio`
    FROM `Equipamento` e
    LEFT JOIN `Localizacao` l ON e.`Localizacao_idLocalizacao` = l.`idLocalizacao`
    WHERE e.`Departamento_idDepartamento` = p_idDepartamento
    ORDER BY e.`estado`, e.`designacao`;
END $$

-- ============================================================
-- SP 5: Listar intervenções de um técnico
-- ============================================================
DROP PROCEDURE IF EXISTS sp_intervencoes_por_tecnico $$
CREATE PROCEDURE sp_intervencoes_por_tecnico(IN p_idTecnico INT)
BEGIN
    SELECT
        it.`idIntervencao`,
        it.`Cargo`,
        it.`horas_trabalho`,
        m.`id_manutencao`,
        m.`tipo`,
        m.`data_inicio`,
        m.`data_fim`,
        m.`custo`,
        e.`designacao` AS equipamento
    FROM `Intervencao_Tecnico` it
    JOIN `Manutencao` m ON it.`Manutencao_id_manutencao` = m.`id_manutencao`
    JOIN `Equipamento` e ON m.`Equipamento_idEquipamento` = e.`idEquipamento`
    WHERE it.`Tecnico_idTecnico` = p_idTecnico
    ORDER BY m.`data_inicio` DESC;
END $$

DELIMITER ;

-- ============================================================
-- FIM DO FICHEIRO 04_procedures.sql
-- ============================================================
