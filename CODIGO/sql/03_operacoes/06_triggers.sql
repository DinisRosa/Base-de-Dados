-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 06: Triggers
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: mod_conceptual_novas_modificacoes (versão revista - Novas Modificações)
-- ============================================================

USE gestao_equipamentos;

DELIMITER $$

-- ============================================================
-- TRIGGER 1: Ao inserir uma manutenção aberta,
--            atualiza o estado e estado_atual do equipamento para 'Em Manutenção'
-- ============================================================
DROP TRIGGER IF EXISTS trg_inicio_manutencao $$
CREATE TRIGGER trg_inicio_manutencao
AFTER INSERT ON MANUTENCAO
FOR EACH ROW
BEGIN
    IF NEW.data_fim IS NULL THEN
        UPDATE EQUIPAMENTO SET estado = 'Em Manutenção', estado_atual = 'Em Manutenção'
        WHERE id_equipamento = NEW.id_equipamento;
    END IF;
END $$

-- ============================================================
-- TRIGGER 2: Ao fechar uma manutenção (data_fim preenchida),
--            restaura o estado e estado_atual do equipamento para 'Operacional'
-- ============================================================
DROP TRIGGER IF EXISTS trg_fecho_manutencao $$
CREATE TRIGGER trg_fecho_manutencao
AFTER UPDATE ON MANUTENCAO
FOR EACH ROW
BEGIN
    IF OLD.data_fim IS NULL AND NEW.data_fim IS NOT NULL THEN
        UPDATE EQUIPAMENTO SET estado = 'Operacional', estado_atual = 'Operacional'
        WHERE id_equipamento = NEW.id_equipamento;
    END IF;
END $$

-- ============================================================
-- TRIGGER 3: Antes de associar uma peça a uma manutenção,
--            valida o prazo de validade da peça
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_validade_peca $$
CREATE TRIGGER trg_validar_validade_peca
BEFORE INSERT ON MANUTENCAO_PECA
FOR EACH ROW
BEGIN
    DECLARE v_validade DATE;
    SELECT validade_peca INTO v_validade FROM PECA WHERE id_peca = NEW.id_peca;
    IF v_validade IS NOT NULL AND v_validade < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: A peça está fora do prazo de validade.';
    END IF;
END $$

-- ============================================================
-- TRIGGER 4: Auditoria automática de mudanças de estado
--            do equipamento (regista em AUDITORIA_EQUIPAMENTO)
--            Atualizado para auditar também estado_atual
-- ============================================================
DROP TRIGGER IF EXISTS trg_auditoria_estado_equipamento $$
CREATE TRIGGER trg_auditoria_estado_equipamento
AFTER UPDATE ON EQUIPAMENTO
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado OR OLD.estado_atual <> NEW.estado_atual THEN
        INSERT INTO AUDITORIA_EQUIPAMENTO
            (id_equipamento, estado_antigo, estado_novo, data_alteracao, utilizador)
        VALUES
            (NEW.id_equipamento, 
             CONCAT(OLD.estado, '/', OLD.estado_atual), 
             CONCAT(NEW.estado, '/', NEW.estado_atual), 
             NOW(), USER());
    END IF;
END $$

-- ============================================================
-- TRIGGER 5: Antes de inserir uma manutenção, valida que
--            data_fim (se fornecida) não é anterior a data_inicio
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_datas_manutencao $$
CREATE TRIGGER trg_validar_datas_manutencao
BEFORE INSERT ON MANUTENCAO
FOR EACH ROW
BEGIN
    IF NEW.data_fim IS NOT NULL AND NEW.data_fim < NEW.data_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: A data de fim não pode ser anterior à data de início.';
    END IF;
END $$

-- ============================================================
-- TRIGGER 6: Antes de registar uma intervenção de técnico,
--            valida que a manutenção ainda está em aberto
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_intervencao_aberta $$
CREATE TRIGGER trg_validar_intervencao_aberta
BEFORE INSERT ON INTERVENCAO_TECNICO
FOR EACH ROW
BEGIN
    DECLARE v_data_fim DATE;
    SELECT data_fim INTO v_data_fim FROM MANUTENCAO WHERE id_manutencao = NEW.id_manutencao;
    IF v_data_fim IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Não é possível adicionar técnicos a uma manutenção já encerrada.';
    END IF;
END $$

-- ============================================================
-- TRIGGER 7: Valida quantidade na tabela MANUTENCAO_PECA
--            quantidade deve ser > 0
-- ============================================================
DROP TRIGGER IF EXISTS trg_validar_quantidade_peca $$
CREATE TRIGGER trg_validar_quantidade_peca
BEFORE INSERT ON MANUTENCAO_PECA
FOR EACH ROW
BEGIN
    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: A quantidade de peças deve ser maior que 0.';
    END IF;
END $$

DELIMITER ;

-- ============================================================
-- FIM DO FICHEIRO 06_triggers.sql
-- ============================================================
