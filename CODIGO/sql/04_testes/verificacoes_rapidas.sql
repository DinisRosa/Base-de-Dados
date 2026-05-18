-- ============================================================
-- VERIFICAÇÕES RÁPIDAS - Consultas Úteis
-- Sistema de Gestão de Equipamentos Médicos
-- ============================================================

USE gestao_equipamentos;

-- ============================================================
-- 1. DASHBOARD - RESUMO EXECUTIVO
-- ============================================================
PRINT '========== DASHBOARD EXECUTIVO ==========';

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'ESTATÍSTICAS GERAIS' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    (SELECT COUNT(*) FROM DEPARTAMENTO) AS total_departamentos,
    (SELECT COUNT(*) FROM EQUIPAMENTO) AS total_equipamentos,
    (SELECT COUNT(*) FROM TECNICO) AS total_tecnicos,
    (SELECT COUNT(*) FROM MANUTENCAO) AS total_manutencoes,
    (SELECT COUNT(*) FROM ORDEM_SERVICO) AS total_ordens,
    (SELECT SUM(custo) FROM MANUTENCAO) AS custo_total_manutencoes;

-- ============================================================
-- 2. EQUIPAMENTOS CRÍTICOS
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'EQUIPAMENTOS FORA DE OPERAÇÃO' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    e.id_equipamento,
    e.designacao,
    e.estado_atual,
    e.fabricante,
    d.designacao AS departamento,
    GROUP_CONCAT(cs.contacto_suporte SEPARATOR '; ') AS contactos
FROM EQUIPAMENTO e
LEFT JOIN DEPARTAMENTO d ON e.id_departamento = d.id_departamento
LEFT JOIN EQUIPAMENTO_CONTACTO_SUPORTE cs ON e.id_equipamento = cs.id_equipamento
WHERE e.estado_atual != 'Operacional'
GROUP BY e.id_equipamento
ORDER BY e.estado_atual;

-- ============================================================
-- 3. MANUTENÇÕES POR DEPARTAMENTO
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'MANUTENÇÕES POR DEPARTAMENTO' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    d.designacao AS departamento,
    COUNT(DISTINCT m.id_manutencao) AS total_manutencoes,
    SUM(m.custo) AS custo_total,
    COUNT(DISTINCT m.id_equipamento) AS equipamentos_mantidos
FROM DEPARTAMENTO d
LEFT JOIN EQUIPAMENTO e ON d.id_departamento = e.id_departamento
LEFT JOIN MANUTENCAO m ON e.id_equipamento = m.id_equipamento
GROUP BY d.id_departamento, d.designacao
ORDER BY custo_total DESC;

-- ============================================================
-- 4. CARGA DE TRABALHO DOS TÉCNICOS
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'CARGA DE TRABALHO - TÉCNICOS' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    t.nome,
    t.especialidade,
    COUNT(DISTINCT it.id_manutencao) AS manutencoes_realizadas,
    ROUND(SUM(it.horas_trabalho), 1) AS horas_totais,
    GROUP_CONCAT(DISTINCT tc.contacto SEPARATOR '; ') AS contactos
FROM TECNICO t
LEFT JOIN INTERVENCAO_TECNICO it ON t.id_tecnico = it.id_tecnico
LEFT JOIN TECNICO_CONTACTO tc ON t.id_tecnico = tc.id_tecnico
GROUP BY t.id_tecnico, t.nome, t.especialidade
ORDER BY horas_totais DESC;

-- ============================================================
-- 5. ORDENS DE SERVIÇO POR STATUS
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'ORDENS DE SERVIÇO POR STATUS' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    estado_atual,
    prioridade,
    COUNT(*) AS total,
    GROUP_CONCAT(id_ordem_servico SEPARATOR ', ') AS ordem_ids
FROM ORDEM_SERVICO
GROUP BY estado_atual, prioridade
ORDER BY 
    CASE estado_atual 
        WHEN 'Pendente' THEN 1
        WHEN 'Em Execução' THEN 2
        WHEN 'Concluída' THEN 3
        ELSE 4
    END,
    CASE prioridade
        WHEN 'Alta' THEN 1
        WHEN 'Normal' THEN 2
        WHEN 'Baixa' THEN 3
        ELSE 4
    END;

