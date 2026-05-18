-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 03.02: Operações CRUD
-- ============================================================

USE `mydb`;

-- ============================================================
-- CREATE (Inserção)
-- ============================================================

-- Procedure: Inserir novo Equipamento
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_inserir_equipamento(
    IN p_estado VARCHAR(45),
    IN p_descricao VARCHAR(45),
    IN p_fabricante VARCHAR(45),
    IN p_designacao VARCHAR(45),
    IN p_data_aquisicao DATE,
    IN p_contacto_id INT,
    IN p_departamento_id INT,
    IN p_localizacao_id INT
)
BEGIN
    INSERT INTO `Equipamento` (
        `estado`, `descricao`, `fabricante`, `designacao`, `data_aquisicao`,
        `Equipamento_contacto_idEquipamento_contacto1`, `Departamento_idDepartamento`, `Localizacao_idLocalizacao`
    ) VALUES (
        p_estado, p_descricao, p_fabricante, p_designacao, p_data_aquisicao,
        p_contacto_id, p_departamento_id, p_localizacao_id
    );
    SELECT LAST_INSERT_ID() as idEquipamento_novo;
END$$
DELIMITER ;

-- Procedure: Inserir nova Manutenção
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_inserir_manutencao(
    IN p_custo DECIMAL(10,2),
    IN p_tipo VARCHAR(45),
    IN p_descricao VARCHAR(45),
    IN p_data_inicio DATE,
    IN p_data_fim DATE,
    IN p_peca_id INT,
    IN p_equipamento_id INT
)
BEGIN
    INSERT INTO `Manutencao` (
        `custo`, `tipo`, `descricao`, `data_inicio`, `data_fim`,
        `Peca_idPeca`, `Equipamento_idEquipamento`
    ) VALUES (
        p_custo, p_tipo, p_descricao, p_data_inicio, p_data_fim,
        p_peca_id, p_equipamento_id
    );
    SELECT LAST_INSERT_ID() as idManutencao_novo;
END$$
DELIMITER ;

-- ============================================================
-- READ (Consulta)
-- ============================================================

-- View: Equipamentos com Departamento
CREATE OR REPLACE VIEW vw_equipamentos_departamento AS
SELECT 
    e.idEquipamento,
    e.designacao,
    e.estado,
    e.fabricante,
    d.designacao as departamento,
    l.sala,
    l.piso,
    l.edificio,
    e.data_aquisicao
FROM `Equipamento` e
INNER JOIN `Departamento` d ON e.Departamento_idDepartamento = d.idDepartamento
INNER JOIN `Localizacao` l ON e.Localizacao_idLocalizacao = l.idLocalizacao;

-- View: Manutenções com Equipamento
CREATE OR REPLACE VIEW vw_manutencoes_equipamento AS
SELECT 
    m.id_manutencao,
    m.tipo,
    m.descricao,
    m.custo,
    m.data_inicio,
    m.data_fim,
    e.designacao as equipamento,
    p.designacao as peca,
    DATEDIFF(m.data_fim, m.data_inicio) as dias_intervencao
FROM `Manutencao` m
INNER JOIN `Equipamento` e ON m.Equipamento_idEquipamento = e.idEquipamento
INNER JOIN `Peca` p ON m.Peca_idPeca = p.idPeca;

-- Procedure: Listar Equipamentos por Departamento
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_listar_equipamentos_depto(
    IN p_departamento_id INT
)
BEGIN
    SELECT 
        e.idEquipamento,
        e.designacao,
        e.estado,
        e.fabricante,
        e.data_aquisicao,
        d.designacao as departamento
    FROM `Equipamento` e
    INNER JOIN `Departamento` d ON e.Departamento_idDepartamento = d.idDepartamento
    WHERE d.idDepartamento = p_departamento_id
    ORDER BY e.designacao;
END$$
DELIMITER ;

-- ============================================================
-- UPDATE (Atualização)
-- ============================================================

-- Procedure: Atualizar Estado do Equipamento
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_atualizar_estado_equipamento(
    IN p_equipamento_id INT,
    IN p_novo_estado VARCHAR(45)
)
BEGIN
    UPDATE `Equipamento`
    SET `estado` = p_novo_estado
    WHERE `idEquipamento` = p_equipamento_id;
    
    SELECT ROW_COUNT() as linhas_atualizadas;
END$$
DELIMITER ;

-- Procedure: Atualizar Custo de Manutenção
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_atualizar_custo_manutencao(
    IN p_manutencao_id INT,
    IN p_novo_custo DECIMAL(10,2)
)
BEGIN
    UPDATE `Manutencao`
    SET `custo` = p_novo_custo
    WHERE `id_manutencao` = p_manutencao_id;
    
    SELECT ROW_COUNT() as linhas_atualizadas;
END$$
DELIMITER ;

-- ============================================================
-- DELETE (Eliminação)
-- ============================================================

-- Procedure: Eliminar Equipamento (com validação)
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_eliminar_equipamento(
    IN p_equipamento_id INT,
    OUT p_sucesso INT
)
BEGIN
    DECLARE p_manutencoes_count INT;
    
    SELECT COUNT(*) INTO p_manutencoes_count
    FROM `Manutencao`
    WHERE `Equipamento_idEquipamento` = p_equipamento_id;
    
    IF p_manutencoes_count > 0 THEN
        SET p_sucesso = 0;
        SELECT 'Erro: Existem registos de manutenção associados' as mensagem;
    ELSE
        DELETE FROM `Equipamento` WHERE `idEquipamento` = p_equipamento_id;
        SET p_sucesso = 1;
        SELECT 'Equipamento eliminado com sucesso' as mensagem;
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- Fim das Operações CRUD
-- ============================================================
