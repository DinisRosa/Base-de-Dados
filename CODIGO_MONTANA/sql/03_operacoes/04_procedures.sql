-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 03.04: Stored Procedures Avançadas
-- ============================================================

USE `mydb`;

-- ============================================================
-- Procedure: Obter Custo Total de Manutenção por Equipamento
-- ============================================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_custo_total_manutencao_equipamento(
    IN p_equipamento_id INT
)
BEGIN
    SELECT 
        e.idEquipamento,
        e.designacao,
        e.fabricante,
        COUNT(m.id_manutencao) as num_manutencoes,
        SUM(m.custo) as custo_total,
        AVG(m.custo) as custo_medio,
        MIN(m.data_inicio) as primeira_manutencao,
        MAX(m.data_fim) as ultima_manutencao
    FROM `Equipamento` e
    LEFT JOIN `Manutencao` m ON e.idEquipamento = m.Equipamento_idEquipamento
    WHERE e.idEquipamento = p_equipamento_id
    GROUP BY e.idEquipamento, e.designacao, e.fabricante;
END$$
DELIMITER ;

-- ============================================================
-- Procedure: Listar Ordens de Serviço Pendentes
-- ============================================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_listar_ordens_pendentes()
BEGIN
    SELECT 
        o.idOrdem,
        o.descricao,
        o.estado_atual,
        o.prioridade,
        m.tipo,
        m.custo,
        e.designacao as equipamento,
        d.designacao as departamento
    FROM `Ordem_servico` o
    INNER JOIN `Manutencao` m ON o.Manutencao_id_manutencao = m.id_manutencao
    INNER JOIN `Equipamento` e ON m.Equipamento_idEquipamento = e.idEquipamento
    INNER JOIN `Departamento` d ON e.Departamento_idDepartamento = d.idDepartamento
    WHERE o.estado_atual IN ('Agendada', 'Em Progresso')
    ORDER BY 
        CASE WHEN o.prioridade = 'Crítica' THEN 1
             WHEN o.prioridade = 'Alta' THEN 2
             WHEN o.prioridade = 'Normal' THEN 3
             ELSE 4 END,
        o.idOrdem;
END$$
DELIMITER ;

-- ============================================================
-- Procedure: Relatório de Carga de Técnico
-- ============================================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_relatorio_carga_tecnico(
    IN p_tecnico_id INT
)
BEGIN
    SELECT 
        t.idTecnico,
        t.nome,
        t.especialidade,
        COUNT(DISTINCT it.idIntervencao) as num_intervencoes,
        SUM(it.horas_trabalho) as total_horas,
        AVG(it.horas_trabalho) as media_horas_intervencao,
        GROUP_CONCAT(DISTINCT m.tipo) as tipos_manutencao,
        MAX(m.data_fim) as ultima_intervencao
    FROM `Tecnico` t
    LEFT JOIN `Intervencao_Tecnico` it ON t.idTecnico = it.Tecnico_idTecnico
    LEFT JOIN `Manutencao` m ON it.Manutencao_id_manutencao = m.id_manutencao
    WHERE t.idTecnico = p_tecnico_id
    GROUP BY t.idTecnico, t.nome, t.especialidade;
END$$
DELIMITER ;

-- ============================================================
-- Procedure: Dashboard - Resumo Geral do Sistema
-- ============================================================
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_dashboard_geral()
BEGIN
    DECLARE v_total_equipamentos INT;
    DECLARE v_equipamentos_operacionais INT;
    DECLARE v_equipamentos_manutencao INT;
    DECLARE v_custo_total_manutencoes DECIMAL(10,2);
    DECLARE v_num_manutencoes_mes INT;
    DECLARE v_ordens_pendentes INT;
    
    -- Total de Equipamentos
    SELECT COUNT(*) INTO v_total_equipamentos FROM `Equipamento`;
    
    -- Equipamentos Operacionais
    SELECT COUNT(*) INTO v_equipamentos_operacionais 
    FROM `Equipamento` 
    WHERE `estado` = 'Operacional';
    
    -- Equipamentos em Manutenção
    SELECT COUNT(*) INTO v_equipamentos_manutencao 
    FROM `Equipamento` 
    WHERE `estado` IN ('Manutenção Preventiva', 'Manutenção Corretiva');
    
    -- Custo Total de Manutenções
    SELECT COALESCE(SUM(`custo`), 0) INTO v_custo_total_manutencoes 
    FROM `Manutencao`;
    
    -- Manutenções este mês
    SELECT COUNT(*) INTO v_num_manutencoes_mes 
    FROM `Manutencao` 
    WHERE MONTH(`data_inicio`) = MONTH(NOW()) 
    AND YEAR(`data_inicio`) = YEAR(NOW());
    
    -- Ordens Pendentes
    SELECT COUNT(*) INTO v_ordens_pendentes 
    FROM `Ordem_servico` 
    WHERE `estado_atual` IN ('Agendada', 'Em Progresso');
    
    -- Resultado
    SELECT 
        v_total_equipamentos as total_equipamentos,
        v_equipamentos_operacionais as equipamentos_operacionais,
        v_equipamentos_manutencao as equipamentos_em_manutencao,
        v_custo_total_manutencoes as custo_total_manutencoes,
        v_num_manutencoes_mes as manutencoes_este_mes,
        v_ordens_pendentes as ordens_de_servico_pendentes;
END$$
DELIMITER ;

-- ============================================================
-- Fim das Procedures Avançadas
-- ============================================================
