USE `mydb`;
-- =============================================================
-- VIEWS
-- =============================================================

-- ---------------------------------------------------------------
-- VIEW 1: Custo total real por equipamento
-- RF: Gestão de Custos
-- Cruza custo base da Manutencao com preco da Peca associada
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_custo_total_equipamento AS
SELECT
    e.id_equipamento,
    e.designacao                                                AS equipamento,
    e.fabricante,
    e.estado,
    d.designacao                                                AS departamento,
    COUNT(m.id_manutencao)                                      AS total_manutencoes,
    ROUND(SUM(m.custo), 2)                                      AS custo_base_total,
    ROUND(COALESCE(SUM(p.preco), 0), 2)                         AS custo_pecas_total,
    ROUND(SUM(m.custo) + COALESCE(SUM(p.preco), 0), 2)         AS custo_total_real
FROM Equipamento e
JOIN Departamento d     ON e.Departamento_id_departamento  = d.id_departamento
LEFT JOIN Manutencao m  ON m.Equipamento_id_equipamento    = e.id_equipamento
LEFT JOIN Peca p        ON m.Peca_id_peca                  = p.id_peca
GROUP BY e.id_equipamento, e.designacao, e.fabricante, e.estado, d.designacao
ORDER BY custo_total_real DESC;


-- ---------------------------------------------------------------
-- VIEW 2: Estado de garantia das peças usadas em manutenções
-- RF: Gestão de Garantias de Componentes
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_garantia_pecas AS
SELECT
    m.id_manutencao,
    m.data_inicio                       AS data_manutencao,
    m.data_fim                          AS data_conclusao,
    e.designacao                        AS equipamento,
    e.fabricante,
    d.designacao                        AS departamento,
    p.id_peca,
    p.designacao                        AS peca,
    p.preco,
    p.garantia                          AS garantia_fim,
    CASE
        WHEN p.garantia >= CURDATE() THEN 'Em garantia'
        ELSE 'Fora de garantia'
    END                                 AS estado_garantia,
    DATEDIFF(p.garantia, CURDATE())     AS dias_restantes_garantia
FROM Manutencao m
JOIN Equipamento e  ON m.Equipamento_id_equipamento   = e.id_equipamento
JOIN Departamento d ON e.Departamento_id_departamento  = d.id_departamento
JOIN Peca p         ON m.Peca_id_peca                  = p.id_peca
ORDER BY p.garantia ASC;


-- ---------------------------------------------------------------
-- VIEW 3: Rastreabilidade completa de intervenções técnicas
-- RF: Rastreabilidade de Intervenções Técnicas
-- Quem interveio, em que equipamento, com que cargo e horas
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_rastreabilidade_intervencoes AS
SELECT
    e.id_equipamento,
    e.designacao                        AS equipamento,
    e.fabricante,
    d.designacao                        AS departamento,
    l.edificio,
    l.piso,
    l.sala,
    m.id_manutencao,
    m.tipo                              AS tipo_manutencao,
    m.descricao                         AS descricao_manutencao,
    m.data_inicio,
    m.data_fim,
    m.custo,
    t.id_tecnico,
    t.nome                              AS tecnico,
    t.especialidade,
    it.Cargo,
    it.horas_trabalho,
    calcular_experiencia_tecnico(t.id_tecnico) AS anos_experiencia_tecnico
FROM Intervencao_Tecnico it
JOIN Tecnico t      ON it.Tecnico_id_tecnico          = t.id_tecnico
JOIN Manutencao m   ON it.Manutencao_id_manutencao     = m.id_manutencao
JOIN Equipamento e  ON m.Equipamento_id_equipamento    = e.id_equipamento
JOIN Departamento d ON e.Departamento_id_departamento   = d.id_departamento
JOIN Localizacao l  ON e.Localizacao_id_localizacao     = l.id_localizacao
ORDER BY e.id_equipamento, m.data_inicio DESC;


-- ---------------------------------------------------------------
-- VIEW 4: Downtime (tempo de paragem) por equipamento
-- RF: Gestão de Tempos de Paragem
-- Usa a function calcular_duracao_manutencao internamente
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_downtime_equipamentos AS
SELECT
    e.id_equipamento,
    e.designacao                                            AS equipamento,
    e.fabricante,
    e.estado,
    d.designacao                                            AS departamento,
    calcular_idade_equipamento(e.id_equipamento)            AS idade_anos,
    COUNT(m.id_manutencao)                                  AS total_manutencoes,
    SUM(DATEDIFF(
        COALESCE(m.data_fim, CURDATE()), m.data_inicio
    ))                                                      AS dias_paragem_total,
    ROUND(AVG(DATEDIFF(
        COALESCE(m.data_fim, CURDATE()), m.data_inicio
    )), 1)                                                  AS media_dias_por_manutencao,
    MAX(m.data_inicio)                                      AS inicio_ultima_paragem,
    MAX(m.data_fim)                                         AS fim_ultima_paragem
