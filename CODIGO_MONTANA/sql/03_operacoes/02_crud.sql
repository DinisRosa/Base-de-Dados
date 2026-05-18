-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 02: CRUD (Stored Procedures)
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: modelo fisico.sql (Montana)
-- ============================================================

USE `mydb`;

DELIMITER $$

-- ============================================================
-- CRUD: Peca
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_peca $$
CREATE PROCEDURE sp_insert_peca(
    IN p_preco      DECIMAL(10,2),
    IN p_designacao VARCHAR(45),
    IN p_garantia   DATE
)
BEGIN
    INSERT INTO `Peca` (`preco`, `designacao`, `garantia`)
    VALUES (p_preco, p_designacao, p_garantia);
    SELECT LAST_INSERT_ID() AS idPeca_inserida, 'Peça inserida com sucesso' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_peca $$
CREATE PROCEDURE sp_update_peca(
    IN p_id         INT,
    IN p_preco      DECIMAL(10,2),
    IN p_designacao VARCHAR(45),
    IN p_garantia   DATE
)
BEGIN
    UPDATE `Peca` SET `preco`=p_preco, `designacao`=p_designacao, `garantia`=p_garantia
    WHERE `idPeca`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Peça ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Peça atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_peca $$
CREATE PROCEDURE sp_delete_peca(IN p_id INT)
BEGIN
    DELETE FROM `Peca` WHERE `idPeca`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Peça ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Peça removida' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: contacto_responsavel
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_contacto_responsavel $$
CREATE PROCEDURE sp_insert_contacto_responsavel(
    IN p_contacto VARCHAR(45),
    IN p_email    VARCHAR(45)
)
BEGIN
    INSERT INTO `contacto_responsavel` (`contacto`, `email`)
    VALUES (p_contacto, p_email);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Contacto de responsável inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_contacto_responsavel $$
CREATE PROCEDURE sp_update_contacto_responsavel(
    IN p_id       INT,
    IN p_contacto VARCHAR(45),
    IN p_email    VARCHAR(45)
)
BEGIN
    UPDATE `contacto_responsavel` SET `contacto`=p_contacto, `email`=p_email
    WHERE `idcontacto_responsavel`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Contacto responsável ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Contacto responsável atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_contacto_responsavel $$
CREATE PROCEDURE sp_delete_contacto_responsavel(IN p_id INT)
BEGIN
    DELETE FROM `contacto_responsavel` WHERE `idcontacto_responsavel`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Contacto responsável ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Contacto responsável removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: contacto_tecnico
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_contacto_tecnico $$
CREATE PROCEDURE sp_insert_contacto_tecnico(
    IN p_contacto VARCHAR(15),
    IN p_email    VARCHAR(45)
)
BEGIN
    INSERT INTO `contacto_tecnico` (`contacto`, `email`)
    VALUES (p_contacto, p_email);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Contacto de técnico inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_contacto_tecnico $$
CREATE PROCEDURE sp_update_contacto_tecnico(
    IN p_id       INT,
    IN p_contacto VARCHAR(15),
    IN p_email    VARCHAR(45)
)
BEGIN
    UPDATE `contacto_tecnico` SET `contacto`=p_contacto, `email`=p_email
    WHERE `idcontacto_tecnico`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Contacto técnico ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Contacto técnico atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_contacto_tecnico $$
CREATE PROCEDURE sp_delete_contacto_tecnico(IN p_id INT)
BEGIN
    DELETE FROM `contacto_tecnico` WHERE `idcontacto_tecnico`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Contacto técnico ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Contacto técnico removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Equipamento_contacto
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_equipamento_contacto $$
CREATE PROCEDURE sp_insert_equipamento_contacto(
    IN p_contacto VARCHAR(15),
    IN p_email    VARCHAR(45)
)
BEGIN
    INSERT INTO `Equipamento_contacto` (`contacto`, `email`)
    VALUES (p_contacto, p_email);
    SELECT LAST_INSERT_ID() AS id_inserido, 'Contacto de equipamento inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_equipamento_contacto $$
CREATE PROCEDURE sp_update_equipamento_contacto(
    IN p_id       INT,
    IN p_contacto VARCHAR(15),
    IN p_email    VARCHAR(45)
)
BEGIN
    UPDATE `Equipamento_contacto` SET `contacto`=p_contacto, `email`=p_email
    WHERE `idEquipamento_contacto`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Contacto equipamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Contacto equipamento atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_equipamento_contacto $$
