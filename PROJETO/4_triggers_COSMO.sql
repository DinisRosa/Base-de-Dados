-- ============================================================
--   TRIGGERS
-- ============================================================

DELIMITER $$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 1: Validar datas e impedir dupla manutenção (BEFORE INSERT)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_validar_datas_insert$$
CREATE TRIGGER trg_manutencao_validar_datas_insert
BEFORE INSERT ON Manutencao
FOR EACH ROW
BEGIN
    DECLARE v_manutencoes_ativas INT DEFAULT 0;

    -- 1. Verifica se o equipamento já está em manutenção
    SELECT COUNT(*) INTO v_manutencoes_ativas
    FROM Manutencao
    WHERE Equipamento_id_equipamento = NEW.Equipamento_id_equipamento
      AND data_fim IS NULL;

    IF v_manutencoes_ativas > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: O equipamento já possui uma manutenção em curso. Conclua-a primeiro.';
    END IF;

    -- 2. Validação de datas
    IF NEW.data_inicio IS NOT NULL AND NEW.data_fim IS NOT NULL THEN
        IF NEW.data_inicio > NEW.data_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro: A data de início não pode ser posterior à data de fim.';
        END IF;
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 2: Validar datas na atualização (BEFORE UPDATE)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_validar_datas_update$$
CREATE TRIGGER trg_manutencao_validar_datas_update
BEFORE UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    IF NEW.data_inicio IS NOT NULL AND NEW.data_fim IS NOT NULL THEN
        IF NEW.data_inicio > NEW.data_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro: A data de início não pode ser posterior à data de fim.';
        END IF;
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 3: Atualizar estado do equipamento para Em Manutencao (AFTER INSERT)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_estado_equipamento_insert$$
CREATE TRIGGER trg_manutencao_estado_equipamento_insert
AFTER INSERT ON Manutencao
FOR EACH ROW
BEGIN
    IF NEW.data_fim IS NULL THEN
        UPDATE Equipamento
        SET estado = 'Em Manutencao'
        WHERE id_equipamento = NEW.Equipamento_id_equipamento; 
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 4: Repor estado do equipamento e fechar OS (AFTER UPDATE)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_estado_equipamento_update$$
CREATE TRIGGER trg_manutencao_estado_equipamento_update
AFTER UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    -- Se a manutenção recebeu data de fim (terminou)
    IF NEW.data_fim IS NOT NULL AND OLD.data_fim IS NULL THEN
        
        -- 1. Repõe o estado do equipamento
        UPDATE Equipamento
        SET estado = 'Operacional'
        WHERE id_equipamento = NEW.Equipamento_id_equipamento;
        
        -- 2. Fecha a Ordem de Serviço associada
        UPDATE Ordem_servico
        SET estado_atual = 'Concluida'
        WHERE Manutencao_id_manutencao = NEW.id_manutencao;
        
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 5A e 5B: Validar domínios da ordem de serviço
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_ordem_servico_validar_dominios_insert$$
CREATE TRIGGER trg_ordem_servico_validar_dominios_insert
BEFORE INSERT ON Ordem_servico
FOR EACH ROW
BEGIN
    IF NEW.prioridade NOT IN ('Baixa', 'Media', 'Alta', 'Urgente') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Prioridade inválida.';
    END IF;
    IF NEW.estado_atual NOT IN ('Pendente', 'Em Curso', 'Concluida', 'Cancelada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado atual inválido.';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_ordem_servico_validar_dominios_update$$
CREATE TRIGGER trg_ordem_servico_validar_dominios_update
BEFORE UPDATE ON Ordem_servico
FOR EACH ROW
BEGIN
    IF NEW.prioridade NOT IN ('Baixa', 'Media', 'Alta', 'Urgente') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Prioridade inválida.';
    END IF;
    IF NEW.estado_atual NOT IN ('Pendente', 'Em Curso', 'Concluida', 'Cancelada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado atual inválido.';
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 6A e 6B: Validar domínios do estado do Equipamento
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_equipamento_validar_estado_insert$$
CREATE TRIGGER trg_equipamento_validar_estado_insert
BEFORE INSERT ON Equipamento
FOR EACH ROW
BEGIN
    IF NEW.estado NOT IN ('Operacional', 'Em Manutencao', 'Avariado', 'Abatido') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado inválido.';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_equipamento_validar_estado_update$$
CREATE TRIGGER trg_equipamento_validar_estado_update
BEFORE UPDATE ON Equipamento
FOR EACH ROW
BEGIN
    IF NEW.estado NOT IN ('Operacional', 'Em Manutencao', 'Avariado', 'Abatido') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado inválido.';
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 7: Impedir eliminação de equipamento com histórico ativo
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_equipamento_proteger_delete$$
CREATE TRIGGER trg_equipamento_proteger_delete
BEFORE DELETE ON Equipamento
FOR EACH ROW
BEGIN
    DECLARE v_manutencoes_ativas INT DEFAULT 0;
    DECLARE v_ordens_abertas INT DEFAULT 0;

    SELECT COUNT(*) INTO v_manutencoes_ativas FROM Manutencao
    WHERE Equipamento_id_equipamento = OLD.id_equipamento AND data_fim IS NULL;

    IF v_manutencoes_ativas > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Não é possível eliminar equipamento com manutenções ativas.';
    END IF;

    SELECT COUNT(*) INTO v_ordens_abertas FROM Ordem_servico os
    INNER JOIN Manutencao m ON os.Manutencao_id_manutencao = m.id_manutencao
    WHERE m.Equipamento_id_equipamento = OLD.id_equipamento AND os.estado_atual != 'Concluida';

    IF v_ordens_abertas > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Não é possível eliminar equipamento com ordens abertas.';
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 8: Validar coerência de custos (Custo Manutenção >= Custo Peça)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_validar_custo_insert$$
CREATE TRIGGER trg_manutencao_validar_custo_insert
BEFORE INSERT ON Manutencao
FOR EACH ROW
BEGIN
    DECLARE v_preco_peca DECIMAL(10,2);

    IF NEW.Peca_id_peca IS NOT NULL THEN
        SELECT preco INTO v_preco_peca
        FROM Peca
        WHERE id_peca = NEW.Peca_id_peca;

        IF NEW.custo < v_preco_peca THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro Financeiro: O custo da manutencao nao pode ser inferior ao preco da peca.';
        END IF;
    END IF;
END$$

DELIMITER ;


