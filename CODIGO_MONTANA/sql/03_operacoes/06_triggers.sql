-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 03.06: Triggers
-- ============================================================

USE `mydb`;

-- ============================================================
-- Trigger: Log de Alterações de Estado do Equipamento
-- (Nota: Requer tabela de auditoria)
-- ============================================================

-- Criar tabela de auditoria (se não existir)
CREATE TABLE IF NOT EXISTS `auditoria_equipamento` (
    `id_auditoria` INT NOT NULL AUTO_INCREMENT,
    `idEquipamento` INT NOT NULL,
    `estado_anterior` VARCHAR(45),
    `estado_novo` VARCHAR(45),
    `data_alteracao` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `usuario` VARCHAR(45),
    PRIMARY KEY (`id_auditoria`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Trigger: Antes de Atualizar Equipamento
-- ============================================================
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS tr_antes_atualizar_equipamento
BEFORE UPDATE ON `Equipamento`
FOR EACH ROW
BEGIN
    IF NEW.`estado` != OLD.`estado` THEN
        INSERT INTO `auditoria_equipamento` (
            `idEquipamento`, `estado_anterior`, `estado_novo`, `usuario`
        ) VALUES (
            NEW.`idEquipamento`, OLD.`estado`, NEW.`estado`, USER()
        );
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- Trigger: Depois de Inserir Manutenção
-- (Atualiza estado do equipamento automaticamente)
-- ============================================================
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS tr_depois_inserir_manutencao
AFTER INSERT ON `Manutencao`
FOR EACH ROW
BEGIN
    -- Se a manutenção é do tipo 'Corretiva', muda estado para manutenção
    IF NEW.`tipo` = 'Corretiva' THEN
        UPDATE `Equipamento`
        SET `estado` = 'Manutenção Corretiva'
        WHERE `idEquipamento` = NEW.`Equipamento_idEquipamento`;
    ELSEIF NEW.`tipo` = 'Preventiva' THEN
        UPDATE `Equipamento`
        SET `estado` = 'Manutenção Preventiva'
        WHERE `idEquipamento` = NEW.`Equipamento_idEquipamento`;
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- Trigger: Depois de Atualizar Manutenção (data_fim)
-- (Retorna equipamento a operacional quando manutenção termina)
-- ============================================================
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS tr_depois_atualizar_manutencao
AFTER UPDATE ON `Manutencao`
FOR EACH ROW
BEGIN
    -- Se a data_fim foi preenchida e não estava preenchida antes
    IF NEW.`data_fim` IS NOT NULL AND OLD.`data_fim` IS NULL THEN
        UPDATE `Equipamento`
        SET `estado` = 'Operacional'
        WHERE `idEquipamento` = NEW.`Equipamento_idEquipamento`;
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- Trigger: Antes de Eliminar Equipamento
-- (Valida se não tem manutenções ativas)
-- ============================================================
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS tr_antes_eliminar_equipamento
BEFORE DELETE ON `Equipamento`
FOR EACH ROW
BEGIN
    DECLARE v_manutencoes_ativas INT;
    
    SELECT COUNT(*) INTO v_manutencoes_ativas
    FROM `Manutencao`
    WHERE `Equipamento_idEquipamento` = OLD.`idEquipamento`
    AND `data_fim` IS NULL;
    
    IF v_manutencoes_ativas > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível eliminar equipamento com manutenções em progresso';
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- Trigger: Antes de Inserir Ordem de Serviço
-- (Valida prioridade)
-- ============================================================
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS tr_antes_inserir_ordem_servico
BEFORE INSERT ON `Ordem_servico`
FOR EACH ROW
BEGIN
    IF NEW.`prioridade` NOT IN ('Crítica', 'Alta', 'Normal', 'Baixa') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prioridade inválida. Deve ser: Crítica, Alta, Normal ou Baixa';
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- End of Triggers
-- ============================================================
