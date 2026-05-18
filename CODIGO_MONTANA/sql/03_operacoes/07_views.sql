-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 07: Views para Relatórios
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: modelo fisico.sql (Montana)
-- ============================================================

USE `mydb`;

-- ============================================================
-- VIEW 1: Equipamentos com informação completa
-- (localização, departamento, idade derivada, estado)
-- ============================================================
DROP VIEW IF EXISTS vw_equipamentos_completo;
CREATE VIEW vw_equipamentos_completo AS
SELECT
    e.`idEquipamento`,
    e.`designacao`,
    e.`fabricante`,
    e.`estado`,
    e.`data_aquisicao`,
    TIMESTAMPDIFF(YEAR, e.`data_aquisicao`, CURDATE()) AS idade_anos,
    l.`sala`,
    l.`piso`,
    l.`edificio`,
    d.`designacao`                                      AS departamento
FROM `Equipamento` e
LEFT JOIN `Localizacao` l   ON e.`Localizacao_idLocalizacao`     = l.`idLocalizacao`
LEFT JOIN `Departamento` d  ON e.`Departamento_idDepartamento`   = d.`idDepartamento`
ORDER BY e.`designacao`;

-- ============================================================
-- VIEW 2: Manutenções em curso (data_fim ainda não passou)
-- ============================================================
DROP VIEW IF EXISTS vw_manutencoes_em_curso;
CREATE VIEW vw_manutencoes_em_curso AS
SELECT
    m.`id_manutencao`,
    m.`tipo`,
    m.`data_inicio`,
    m.`data_fim`,
    DATEDIFF(CURDATE(), m.`data_inicio`) AS dias_em_curso,
    m.`descricao`,
    m.`custo`,
    e.`idEquipamento`,
    e.`designacao`                        AS equipamento,
    e.`fabricante`,
    p.`designacao`                        AS peca_utilizada,
    l.`sala`,
    l.`edificio`
FROM `Manutencao` m
JOIN `Equipamento` e       ON m.`Equipamento_idEquipamento` = e.`idEquipamento`
JOIN `Peca` p              ON m.`Peca_idPeca`               = p.`idPeca`
LEFT JOIN `Localizacao` l  ON e.`Localizacao_idLocalizacao` = l.`idLocalizacao`
WHERE m.`data_fim` >= CURDATE()
ORDER BY m.`data_inicio` ASC;

-- ============================================================
-- VIEW 3: Técnicos com intervenções e horas totais
-- ============================================================
DROP VIEW IF EXISTS vw_tecnicos_intervencoes;
CREATE VIEW vw_tecnicos_intervencoes AS
SELECT
    t.`idTecnico`,
    t.`nome`,
    t.`especialidade`,
    t.`data_início_carreira`,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(t.`data_início_carreira`, '%Y-%m-%d'), CURDATE()) AS anos_carreira,
    COUNT(it.`idIntervencao`)          AS total_intervencoes,
    COALESCE(SUM(it.`horas_trabalho`), 0) AS total_horas_trabalho
FROM `Tecnico` t
LEFT JOIN `Intervencao_Tecnico` it ON t.`idTecnico` = it.`Tecnico_idTecnico`
GROUP BY t.`idTecnico`, t.`nome`, t.`especialidade`, t.`data_início_carreira`
ORDER BY total_intervencoes DESC;

-- ============================================================
-- VIEW 4: Histórico completo de manutenções por equipamento
-- ============================================================
DROP VIEW IF EXISTS vw_historico_manutencoes;
CREATE VIEW vw_historico_manutencoes AS
SELECT
    e.`idEquipamento`,
    e.`designacao`                          AS equipamento,
    e.`fabricante`,
    m.`id_manutencao`,
    m.`tipo`                                AS tipo_manutencao,
    m.`data_inicio`,
    m.`data_fim`,
    DATEDIFF(m.`data_fim`, m.`data_inicio`) AS duracao_dias,
    m.`custo`,
    m.`descricao`,
    p.`designacao`                          AS peca_usada,
    p.`preco`                               AS preco_peca,
    GROUP_CONCAT(DISTINCT tc.`nome` ORDER BY tc.`nome` SEPARATOR ', ') AS tecnicos
FROM `Equipamento` e
JOIN `Manutencao` m           ON e.`idEquipamento`   = m.`Equipamento_idEquipamento`
JOIN `Peca` p                 ON m.`Peca_idPeca`     = p.`idPeca`
LEFT JOIN `Intervencao_Tecnico` it ON m.`id_manutencao` = it.`Manutencao_id_manutencao`
LEFT JOIN `Tecnico` tc             ON it.`Tecnico_idTecnico` = tc.`idTecnico`
GROUP BY e.`idEquipamento`, e.`designacao`, e.`fabricante`,
         m.`id_manutencao`, m.`tipo`, m.`data_inicio`, m.`data_fim`,
         m.`custo`, m.`descricao`, p.`designacao`, p.`preco`
