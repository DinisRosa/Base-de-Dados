-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 04: Stored Procedures de Negócio
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: mod_conceptual_novas_modificacoes (versão revista - Novas Modificações)
-- ============================================================

USE gestao_equipamentos;

DELIMITER $$

-- ============================================================
-- SP 1: Registar manutenção completa numa transação
-- (cria manutenção + ordem de serviço + intervenção do técnico)
-- Atualizado com novos campos: duracao, horas_trabalho, estado_atual
-- ============================================================
DROP PROCEDURE IF EXISTS sp_registar_manutencao_completa $$
CREATE PROCEDURE sp_registar_manutencao_completa(
    IN p_tipo              VARCHAR(50),
    IN p_data_inicio       DATE,
    IN p_descricao         VARCHAR(500),
    IN p_custo             DECIMAL(10,2),
    IN p_duracao           INT,
    IN p_id_equipamento    INT,
    IN p_descricao_os      VARCHAR(500),
    IN p_prioridade        VARCHAR(20),
    IN p_id_tecnico        INT,
    IN p_cargo             VARCHAR(100),
    IN p_horas             DECIMAL(5,1)
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

    -- 1. Criar a manutenção (com novos campos)
    INSERT INTO MANUTENCAO (tipo, data_inicio, data_fim, descricao, custo, duracao, horas_trabalho, id_equipamento)
    VALUES (p_tipo, p_data_inicio, NULL, p_descricao, p_custo, p_duracao, p_horas, p_id_equipamento);
    SET v_id_manutencao = LAST_INSERT_ID();

    -- 2. Criar a ordem de serviço
    INSERT INTO ORDEM_SERVICO (descricao, estado_atual, data_criacao, prioridade)
    VALUES (p_descricao_os, 'Em Execução', CURDATE(), p_prioridade);
    SET v_id_ordem = LAST_INSERT_ID();

    -- 3. Associar manutenção à ordem
    INSERT INTO MANUTENCAO_ORDEM (id_manutencao, id_ordem)
    VALUES (v_id_manutencao, v_id_ordem);

    -- 4. Registar intervenção do técnico (entrel direto)
    INSERT INTO INTERVENCAO_TECNICO (id_manutencao, id_tecnico, cargo, horas_trabalho)
    VALUES (v_id_manutencao, p_id_tecnico, p_cargo, p_horas);

    -- 5. Atualizar estado e estado_atual do equipamento
    UPDATE EQUIPAMENTO SET estado = 'Em Manutenção', estado_atual = 'Em Manutenção'
    WHERE id_equipamento = p_id_equipamento;

    COMMIT;

    SELECT v_id_manutencao AS id_manutencao,
           v_id_ordem      AS id_ordem,
           'Manutenção registada com sucesso' AS mensagem;
END $$

-- ============================================================
-- SP 2: Fechar ordem de serviço e concluir manutenção
-- Atualizado para atualizar estado_atual
-- ============================================================
DROP PROCEDURE IF EXISTS sp_fechar_ordem_servico $$
CREATE PROCEDURE sp_fechar_ordem_servico(
    IN p_id_ordem      INT,
    IN p_id_manutencao INT,
    IN p_data_fim      DATE
)
BEGIN
    DECLARE v_id_equip INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao fechar ordem de serviço.';
    END;

    START TRANSACTION;

    UPDATE ORDEM_SERVICO SET estado_atual = 'Concluída' WHERE id_ordem = p_id_ordem;

    UPDATE MANUTENCAO SET data_fim = p_data_fim WHERE id_manutencao = p_id_manutencao;

    SELECT id_equipamento INTO v_id_equip
    FROM MANUTENCAO WHERE id_manutencao = p_id_manutencao;

    UPDATE EQUIPAMENTO SET estado = 'Operacional', estado_atual = 'Operacional' 
    WHERE id_equipamento = v_id_equip;

    COMMIT;

    SELECT 'Ordem fechada e equipamento marcado como Operacional' AS mensagem;
END $$

-- ============================================================
-- SP 3: Alocar técnico adicional a uma manutenção existente
-- ============================================================
DROP PROCEDURE IF EXISTS sp_alocar_tecnico_manutencao $$
CREATE PROCEDURE sp_alocar_tecnico_manutencao(
    IN p_id_manutencao INT,
    IN p_id_tecnico    INT,
    IN p_cargo         VARCHAR(100),
    IN p_horas         DECIMAL(5,1)
)
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count FROM MANUTENCAO WHERE id_manutencao = p_id_manutencao;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Manutenção não encontrada.';
    END IF;

    SELECT COUNT(*) INTO v_count FROM TECNICO WHERE id_tecnico = p_id_tecnico;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Técnico não encontrado.';
    END IF;

    INSERT INTO INTERVENCAO_TECNICO (id_manutencao, id_tecnico, cargo, horas_trabalho)
    VALUES (p_id_manutencao, p_id_tecnico, p_cargo, p_horas);

    SELECT LAST_INSERT_ID() AS id_intervencao, 'Técnico alocado com sucesso' AS mensagem;
END $$

-- ============================================================
-- SP 4: Registar substituição de peça (com validação de validade)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_registar_substituicao_peca $$
CREATE PROCEDURE sp_registar_substituicao_peca(
    IN p_id_manutencao INT,
    IN p_id_peca       INT,
    IN p_quantidade    INT
)
BEGIN
    DECLARE v_validade   DATE;
    DECLARE v_designacao VARCHAR(150);

    SELECT validade_peca, designacao INTO v_validade, v_designacao
    FROM PECA WHERE id_peca = p_id_peca;

    IF v_validade IS NOT NULL AND v_validade < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: A peça está fora do prazo de validade.';
    END IF;

    INSERT INTO MANUTENCAO_PECA (id_manutencao, id_peca, quantidade)
    VALUES (p_id_manutencao, p_id_peca, p_quantidade)
    ON DUPLICATE KEY UPDATE quantidade = quantidade + p_quantidade;

    SELECT CONCAT('Peça "', v_designacao, '" registada na manutenção') AS mensagem;
END $$

-- ============================================================
-- SP 5: Relatório de equipamentos por departamento
-- Atualizado para incluir estado_atual e garantia
-- ============================================================
DROP PROCEDURE IF EXISTS sp_relatorio_equipamentos_dept $$
CREATE PROCEDURE sp_relatorio_equipamentos_dept(IN p_id_departamento INT)
BEGIN
    SELECT
        e.id_equipamento,
        e.designacao,
        e.fabricante,
        e.estado,
        e.estado_atual,
        e.garantia,
        e.data_aquisicao,
        TIMESTAMPDIFF(YEAR, e.data_aquisicao, CURDATE()) AS idade_anos,
        l.sala,
        l.piso,
        l.edificio
    FROM EQUIPAMENTO e
    JOIN EQUIPAMENTO_DEPARTAMENTO ed ON e.id_equipamento  = ed.id_equipamento
    LEFT JOIN LOCALIZACAO l           ON e.id_localizacao  = l.id_localizacao
    WHERE ed.id_departamento = p_id_departamento
    ORDER BY e.estado_atual, e.designacao;
END $$

DELIMITER ;

-- ============================================================
-- FIM DO FICHEIRO 04_procedures.sql
-- ============================================================
