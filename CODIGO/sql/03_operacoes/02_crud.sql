-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 02: CRUD (Stored Procedures)
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: mod_conceptual_novas_modificacoes (versão revista - Sem EQUIPAMENTO_DEPARTAMENTO)
-- ============================================================

USE gestao_equipamentos;

DELIMITER $$

-- ============================================================
-- CRUD: LOCALIZACAO
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_localizacao $$
CREATE PROCEDURE sp_insert_localizacao(
    IN p_sala     VARCHAR(50),
    IN p_piso     VARCHAR(20),
    IN p_edificio VARCHAR(100)
)
BEGIN
    INSERT INTO LOCALIZACAO (sala, piso, edificio) VALUES (p_sala, p_piso, p_edificio);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Localização inserida' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_localizacao $$
CREATE PROCEDURE sp_update_localizacao(
    IN p_id       INT,
    IN p_sala     VARCHAR(50),
    IN p_piso     VARCHAR(20),
    IN p_edificio VARCHAR(100)
)
BEGIN
    UPDATE LOCALIZACAO SET sala=p_sala, piso=p_piso, edificio=p_edificio
    WHERE id_localizacao=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Localização ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Localização atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_localizacao $$
CREATE PROCEDURE sp_delete_localizacao(IN p_id INT)
BEGIN
    DELETE FROM LOCALIZACAO WHERE id_localizacao=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Localização ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Localização removida' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: DEPARTAMENTO
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_departamento $$
CREATE PROCEDURE sp_insert_departamento(
    IN p_designacao VARCHAR(100),
    IN p_descricao  VARCHAR(255)
)
BEGIN
    INSERT INTO DEPARTAMENTO (designacao, descricao) VALUES (p_designacao, p_descricao);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Departamento inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_departamento $$
CREATE PROCEDURE sp_update_departamento(
    IN p_id         INT,
    IN p_designacao VARCHAR(100),
    IN p_descricao  VARCHAR(255)
)
BEGIN
    UPDATE DEPARTAMENTO SET designacao=p_designacao, descricao=p_descricao
    WHERE id_departamento=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Departamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Departamento atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_departamento $$
CREATE PROCEDURE sp_delete_departamento(IN p_id INT)
BEGIN
    DELETE FROM DEPARTAMENTO WHERE id_departamento=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Departamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Departamento removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: RESPONSAVEL (com novo campo aprova)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_responsavel $$
CREATE PROCEDURE sp_insert_responsavel(
    IN p_nome            VARCHAR(150),
    IN p_data_nascimento DATE,
    IN p_id_departamento INT,
    IN p_aprova          BOOLEAN
)
BEGIN
    INSERT INTO RESPONSAVEL (nome, data_nascimento, id_departamento, aprova)
    VALUES (p_nome, p_data_nascimento, p_id_departamento, p_aprova);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Responsável inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_responsavel $$
CREATE PROCEDURE sp_update_responsavel(
    IN p_id              INT,
    IN p_nome            VARCHAR(150),
    IN p_data_nascimento DATE,
    IN p_id_departamento INT,
    IN p_aprova          BOOLEAN
)
BEGIN
    UPDATE RESPONSAVEL SET nome=p_nome, data_nascimento=p_data_nascimento, 
                           id_departamento=p_id_departamento, aprova=p_aprova
    WHERE id_responsavel=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Responsável ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Responsável atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_responsavel $$
CREATE PROCEDURE sp_delete_responsavel(IN p_id INT)
BEGIN
    DELETE FROM RESPONSAVEL WHERE id_responsavel=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Responsável ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Responsável removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: EQUIPAMENTO (com novos campos estado_atual, garantia, id_departamento)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_equipamento $$
CREATE PROCEDURE sp_insert_equipamento(
    IN p_designacao     VARCHAR(150),
    IN p_data_aquisicao DATE,
    IN p_fabricante     VARCHAR(100),
    IN p_estado         VARCHAR(50),
    IN p_estado_atual   VARCHAR(50),
    IN p_descricao      VARCHAR(500),
    IN p_garantia       INT,
    IN p_id_localizacao INT,
    IN p_id_departamento INT
)
BEGIN
    INSERT INTO EQUIPAMENTO (designacao, data_aquisicao, fabricante, estado, estado_atual, 
                             descricao, garantia, id_localizacao, id_departamento)
    VALUES (p_designacao, p_data_aquisicao, p_fabricante, p_estado, p_estado_atual, 
            p_descricao, p_garantia, p_id_localizacao, p_id_departamento);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Equipamento inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_equipamento $$
CREATE PROCEDURE sp_update_equipamento(
    IN p_id             INT,
    IN p_designacao     VARCHAR(150),
    IN p_data_aquisicao DATE,
    IN p_fabricante     VARCHAR(100),
    IN p_estado         VARCHAR(50),
    IN p_estado_atual   VARCHAR(50),
    IN p_descricao      VARCHAR(500),
    IN p_garantia       INT,
    IN p_id_localizacao INT,
    IN p_id_departamento INT
)
BEGIN
    UPDATE EQUIPAMENTO SET designacao=p_designacao, data_aquisicao=p_data_aquisicao,
                          fabricante=p_fabricante, estado=p_estado, estado_atual=p_estado_atual,
                          descricao=p_descricao, garantia=p_garantia, id_localizacao=p_id_localizacao,
                          id_departamento=p_id_departamento
    WHERE id_equipamento=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Equipamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Equipamento atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_equipamento $$
CREATE PROCEDURE sp_delete_equipamento(IN p_id INT)
BEGIN
    DELETE FROM EQUIPAMENTO WHERE id_equipamento=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Equipamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Equipamento removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: TECNICO (com novo campo anos_experiencia)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_tecnico $$