FROM Equipamento e
JOIN Departamento d    ON e.Departamento_id_departamento = d.id_departamento
LEFT JOIN Manutencao m ON m.Equipamento_id_equipamento   = e.id_equipamento
GROUP BY e.id_equipamento, e.designacao, e.fabricante, e.estado, d.designacao
ORDER BY dias_paragem_total DESC;


-- ---------------------------------------------------------------
-- VIEW 5: Localização atual de todos os equipamentos
-- RF: Localização em Tempo Real
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_localizacao_equipamentos AS
SELECT
    e.id_equipamento,
    e.designacao                        AS equipamento,
    e.fabricante,
    e.estado,
    d.designacao                        AS departamento,
    r.nome                              AS responsavel_departamento,
    l.edificio,
    l.piso,
    l.sala,
    l.descricao                         AS descricao_localizacao,
    obter_localizacao_equipamento(e.id_equipamento) AS localizacao_completa
FROM Equipamento e
JOIN Departamento d  ON e.Departamento_id_departamento = d.id_departamento
JOIN Localizacao l   ON e.Localizacao_id_localizacao    = l.id_localizacao
JOIN Responsavel r   ON d.id_responsavel                = r.id_responsavel
ORDER BY d.designacao, e.designacao;


-- ---------------------------------------------------------------
-- VIEW 6: Ordens de serviço abertas com detalhe completo
-- RF: Gestão de Ordens de Serviço
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_ordens_abertas AS
SELECT
    os.id_ordem,
    os.prioridade,
    os.estado_atual,
    os.descricao                        AS descricao_ordem,
    m.tipo                              AS tipo_manutencao,
    m.data_inicio,
    DATEDIFF(CURDATE(), m.data_inicio)  AS dias_em_aberto,
    e.designacao                        AS equipamento,
    e.estado                            AS estado_equipamento,
    d.designacao                        AS departamento,
    l.edificio, l.piso, l.sala
FROM Ordem_servico os
JOIN Manutencao m   ON os.Manutencao_id_manutencao    = m.id_manutencao
JOIN Equipamento e  ON m.Equipamento_id_equipamento   = e.id_equipamento
JOIN Departamento d ON e.Departamento_id_departamento  = d.id_departamento
JOIN Localizacao l  ON e.Localizacao_id_localizacao    = l.id_localizacao
WHERE os.estado_atual NOT IN ('Concluida', 'Cancelada')
ORDER BY FIELD(os.prioridade, 'Alta', 'Media', 'Baixa');


-- ---------------------------------------------------------------
-- VIEW 7: Resumo de técnicos — intervenções e horas
-- RF: Rastreabilidade / Gestão de Recursos
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_tecnico_resumo AS
SELECT
    t.id_tecnico,
    t.nome                                          AS tecnico,
    t.especialidade,
    calcular_experiencia_tecnico(t.id_tecnico)      AS anos_experiencia,
    COUNT(it.id_intervencao)                        AS total_intervencoes,
    ROUND(SUM(it.horas_trabalho), 1)                AS total_horas,
    ROUND(AVG(it.horas_trabalho), 1)                AS media_horas_por_intervencao
FROM Tecnico t
LEFT JOIN Intervencao_Tecnico it ON it.Tecnico_id_tecnico = t.id_tecnico
GROUP BY t.id_tecnico, t.nome, t.especialidade
ORDER BY total_horas DESC;


-- ---------------------------------------------------------------
-- VIEW 8: Custo por departamento
-- RF: Gestão de Custos / Relatório Financeiro
-- ---------------------------------------------------------------
CREATE OR REPLACE VIEW vw_custos_por_departamento AS
SELECT
    d.designacao                            AS departamento,
    r.nome                                  AS responsavel,
    COUNT(DISTINCT e.id_equipamento)        AS total_equipamentos,
    COUNT(m.id_manutencao)                  AS total_manutencoes,
    ROUND(SUM(m.custo), 2)                  AS custo_base_total,
    ROUND(COALESCE(SUM(p.preco), 0), 2)     AS custo_pecas_total,
    ROUND(SUM(m.custo) + COALESCE(SUM(p.preco), 0), 2) AS custo_total,
    ROUND(AVG(m.custo), 2)                  AS custo_medio_manutencao
FROM Departamento d
JOIN Responsavel r     ON d.id_responsavel                  = r.id_responsavel
JOIN Equipamento e     ON e.Departamento_id_departamento    = d.id_departamento
LEFT JOIN Manutencao m ON m.Equipamento_id_equipamento      = e.id_equipamento
LEFT JOIN Peca p       ON m.Peca_id_peca                    = p.id_peca
GROUP BY d.id_departamento, d.designacao, r.nome
ORDER BY custo_total DESC;



