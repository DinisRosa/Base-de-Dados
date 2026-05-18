-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 06: Triggers
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: modelo fisico.sql (Montana)
-- ============================================================

USE `mydb`;

DELIMITER $$

-- ============================================================
-- TRIGGER 1: Ao inserir uma manutenção,
--            atualiza o estado do equipamento para 'Em Manutenção'
-- ============================================================
DROP TRIGGER IF EXISTS trg_inicio_manutencao $$
CREATE TRIGGER trg_inicio_manutencao
AFTER INSERT ON `Manutencao`
FOR EACH ROW
BEGIN
    UPDATE `Equipamento` SET `estado` = 'Em Manutenção'
    WHERE `idEquipamento` = NEW.`Equipamento_idEquipamento`;
END $$

-- ============================================================
-- TRIGGER 2: Ao fechar uma ordem de serviço (estado → 'Concluída'),
--            restaura o estado do equipamento para 'Operacional'
-- ============================================================
DROP TRIGGER IF EXISTS trg_fecho_ordem_servico $$
CREATE TRIGGER trg_fecho_ordem_servico
AFTER UPDATE ON `Ordem_servico`
FOR EACH ROW
BEGIN
    DECLARE v_idEquipamento INT;
    IF OLD.`estado_atual` <> 'Concluída' AND NEW.`estado_atual` = 'Concluída' THEN
        SELECT m.`Equipamento_idEquipamento` INTO v_idEquipamento
        FROM `Manutencao` m
        WHERE m.`id_manutencao` = NEW.`Manutencao_id_manutencao`;

        UPDATE `Equipamento` SET `estado` = 'Operacional'
        WHERE `idEquipamento` = v_idEquipamento;
    END IF;
END $$

-- ============================================================
-- TRIGGER 3: Antes de inserir uma manutenção,
--            valida que data_fim não é anterior a data_inicio
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_datas_manutencao $$
CREATE TRIGGER trg_validar_datas_manutencao
BEFORE INSERT ON `Manutencao`
FOR EACH ROW
BEGIN
    IF NEW.`data_fim` < NEW.`data_inicio` THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: A data de fim não pode ser anterior à data de início.';
    END IF;
END $$

-- ============================================================
-- TRIGGER 4: Antes de inserir uma intervenção,
--            valida que o técnico não está já alocado à mesma manutenção
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_duplicado_intervencao $$
CREATE TRIGGER trg_validar_duplicado_intervencao
BEFORE INSERT ON `Intervencao_Tecnico`
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM `Intervencao_Tecnico`
    WHERE `Tecnico_idTecnico` = NEW.`Tecnico_idTecnico`
      AND `Manutencao_id_manutencao` = NEW.`Manutencao_id_manutencao`;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Este técnico já está alocado a esta manutenção.';
    END IF;
END $$

-- ============================================================
-- TRIGGER 5: Antes de inserir uma manutenção,
--            valida que a peça utilizada ainda está na garantia
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_garantia_peca $$
CREATE TRIGGER trg_validar_garantia_peca
BEFORE INSERT ON `Manutencao`
FOR EACH ROW
BEGIN
    DECLARE v_garantia DATE;
    SELECT `garantia` INTO v_garantia
    FROM `Peca` WHERE `idPeca` = NEW.`Peca_idPeca`;
    IF v_garantia IS NOT NULL AND v_garantia < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Aviso: A peça selecionada já está fora do período de garantia.';
    END IF;
END $$

-- ============================================================
-- TRIGGER 6: Antes de atualizar o estado da Ordem_servico,
--            impede reabrir uma ordem já cancelada
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_transicao_estado_os $$
CREATE TRIGGER trg_validar_transicao_estado_os
BEFORE UPDATE ON `Ordem_servico`
FOR EACH ROW
BEGIN
    IF OLD.`estado_atual` = 'Cancelada' AND NEW.`estado_atual` <> 'Cancelada' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Não é possível reabrir uma Ordem de Serviço cancelada.';
    END IF;
END $$

DELIMITER ;

-- ============================================================
-- FIM DO FICHEIRO 06_triggers.sql
-- ============================================================
