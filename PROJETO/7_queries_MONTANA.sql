-- ============================================================================
-- QUERIES
-- ============================================================================

-- ---------------------------------------------------------------
-- RF1: GESTÃO DE CUSTOS
-- ---------------------------------------------------------------

-- Custo total real por equipamento (custo manutenção + custo peça)
SELECT * FROM vw_custo_total_equipamento;

-- Equipamento mais dispendioso em manutenções
SELECT equipamento, fabricante, custo_base_total, custo_pecas_total, custo_total_real
FROM vw_custo_total_equipamento
ORDER BY custo_total_real DESC LIMIT 1;

-- Custo total usando a function diretamente
SELECT e.designacao AS equipamento,
custo_total_manutencoes(e.id_equipamento) AS custo_total_EUR
FROM Equipamento e ORDER BY custo_total_manutencoes(e.id_equipamento) DESC;

-- Relatório financeiro por departamento
SELECT * FROM vw_custos_por_departamento;


-- ---------------------------------------------------------------
-- RF2: GESTÃO DE GARANTIAS
-- ---------------------------------------------------------------

-- Todas as peças e o seu estado de garantia
SELECT * FROM vw_garantia_pecas;

-- Peças JÁ fora de garantia (risco de custo hospitalar)
SELECT equipamento, peca, garantia_fim, dias_restantes_garantia
FROM vw_garantia_pecas
WHERE estado_garantia = 'Fora de garantia';

-- Peças cuja garantia expira nos próximos 365 dias
SELECT equipamento, peca, garantia_fim, dias_restantes_garantia
FROM vw_garantia_pecas
WHERE estado_garantia = 'Em garantia'
  AND dias_restantes_garantia <= 365
ORDER BY dias_restantes_garantia ASC;


-- ---------------------------------------------------------------
-- RF3: RASTREABILIDADE DE INTERVENÇÕES TÉCNICAS
-- ---------------------------------------------------------------

-- Histórico completo de todas as intervenções
SELECT * FROM vw_rastreabilidade_intervencoes;

-- Histórico de intervenções num equipamento específico (ex: Ventilador, id=1)
SELECT tecnico, especialidade, Cargo, horas_trabalho, tipo_manutencao, data_inicio
FROM vw_rastreabilidade_intervencoes
WHERE id_equipamento = 1;

-- Técnico com mais horas no equipamento 1 (responsabilidade em caso de falha)
SELECT tecnico, especialidade, SUM(horas_trabalho) AS total_horas
FROM vw_rastreabilidade_intervencoes
WHERE id_equipamento = 1
GROUP BY tecnico, especialidade
ORDER BY total_horas DESC LIMIT 1;

-- Todos os técnicos e as suas horas acumuladas
SELECT * FROM vw_tecnico_resumo;

-- Anos de experiência de cada técnico (atributo derivado)
SELECT t.nome, t.especialidade, calcular_experiencia_tecnico(t.id_tecnico) AS anos_experiencia
FROM Tecnico t
ORDER BY anos_experiencia DESC;


-- ---------------------------------------------------------------
-- RF4: GESTÃO DE TEMPOS DE PARAGEM (DOWNTIME)
-- ---------------------------------------------------------------

-- Downtime acumulado por equipamento
SELECT * FROM vw_downtime_equipamentos;

-- Duração de cada manutenção em dias (atributo derivado)
SELECT m.id_manutencao, e.designacao AS equipamento, m.tipo, m.data_inicio, m.data_fim, calcular_duracao_manutencao(m.id_manutencao) AS duracao_dias
FROM Manutencao m
JOIN Equipamento e ON m.Equipamento_id_equipamento = e.id_equipamento
ORDER BY duracao_dias DESC;

-- Manutenções ainda em curso (sem data_fim — equipamento parado)
SELECT e.designacao AS equipamento, e.fabricante, m.tipo, m.descricao, m.data_inicio,
DATEDIFF(CURDATE(), m.data_inicio) AS dias_em_paragem
FROM Manutencao m
JOIN Equipamento e ON m.Equipamento_id_equipamento = e.id_equipamento
WHERE m.data_fim IS NULL
ORDER BY dias_em_paragem DESC;

