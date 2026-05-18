-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 07: Views para Relatórios
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: mod_conceptual_novas_modificacoes (Sem EQUIPAMENTO_DEPARTAMENTO)
-- ============================================================

USE gestao_equipamentos;

-- ============================================================
-- VIEW 1: Equipamentos com informação completa
-- (localização, departamento, idade derivada, estado, estado_atual, garantia)
-- Agora usa FK direto em EQUIPAMENTO.id_departamento
-- ============================================================
DROP VIEW IF EXISTS vw_equipamentos_completo;
CREATE VIEW vw_equipamentos_completo AS
SELECT
    e.id_equipamento,
    e.designacao,
    e.fabricante,
    e.estado,
    e.estado_atual,
    e.garantia,
    e.data_aquisicao,
    TIMESTAMPDIFF(YEAR, e.data_aquisicao, CURDATE())          AS idade_anos,
    l.sala,
    l.piso,
    l.edificio,
    d.designacao                                              AS departamento
FROM EQUIPAMENTO e
LEFT JOIN LOCALIZACAO l   ON e.id_localizacao  = l.id_localizacao
LEFT JOIN DEPARTAMENTO d  ON e.id_departamento = d.id_departamento
ORDER BY e.designacao;

-- ============================================================
-- VIEW 2: Manutenções em curso (sem data de fim)
-- Atualizado para incluir duracao e horas_trabalho
-- ============================================================
DROP VIEW IF EXISTS vw_manutencoes_em_curso;
CREATE VIEW vw_manutencoes_em_curso AS
SELECT
    m.id_manutencao,
    m.tipo,
    m.data_inicio,
    DATEDIFF(CURDATE(), m.data_inicio) AS dias_em_curso,
    m.duracao,
    m.horas_trabalho,
    m.descricao,
    m.custo,
    e.id_equipamento,
    e.designacao                       AS equipamento,
    e.fabricante,
    l.sala,
    l.edificio
FROM MANUTENCAO m
JOIN EQUIPAMENTO e      ON m.id_equipamento  = e.id_equipamento
LEFT JOIN LOCALIZACAO l ON e.id_localizacao  = l.id_localizacao
WHERE m.data_fim IS NULL
ORDER BY m.data_inicio ASC;

-- ============================================================
-- VIEW 3: Técnicos com intervenções e horas totais
-- Atualizado para considerar anos_experiencia da tabela
-- ============================================================
DROP VIEW IF EXISTS vw_tecnicos_intervencoes;
CREATE VIEW vw_tecnicos_intervencoes AS
SELECT
    t.id_tecnico,
    t.nome,
    t.especialidade,
    CASE 
        WHEN t.anos_experiencia > 0 THEN t.anos_experiencia
        ELSE TIMESTAMPDIFF(YEAR, t.data_inicio_carreira, CURDATE())
    END AS anos_experiencia,
    COUNT(it.id_intervencao)                               AS total_intervencoes,
    COALESCE(SUM(it.horas_trabalho), 0)                    AS total_horas_trabalho
FROM TECNICO t
LEFT JOIN INTERVENCAO_TECNICO it ON t.id_tecnico = it.id_tecnico
GROUP BY t.id_tecnico, t.nome, t.especialidade, t.anos_experiencia, t.data_inicio_carreira
ORDER BY total_intervencoes DESC;

-- ============================================================
-- VIEW 4: Histórico completo de manutenções por equipamento
-- Atualizado para incluir duracao e horas_trabalho
-- ============================================================
DROP VIEW IF EXISTS vw_historico_manutencoes;
CREATE VIEW vw_historico_manutencoes AS
SELECT
    e.id_equipamento,
    e.designacao                        AS equipamento,
    e.fabricante,
    m.id_manutencao,
    m.tipo                              AS tipo_manutencao,
    m.data_inicio,
    m.data_fim,
    COALESCE(m.duracao, DATEDIFF(m.data_fim, m.data_inicio)) AS duracao_dias,
    m.horas_trabalho,
    m.custo,
    m.descricao,
    GROUP_CONCAT(DISTINCT t.nome ORDER BY t.nome SEPARATOR ', ') AS tecnicos
FROM EQUIPAMENTO e
JOIN MANUTENCAO m ON e.id_equipamento = m.id_equipamento
LEFT JOIN INTERVENCAO_TECNICO it ON m.id_manutencao = it.id_manutencao
LEFT JOIN TECNICO t              ON it.id_tecnico    = t.id_tecnico
GROUP BY e.id_equipamento, e.designacao, e.fabricante,
         m.id_manutencao, m.tipo, m.data_inicio, m.data_fim, m.duracao, m.horas_trabalho, m.custo, m.descricao
ORDER BY e.id_equipamento, m.data_inicio;