-- ============================================================
-- 6. PEÇAS MAIS UTILIZADAS
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'PEÇAS MAIS UTILIZADAS' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    p.designacao,
    SUM(mp.quantidade) AS quantidade_total_usada,
    COUNT(DISTINCT mp.id_manutencao) AS manutencoes_com_peca,
    p.preco,
    ROUND(SUM(mp.quantidade) * p.preco, 2) AS custo_estimado_total
FROM PECA p
LEFT JOIN MANUTENCAO_PECA mp ON p.id_peca = mp.id_peca
GROUP BY p.id_peca, p.designacao, p.preco
ORDER BY quantidade_total_usada DESC;

-- ============================================================
-- 7. GARANTIA - EQUIPAMENTOS FORA DE GARANTIA
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'EQUIPAMENTOS FORA DE GARANTIA' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    e.designacao,
    e.data_aquisicao,
    e.garantia,
    DATE_ADD(e.data_aquisicao, INTERVAL e.garantia MONTH) AS data_fim_garantia,
    DATEDIFF(DATE_ADD(e.data_aquisicao, INTERVAL e.garantia MONTH), CURDATE()) AS dias_ate_vencer,
    d.designacao AS departamento
FROM EQUIPAMENTO e
LEFT JOIN DEPARTAMENTO d ON e.id_departamento = d.id_departamento
WHERE DATE_ADD(e.data_aquisicao, INTERVAL e.garantia MONTH) < DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY dias_ate_vencer ASC;

-- ============================================================
-- 8. RESPONSÁVEIS E SEUS DEPARTAMENTOS
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'RESPONSÁVEIS POR DEPARTAMENTO' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    d.designacao AS departamento,
    r.nome,
    r.aprova,
    GROUP_CONCAT(rc.contacto SEPARATOR '; ') AS contactos,
    COUNT(DISTINCT e.id_equipamento) AS equipamentos_departamento
FROM DEPARTAMENTO d
LEFT JOIN RESPONSAVEL r ON d.id_departamento = r.id_departamento
LEFT JOIN RESPONSAVEL_CONTACTO rc ON r.id_responsavel = rc.id_responsavel
LEFT JOIN EQUIPAMENTO e ON d.id_departamento = e.id_departamento
GROUP BY d.id_departamento, d.designacao, r.id_responsavel, r.nome, r.aprova
ORDER BY d.designacao;

-- ============================================================
-- 9. HISTÓRICO DE AUDITORIA
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'ÚLTIMAS ALTERAÇÕES (Auditoria)' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    id_auditoria,
    id_equipamento,
    operacao,
    descricao_mudanca,
    data_operacao,
    utilizador
FROM AUDITORIA_EQUIPAMENTO
ORDER BY data_operacao DESC
LIMIT 10;

-- ============================================================
-- 10. RELATÓRIO: MANUTENÇÕES EM ABERTO
-- ============================================================
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;
SELECT 'MANUTENÇÕES PENDENTES/EM EXECUÇÃO' AS secao;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separador;

SELECT 
    m.id_manutencao,
    e.designacao AS equipamento,
    m.tipo,
    m.data_inicio,
    m.descricao,
    m.custo,
    GROUP_CONCAT(DISTINCT t.nome SEPARATOR ', ') AS tecnicos_atribuidos,
    os.prioridade
FROM MANUTENCAO m
JOIN EQUIPAMENTO e ON m.id_equipamento = e.id_equipamento
LEFT JOIN INTERVENCAO_TECNICO it ON m.id_manutencao = it.id_manutencao
LEFT JOIN TECNICO t ON it.id_tecnico = t.id_tecnico
LEFT JOIN MANUTENCAO_ORDEM mo ON m.id_manutencao = mo.id_manutencao
LEFT JOIN ORDEM_SERVICO os ON mo.id_ordem = os.id_ordem_servico
WHERE m.data_fim IS NULL OR m.data_fim > CURDATE()
GROUP BY m.id_manutencao
ORDER BY m.data_inicio ASC;

-- ============================================================
-- FIM DAS VERIFICAÇÕES RÁPIDAS
-- ============================================================