-- Idade de cada equipamento (atributo derivado)
SELECT e.designacao AS equipamento, e.fabricante, e.data_aquisicao, calcular_idade_equipamento(e.id_equipamento) AS idade_anos
FROM Equipamento e
ORDER BY idade_anos DESC;


-- ---------------------------------------------------------------
-- RF5: GESTÃO DE ORDENS DE SERVIÇO
-- ---------------------------------------------------------------

-- Ordens ainda em aberto (Em Curso ou Pendente)
SELECT * FROM vw_ordens_abertas;

-- Ordens de alta prioridade em aberto
SELECT * FROM vw_ordens_abertas WHERE prioridade = 'Alta';

-- Estado atual de todas as ordens com detalhe
SELECT os.id_ordem, os.estado_atual, os.prioridade, os.descricao, m.tipo AS tipo_manutencao, e.designacao        AS equipamento
FROM Ordem_servico os
JOIN Manutencao m  ON os.Manutencao_id_manutencao   = m.id_manutencao
JOIN Equipamento e ON m.Equipamento_id_equipamento   = e.id_equipamento
ORDER BY FIELD(os.prioridade,'Alta','Media','Baixa'), os.estado_atual;


-- ---------------------------------------------------------------
-- RF6: LOCALIZAÇÃO EM TEMPO REAL
-- ---------------------------------------------------------------

-- Localização de todos os equipamentos
SELECT * FROM vw_localizacao_equipamentos;

-- Localização de equipamentos ativos
SELECT * FROM vw_localizacao_equipamentos WHERE estado = 'Operacional';

-- Localização de um equipamento específico usando a function
SELECT obter_localizacao_equipamento(1) AS localizacao_ventilador;
SELECT obter_localizacao_equipamento(3) AS localizacao_monitor;

-- Todos os equipamentos com a sua localização completa
SELECT e.designacao AS equipamento, e.estado, obter_localizacao_equipamento(e.id_equipamento) AS localizacao
FROM Equipamento e;


-- ---------------------------------------------------------------
-- RF7: VERIFICAÇÃO DE ESTADO (Integridade Referencial)
-- ---------------------------------------------------------------

-- Verificar se equipamento tem manutenção ativa antes de qualquer operação
SELECT e.id_equipamento, e.designacao, e.estado, equipamento_tem_manutencao_ativa(e.id_equipamento) AS tem_manutencao_ativa
FROM Equipamento e;

-- Equipamentos que PODEM ser abatidos (sem manutenção ativa)
SELECT e.id_equipamento, e.designacao, e.estado
FROM Equipamento e
WHERE equipamento_tem_manutencao_ativa(e.id_equipamento) = 0
  AND e.estado != 'Abatido';

-- Equipamentos que NÃO podem ser abatidos (manutenção ativa em curso)
SELECT e.id_equipamento, e.designacao, e.estado
FROM Equipamento e
WHERE equipamento_tem_manutencao_ativa(e.id_equipamento) = 1;


-- ---------------------------------------------------------------
-- QUERY COMBINADA: Painel geral de gestão (para a apresentação)
-- Resume o estado de toda a frota de equipamentos
-- ---------------------------------------------------------------
SELECT e.id_equipamento, e.designacao AS equipamento, e.fabricante, e.estado, d.designacao
AS departamento, obter_localizacao_equipamento(e.id_equipamento)
AS localizacao, calcular_idade_equipamento(e.id_equipamento)
AS idade_anos, calcular_duracao_manutencao(
(SELECT id_manutencao FROM Manutencao
WHERE Equipamento_id_equipamento = e.id_equipamento
ORDER BY data_inicio DESC LIMIT 1)
)
AS duracao_ultima_manutencao_dias, custo_total_manutencoes(e.id_equipamento) AS custo_total_EUR, equipamento_tem_manutencao_ativa(e.id_equipamento)      AS em_manutencao_ativa
FROM Equipamento e
JOIN Departamento d ON e.Departamento_id_departamento = d.id_departamento
ORDER BY d.designacao, e.designacao;