ORDER BY e.`idEquipamento`, m.`data_inicio`;

-- ============================================================
-- VIEW 5: Ordens de serviço pendentes ou em execução
-- ============================================================
DROP VIEW IF EXISTS vw_ordens_pendentes;
CREATE VIEW vw_ordens_pendentes AS
SELECT
    os.`idOrdem`,
    os.`prioridade`,
    os.`estado_atual`,
    os.`descricao`,
    m.`id_manutencao`,
    m.`tipo`                 AS tipo_manutencao,
    m.`data_inicio`,
    m.`data_fim`,
    e.`idEquipamento`,
    e.`designacao`           AS equipamento,
    e.`estado`               AS estado_equipamento
FROM `Ordem_servico` os
JOIN `Manutencao` m    ON os.`Manutencao_id_manutencao` = m.`id_manutencao`
JOIN `Equipamento` e   ON m.`Equipamento_idEquipamento` = e.`idEquipamento`
WHERE os.`estado_atual` IN ('Pendente', 'Em Execução')
ORDER BY FIELD(os.`prioridade`, 'Crítica','Alta','Normal','Baixa');

-- ============================================================
-- VIEW 6: Custo total de manutenções por departamento
-- ============================================================
DROP VIEW IF EXISTS vw_custo_manutencao_por_dept;
CREATE VIEW vw_custo_manutencao_por_dept AS
SELECT
    d.`idDepartamento`,
    d.`designacao`                    AS departamento,
    COUNT(DISTINCT e.`idEquipamento`) AS total_equipamentos,
    COUNT(DISTINCT m.`id_manutencao`) AS total_manutencoes,
    COALESCE(SUM(m.`custo`), 0)       AS custo_total,
    COALESCE(AVG(m.`custo`), 0)       AS custo_medio
FROM `Departamento` d
LEFT JOIN `Equipamento` e  ON d.`idDepartamento`      = e.`Departamento_idDepartamento`
LEFT JOIN `Manutencao` m   ON e.`idEquipamento`        = m.`Equipamento_idEquipamento`
GROUP BY d.`idDepartamento`, d.`designacao`
ORDER BY custo_total DESC;

-- ============================================================
-- VIEW 7: Responsáveis por departamento
-- ============================================================
DROP VIEW IF EXISTS vw_responsaveis_departamentos;
CREATE VIEW vw_responsaveis_departamentos AS
SELECT
    r.`idResponsavel`,
    r.`nome`                          AS responsavel,
    r.`data_nascimento`,
    d.`idDepartamento`,
    d.`designacao`                    AS departamento,
    d.`descricao`                     AS descricao_dept,
    cr.`contacto`,
    cr.`email`
FROM `Responsavel` r
JOIN `contacto_responsavel` cr ON r.`contacto_responsavel_idcontacto_responsavel` = cr.`idcontacto_responsavel`
JOIN `Departamento` d          ON d.`idResponsavel` = r.`idResponsavel`
ORDER BY d.`designacao`, r.`nome`;

-- ============================================================
-- VIEW 8: Peças com garantia expirada ou próxima
-- ============================================================
DROP VIEW IF EXISTS vw_pecas_garantia_critica;
CREATE VIEW vw_pecas_garantia_critica AS
SELECT
    `idPeca`,
    `designacao`,
    `preco`,
    `garantia`,
    DATEDIFF(`garantia`, CURDATE()) AS dias_ate_expiracao,
    CASE
        WHEN `garantia` < CURDATE()                        THEN 'EXPIRADA'
        WHEN DATEDIFF(`garantia`, CURDATE()) <= 30         THEN 'CRÍTICA'
        WHEN DATEDIFF(`garantia`, CURDATE()) <= 90         THEN 'ATENÇÃO'
        ELSE                                                    'OK'
    END AS estado_garantia
FROM `Peca`
ORDER BY `garantia` ASC;

-- ============================================================
-- Exemplos de consulta:
-- SELECT * FROM vw_equipamentos_completo;
-- SELECT * FROM vw_manutencoes_em_curso;
-- SELECT * FROM vw_tecnicos_intervencoes;
-- SELECT * FROM vw_historico_manutencoes WHERE idEquipamento = 1;
-- SELECT * FROM vw_ordens_pendentes;
-- SELECT * FROM vw_custo_manutencao_por_dept;
-- SELECT * FROM vw_responsaveis_departamentos;
-- SELECT * FROM vw_pecas_garantia_critica;
-- ============================================================

-- ============================================================
-- FIM DO FICHEIRO 07_views.sql
-- ============================================================