-- ============================================================
-- VIEW 5: Ordens de serviço pendentes ou em execução
-- Atualizado para incluir estado_atual do equipamento
-- ============================================================
DROP VIEW IF EXISTS vw_ordens_pendentes;
CREATE VIEW vw_ordens_pendentes AS
SELECT
    os.id_ordem,
    os.prioridade,
    os.estado_atual,
    os.data_criacao,
    DATEDIFF(CURDATE(), os.data_criacao) AS dias_aberta,
    os.descricao,
    e.id_equipamento,
    e.designacao                         AS equipamento,
    e.estado                             AS estado_equipamento,
    e.estado_atual                       AS estado_atual_equipamento
FROM ORDEM_SERVICO os
LEFT JOIN MANUTENCAO_ORDEM mo ON os.id_ordem       = mo.id_ordem
LEFT JOIN MANUTENCAO m        ON mo.id_manutencao   = m.id_manutencao
LEFT JOIN EQUIPAMENTO e       ON m.id_equipamento   = e.id_equipamento
WHERE os.estado_atual IN ('Pendente', 'Em Execução')
ORDER BY FIELD(os.prioridade, 'Crítica','Alta','Normal','Baixa'),
         os.data_criacao ASC;

-- ============================================================
-- VIEW 6: Custo total de manutenções por departamento
-- Agora usa relação 1:N (FK em EQUIPAMENTO)
-- ============================================================
DROP VIEW IF EXISTS vw_custo_manutencao_por_dept;
CREATE VIEW vw_custo_manutencao_por_dept AS
SELECT
    d.id_departamento,
    d.designacao                     AS departamento,
    COUNT(DISTINCT e.id_equipamento) AS total_equipamentos,
    COUNT(DISTINCT m.id_manutencao)  AS total_manutencoes,
    COALESCE(SUM(m.custo), 0)        AS custo_total,
    COALESCE(AVG(m.custo), 0)        AS custo_medio
FROM DEPARTAMENTO d
LEFT JOIN EQUIPAMENTO e         ON d.id_departamento = e.id_departamento
LEFT JOIN MANUTENCAO m          ON e.id_equipamento  = m.id_equipamento
GROUP BY d.id_departamento, d.designacao
ORDER BY custo_total DESC;

-- ============================================================
-- VIEW 7: Peças com validade próxima ou expirada
-- Atualizado para incluir custo da peça
-- ============================================================
DROP VIEW IF EXISTS vw_pecas_validade_critica;
CREATE VIEW vw_pecas_validade_critica AS
SELECT
    id_peca,
    designacao,
    preco,
    custo,
    validade_peca,
    DATEDIFF(validade_peca, CURDATE()) AS dias_ate_validade,
    CASE
        WHEN validade_peca < CURDATE()                          THEN 'EXPIRADA'
        WHEN DATEDIFF(validade_peca, CURDATE()) <= 30           THEN 'CRÍTICA'
        WHEN DATEDIFF(validade_peca, CURDATE()) <= 90           THEN 'ATENÇÃO'
        ELSE                                                         'OK'
    END AS estado_validade
FROM PECA
WHERE validade_peca IS NOT NULL
ORDER BY validade_peca ASC;

-- ============================================================
-- VIEW 8: Responsáveis por departamento com permissão aprova
-- ============================================================
DROP VIEW IF EXISTS vw_responsaveis_departamentos;
CREATE VIEW vw_responsaveis_departamentos AS
SELECT
    r.id_responsavel,
    r.nome,
    r.data_nascimento,
    r.aprova,
    d.id_departamento,
    d.designacao                    AS departamento,
    COUNT(DISTINCT e.id_equipamento) AS total_equipamentos,
    GROUP_CONCAT(DISTINCT rc.contacto ORDER BY rc.contacto SEPARATOR ', ') AS contactos
FROM RESPONSAVEL r
JOIN DEPARTAMENTO d              ON r.id_departamento = d.id_departamento
LEFT JOIN EQUIPAMENTO e          ON d.id_departamento = e.id_departamento
LEFT JOIN RESPONSAVEL_CONTACTO rc ON r.id_responsavel = rc.id_responsavel
GROUP BY r.id_responsavel, r.nome, r.data_nascimento, r.aprova, d.id_departamento, d.designacao
ORDER BY d.designacao, r.nome;

-- ============================================================
-- Exemplos de consulta:
-- SELECT * FROM vw_equipamentos_completo;
-- SELECT * FROM vw_manutencoes_em_curso;
-- SELECT * FROM vw_tecnicos_intervencoes;
-- SELECT * FROM vw_historico_manutencoes WHERE id_equipamento = 2;
-- SELECT * FROM vw_ordens_pendentes;
-- SELECT * FROM vw_custo_manutencao_por_dept;
-- SELECT * FROM vw_pecas_validade_critica;
-- SELECT * FROM vw_responsaveis_departamentos;
-- ============================================================

-- ============================================================
-- FIM DO FICHEIRO 07_views.sql
-- ============================================================