CREATE PROCEDURE sp_insert_tecnico(
    IN p_nome                 VARCHAR(150),
    IN p_especialidade        VARCHAR(100),
    IN p_data_inicio_carreira DATE,
    IN p_anos_experiencia     INT
)
BEGIN
    INSERT INTO TECNICO (nome, especialidade, data_inicio_carreira, anos_experiencia)
    VALUES (p_nome, p_especialidade, p_data_inicio_carreira, p_anos_experiencia);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Técnico inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_tecnico $$
CREATE PROCEDURE sp_update_tecnico(
    IN p_id                   INT,
    IN p_nome                 VARCHAR(150),
    IN p_especialidade        VARCHAR(100),
    IN p_data_inicio_carreira DATE,
    IN p_anos_experiencia     INT
)
BEGIN
    UPDATE TECNICO SET nome=p_nome, especialidade=p_especialidade,
                      data_inicio_carreira=p_data_inicio_carreira, anos_experiencia=p_anos_experiencia
    WHERE id_tecnico=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Técnico ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Técnico atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_tecnico $$
CREATE PROCEDURE sp_delete_tecnico(IN p_id INT)
BEGIN
    DELETE FROM TECNICO WHERE id_tecnico=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Técnico ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Técnico removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: MANUTENCAO (com novos campos duracao, horas_trabalho)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_manutencao $$
CREATE PROCEDURE sp_insert_manutencao(
    IN p_tipo          VARCHAR(50),
    IN p_data_inicio   DATE,
    IN p_data_fim      DATE,
    IN p_descricao     VARCHAR(500),
    IN p_custo         DECIMAL(10,2),
    IN p_duracao       INT,
    IN p_horas_trabalho DECIMAL(5,1),
    IN p_id_equipamento INT
)
BEGIN
    INSERT INTO MANUTENCAO (tipo, data_inicio, data_fim, descricao, custo, duracao, horas_trabalho, id_equipamento)
    VALUES (p_tipo, p_data_inicio, p_data_fim, p_descricao, p_custo, p_duracao, p_horas_trabalho, p_id_equipamento);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Manutenção inserida' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_manutencao $$
CREATE PROCEDURE sp_update_manutencao(
    IN p_id            INT,
    IN p_tipo          VARCHAR(50),
    IN p_data_inicio   DATE,
    IN p_data_fim      DATE,
    IN p_descricao     VARCHAR(500),
    IN p_custo         DECIMAL(10,2),
    IN p_duracao       INT,
    IN p_horas_trabalho DECIMAL(5,1),
    IN p_id_equipamento INT
)
BEGIN
    UPDATE MANUTENCAO SET tipo=p_tipo, data_inicio=p_data_inicio, data_fim=p_data_fim,
                        descricao=p_descricao, custo=p_custo, duracao=p_duracao, 
                        horas_trabalho=p_horas_trabalho, id_equipamento=p_id_equipamento
    WHERE id_manutencao=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Manutenção ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Manutenção atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_manutencao $$
CREATE PROCEDURE sp_delete_manutencao(IN p_id INT)
BEGIN
    DELETE FROM MANUTENCAO WHERE id_manutencao=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Manutenção ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Manutenção removida' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: ORDEM_SERVICO
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_ordem_servico $$
CREATE PROCEDURE sp_insert_ordem_servico(
    IN p_descricao    VARCHAR(500),
    IN p_estado_atual VARCHAR(50),
    IN p_prioridade   VARCHAR(20)
)
BEGIN
    INSERT INTO ORDEM_SERVICO (descricao, estado_atual, prioridade)
    VALUES (p_descricao, p_estado_atual, p_prioridade);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Ordem inserida' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_ordem_servico $$
CREATE PROCEDURE sp_update_ordem_servico(
    IN p_id           INT,
    IN p_descricao    VARCHAR(500),
    IN p_estado_atual VARCHAR(50),
    IN p_prioridade   VARCHAR(20)
)
BEGIN
    UPDATE ORDEM_SERVICO SET descricao=p_descricao, estado_atual=p_estado_atual, prioridade=p_prioridade
    WHERE id_ordem=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Ordem ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Ordem atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_ordem_servico $$
CREATE PROCEDURE sp_delete_ordem_servico(IN p_id INT)
BEGIN
    DELETE FROM ORDEM_SERVICO WHERE id_ordem=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Ordem ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Ordem removida' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: PECA (com novo campo custo)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_peca $$
CREATE PROCEDURE sp_insert_peca(
    IN p_designacao    VARCHAR(150),
    IN p_preco         DECIMAL(10,2),
    IN p_custo         DECIMAL(10,2),
    IN p_validade_peca DATE
)
BEGIN
    INSERT INTO PECA (designacao, preco, custo, validade_peca)
    VALUES (p_designacao, p_preco, p_custo, p_validade_peca);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Peça inserida' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_peca $$
CREATE PROCEDURE sp_update_peca(
    IN p_id            INT,
    IN p_designacao    VARCHAR(150),
    IN p_preco         DECIMAL(10,2),
    IN p_custo         DECIMAL(10,2),
    IN p_validade_peca DATE
)
BEGIN
    UPDATE PECA SET designacao=p_designacao, preco=p_preco, custo=p_custo, validade_peca=p_validade_peca
    WHERE id_peca=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Peça ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Peça atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_peca $$
CREATE PROCEDURE sp_delete_peca(IN p_id INT)
BEGIN
    DELETE FROM PECA WHERE id_peca=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Peça ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Peça removida' AS mensagem; END IF;
END $$

DELIMITER ;

-- ============================================================
-- FIM DO FICHEIRO 02_crud.sql
-- ============================================================
