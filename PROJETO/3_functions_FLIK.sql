-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- ============================================================================
-- FUNÇÃO 1: Calcular idade do equipamento (atributo derivado)
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS calcular_idade_equipamento$$
CREATE FUNCTION calcular_idade_equipamento(p_id_equipamento INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE anos INT;
    SELECT TIMESTAMPDIFF(YEAR, data_aquisicao, CURDATE())
    INTO anos
    FROM Equipamento
    WHERE id_equipamento = p_id_equipamento;
    RETURN anos;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 2: Calcular duração de uma manutenção em dias (atributo derivado)
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS calcular_duracao_manutencao$$
CREATE FUNCTION calcular_duracao_manutencao(p_id_manutencao INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE dias INT;
    SELECT DATEDIFF(data_fim, data_inicio)
    INTO dias
    FROM Manutencao
    WHERE id_manutencao = p_id_manutencao;
    RETURN dias;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 3: Calcular anos de experiência do técnico (atributo derivado)
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS calcular_experiencia_tecnico$$
CREATE FUNCTION calcular_experiencia_tecnico(p_id_tecnico INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE anos INT;
    SELECT TIMESTAMPDIFF(YEAR, data_inicio_carreira, CURDATE())
    INTO anos
    FROM Tecnico
    WHERE id_tecnico = p_id_tecnico;
    RETURN anos;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 4: Verificar se equipamento tem manutenções ativas
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS equipamento_tem_manutencao_ativa$$
CREATE FUNCTION equipamento_tem_manutencao_ativa(p_id_equipamento INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*)
    INTO total
    FROM Manutencao m
    JOIN Ordem_servico o ON o.Manutencao_id_manutencao = m.id_manutencao
    WHERE m.Equipamento_id_equipamento = p_id_equipamento
      AND o.estado_atual NOT IN ('Concluida', 'Cancelada');
    RETURN total > 0;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 5: Obter localização completa de um equipamento
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS obter_localizacao_equipamento$$
CREATE FUNCTION obter_localizacao_equipamento(p_id_equipamento INT)
RETURNS VARCHAR(150)
DETERMINISTIC
BEGIN
    DECLARE resultado VARCHAR(150);
    SELECT CONCAT('Edificio: ', l.edificio, ' | Piso: ', l.piso, ' | Sala: ', l.sala)
    INTO resultado
    FROM Equipamento e
    JOIN Localizacao l ON l.id_localizacao = e.Localizacao_id_localizacao
    WHERE e.id_equipamento = p_id_equipamento;
    RETURN resultado;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 6: Calcular custo total de manutenções de um equipamento
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS custo_total_manutencoes$$
CREATE FUNCTION custo_total_manutencoes(p_id_equipamento INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT COALESCE(SUM(custo), 0)
    INTO total
    FROM Manutencao
    WHERE Equipamento_id_equipamento = p_id_equipamento;
    RETURN total;
END$$
DELIMITER ;