CREATE PROCEDURE sp_delete_equipamento_contacto(IN p_id INT)
BEGIN
    DELETE FROM `Equipamento_contacto` WHERE `idEquipamento_contacto`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Contacto equipamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Contacto equipamento removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Manutencao
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_manutencao $$
CREATE PROCEDURE sp_insert_manutencao(
    IN p_custo              DECIMAL(10,2),
    IN p_tipo               VARCHAR(45),
    IN p_descricao          VARCHAR(45),
    IN p_data_inicio        DATE,
    IN p_data_fim           DATE,
    IN p_idPeca             INT,
    IN p_idEquipamento      INT
)
BEGIN
    INSERT INTO `Manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `data_fim`,
                               `Peca_idPeca`, `Equipamento_idEquipamento`)
    VALUES (p_custo, p_tipo, p_descricao, p_data_inicio, p_data_fim, p_idPeca, p_idEquipamento);
    SELECT LAST_INSERT_ID() AS id_manutencao_inserida, 'Manutenção inserida' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_manutencao $$
CREATE PROCEDURE sp_update_manutencao(
    IN p_id                 INT,
    IN p_custo              DECIMAL(10,2),
    IN p_tipo               VARCHAR(45),
    IN p_descricao          VARCHAR(45),
    IN p_data_inicio        DATE,
    IN p_data_fim           DATE,
    IN p_idPeca             INT,
    IN p_idEquipamento      INT
)
BEGIN
    UPDATE `Manutencao`
    SET `custo`=p_custo, `tipo`=p_tipo, `descricao`=p_descricao,
        `data_inicio`=p_data_inicio, `data_fim`=p_data_fim,
        `Peca_idPeca`=p_idPeca, `Equipamento_idEquipamento`=p_idEquipamento
    WHERE `id_manutencao`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Manutenção ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Manutenção atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_manutencao $$
CREATE PROCEDURE sp_delete_manutencao(IN p_id INT)
BEGIN
    DELETE FROM `Manutencao` WHERE `id_manutencao`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Manutenção ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Manutenção removida' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Ordem_servico
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_ordem_servico $$
CREATE PROCEDURE sp_insert_ordem_servico(
    IN p_descricao    VARCHAR(45),
    IN p_estado_atual VARCHAR(45),
    IN p_prioridade   VARCHAR(45),
    IN p_id_manutencao INT
)
BEGIN
    INSERT INTO `Ordem_servico` (`descricao`, `estado_atual`, `prioridade`, `Manutencao_id_manutencao`)
    VALUES (p_descricao, p_estado_atual, p_prioridade, p_id_manutencao);
    SELECT LAST_INSERT_ID() AS idOrdem_inserida, 'Ordem de serviço inserida' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_ordem_servico $$
CREATE PROCEDURE sp_update_ordem_servico(
    IN p_id           INT,
    IN p_descricao    VARCHAR(45),
    IN p_estado_atual VARCHAR(45),
    IN p_prioridade   VARCHAR(45)
)
BEGIN
    UPDATE `Ordem_servico` SET `descricao`=p_descricao, `estado_atual`=p_estado_atual,
                               `prioridade`=p_prioridade
    WHERE `idOrdem`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Ordem ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Ordem de serviço atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_ordem_servico $$
CREATE PROCEDURE sp_delete_ordem_servico(IN p_id INT)
BEGIN
    DELETE FROM `Ordem_servico` WHERE `idOrdem`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Ordem ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Ordem de serviço removida' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Responsavel
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_responsavel $$
CREATE PROCEDURE sp_insert_responsavel(
    IN p_nome                              VARCHAR(45),
    IN p_data_nascimento                   DATE,
    IN p_idOrdem                           INT,
    IN p_idcontacto_responsavel            INT
)
BEGIN
    INSERT INTO `Responsavel` (`nome`, `data_nascimento`,
                                `Ordem_de_servico_idOrdem`,
                                `contacto_responsavel_idcontacto_responsavel`)
    VALUES (p_nome, p_data_nascimento, p_idOrdem, p_idcontacto_responsavel);
    SELECT LAST_INSERT_ID() AS idResponsavel_inserido, 'Responsável inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_responsavel $$
CREATE PROCEDURE sp_update_responsavel(
    IN p_id              INT,
    IN p_nome            VARCHAR(45),
    IN p_data_nascimento DATE
)
BEGIN
    UPDATE `Responsavel` SET `nome`=p_nome, `data_nascimento`=p_data_nascimento
    WHERE `idResponsavel`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Responsável ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Responsável atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_responsavel $$
CREATE PROCEDURE sp_delete_responsavel(IN p_id INT)
BEGIN
    DELETE FROM `Responsavel` WHERE `idResponsavel`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Responsável ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Responsável removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Departamento
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_departamento $$
CREATE PROCEDURE sp_insert_departamento(
    IN p_designacao  VARCHAR(45),
    IN p_descricao   VARCHAR(45),
    IN p_idResponsavel INT
)
BEGIN
    INSERT INTO `Departamento` (`designacao`, `descricao`, `idResponsavel`)
    VALUES (p_designacao, p_descricao, p_idResponsavel);
    SELECT LAST_INSERT_ID() AS idDepartamento_inserido, 'Departamento inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_departamento $$
CREATE PROCEDURE sp_update_departamento(
    IN p_id          INT,
    IN p_designacao  VARCHAR(45),
    IN p_descricao   VARCHAR(45),
    IN p_idResponsavel INT
)
BEGIN
    UPDATE `Departamento` SET `designacao`=p_designacao, `descricao`=p_descricao,
                              `idResponsavel`=p_idResponsavel
    WHERE `idDepartamento`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Departamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Departamento atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_departamento $$
CREATE PROCEDURE sp_delete_departamento(IN p_id INT)
BEGIN
    DELETE FROM `Departamento` WHERE `idDepartamento`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Departamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Departamento removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Localizacao
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_localizacao $$
CREATE PROCEDURE sp_insert_localizacao(
    IN p_descricao            VARCHAR(45),
    IN p_sala                 VARCHAR(45),
    IN p_piso                 VARCHAR(45),
    IN p_edificio             VARCHAR(45),
    IN p_idDepartamento       INT
)
BEGIN
    INSERT INTO `Localizacao` (`descricao`, `sala`, `piso`, `edificio`, `Departamento_idDepartamento`)
    VALUES (p_descricao, p_sala, p_piso, p_edificio, p_idDepartamento);
    SELECT LAST_INSERT_ID() AS idLocalizacao_inserida, 'Localização inserida' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_localizacao $$
CREATE PROCEDURE sp_update_localizacao(
    IN p_id       INT,
    IN p_descricao VARCHAR(45),
    IN p_sala     VARCHAR(45),
    IN p_piso     VARCHAR(45),
    IN p_edificio VARCHAR(45)
)
BEGIN
    UPDATE `Localizacao` SET `descricao`=p_descricao, `sala`=p_sala,
                             `piso`=p_piso, `edificio`=p_edificio
    WHERE `idLocalizacao`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Localização ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Localização atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_localizacao $$
CREATE PROCEDURE sp_delete_localizacao(IN p_id INT)
BEGIN
    DELETE FROM `Localizacao` WHERE `idLocalizacao`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Localização ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Localização removida' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Tecnico
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_tecnico $$
CREATE PROCEDURE sp_insert_tecnico(
    IN p_data_inicio_carreira VARCHAR(45),
    IN p_nome                 VARCHAR(45),
    IN p_especialidade        VARCHAR(45),
    IN p_idcontacto_tecnico   INT
)
BEGIN
    INSERT INTO `Tecnico` (`data_inicio_carreira`, `nome`, `especialidade`,
                            `contacto_tecnico_idcontacto_tecnico`)
    VALUES (p_data_inicio_carreira, p_nome, p_especialidade, p_idcontacto_tecnico);
    SELECT LAST_INSERT_ID() AS idTecnico_inserido, 'Técnico inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_tecnico $$
CREATE PROCEDURE sp_update_tecnico(
    IN p_id                   INT,
    IN p_data_inicio_carreira VARCHAR(45),
    IN p_nome                 VARCHAR(45),
    IN p_especialidade        VARCHAR(45)
)
BEGIN
    UPDATE `Tecnico` SET `data_inicio_carreira`=p_data_inicio_carreira,
                         `nome`=p_nome, `especialidade`=p_especialidade
    WHERE `idTecnico`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Técnico ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Técnico atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_tecnico $$
CREATE PROCEDURE sp_delete_tecnico(IN p_id INT)
BEGIN
    DELETE FROM `Tecnico` WHERE `idTecnico`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Técnico ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Técnico removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Equipamento
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_equipamento $$
CREATE PROCEDURE sp_insert_equipamento(
    IN p_estado                              VARCHAR(45),
    IN p_descricao                           VARCHAR(45),
    IN p_fabricante                          VARCHAR(45),
    IN p_designacao                          VARCHAR(45),
    IN p_data_aquisicao                      DATE,
    IN p_idEquipamento_contacto              INT,
    IN p_idDepartamento                      INT,
    IN p_idLocalizacao                       INT
)
BEGIN
    INSERT INTO `Equipamento` (`estado`, `descricao`, `fabricante`, `designacao`, `data_aquisicao`,
                                `Equipamento_contacto_idEquipamento_contacto1`,
                                `Departamento_idDepartamento`,
                                `Localizacao_idLocalizacao`)
    VALUES (p_estado, p_descricao, p_fabricante, p_designacao, p_data_aquisicao,
            p_idEquipamento_contacto, p_idDepartamento, p_idLocalizacao);
    SELECT LAST_INSERT_ID() AS idEquipamento_inserido, 'Equipamento inserido' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_equipamento $$
CREATE PROCEDURE sp_update_equipamento(
    IN p_id         INT,
    IN p_estado     VARCHAR(45),
    IN p_descricao  VARCHAR(45),
    IN p_fabricante VARCHAR(45),
    IN p_designacao VARCHAR(45)
)
BEGIN
    UPDATE `Equipamento` SET `estado`=p_estado, `descricao`=p_descricao,
                             `fabricante`=p_fabricante, `designacao`=p_designacao
    WHERE `idEquipamento`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Equipamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Equipamento atualizado' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_equipamento $$
CREATE PROCEDURE sp_delete_equipamento(IN p_id INT)
BEGIN
    DELETE FROM `Equipamento` WHERE `idEquipamento`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Equipamento ',p_id,' não encontrado') AS mensagem;
    ELSE SELECT 'Equipamento removido' AS mensagem; END IF;
END $$

-- ============================================================
-- CRUD: Intervencao_Tecnico
-- ============================================================
DROP PROCEDURE IF EXISTS sp_insert_intervencao_tecnico $$
CREATE PROCEDURE sp_insert_intervencao_tecnico(
    IN p_cargo            VARCHAR(45),
    IN p_horas_trabalho   INT,
    IN p_idTecnico        INT,
    IN p_id_manutencao    INT
)
BEGIN
    INSERT INTO `Intervencao_Tecnico` (`Cargo`, `horas_trabalho`,
                                        `Tecnico_idTecnico`, `Manutencao_id_manutencao`)
    VALUES (p_cargo, p_horas_trabalho, p_idTecnico, p_id_manutencao);
    SELECT LAST_INSERT_ID() AS idIntervencao_inserida, 'Intervenção de técnico registada' AS mensagem;
END $$

DROP PROCEDURE IF EXISTS sp_update_intervencao_tecnico $$
CREATE PROCEDURE sp_update_intervencao_tecnico(
    IN p_id             INT,
    IN p_cargo          VARCHAR(45),
    IN p_horas_trabalho INT
)
BEGIN
    UPDATE `Intervencao_Tecnico` SET `Cargo`=p_cargo, `horas_trabalho`=p_horas_trabalho
    WHERE `idIntervencao`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Intervenção ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Intervenção atualizada' AS mensagem; END IF;
END $$

DROP PROCEDURE IF EXISTS sp_delete_intervencao_tecnico $$
CREATE PROCEDURE sp_delete_intervencao_tecnico(IN p_id INT)
BEGIN
    DELETE FROM `Intervencao_Tecnico` WHERE `idIntervencao`=p_id;
    IF ROW_COUNT()=0 THEN SELECT CONCAT('Intervenção ',p_id,' não encontrada') AS mensagem;
    ELSE SELECT 'Intervenção removida' AS mensagem; END IF;
END $$

DELIMITER ;

-- ============================================================
-- FIM DO FICHEIRO 02_crud.sql
-- ============================================================
