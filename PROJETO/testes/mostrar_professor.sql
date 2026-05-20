-- ============================================================
-- SCRIPT DE APRESENTAÇÃO: PROCEDURES E REGRAS DE NEGÓCIO
-- Objetivo: Demonstrar ao professor o domínio de Transações,
-- Triggers em Cascata, Máquinas de Estado e Lógica Avançada.
-- ============================================================

USE `mydb`;

-- ============================================================
-- 1. O FLUXO PRINCIPAL: ORQUESTRAÇÃO E TRIGGERS EM CASCATA
-- ============================================================
-- O que mostrar: A procedure gere o insert básico, mas os 
-- Triggers atuam como "guardiões", mudando o estado do Equipamento.

-- PASSO 1A: Registar uma avaria no equipamento 1 (Muda estado para Em Manutenção)
CALL registar_avaria(1, 1, 'Corretiva', 150.00, 'Falha no visor', 'Alta');

-- (Mostrar ao professor que o equipamento mudou de estado)
SELECT id_equipamento, designacao, estado 
FROM Equipamento WHERE id_equipamento = 1;

-- PASSO 1B: Concluir a manutenção (Trigger fecha Ordem e reativa Equipamento)
-- (Vamos concluir a manutenção ID 4 assumindo que é a que acabou de ser criada)
CALL concluir_manutencao(4);

-- (Mostrar ao professor que o equipamento voltou ao normal e a ordem fechou)
SELECT e.id_equipamento, e.estado AS estado_equipamento, o.id_ordem, o.estado_atual AS estado_ordem
FROM Equipamento e
JOIN Manutencao m ON m.Equipamento_id_equipamento = e.id_equipamento
JOIN Ordem_servico o ON o.Manutencao_id_manutencao = m.id_manutencao
WHERE m.id_manutencao = 4;


-- ============================================================
-- 2. MÁQUINA DE ESTADOS: PROTEÇÃO CONTRA TRANSIÇÕES ILÓGICAS
-- ============================================================
-- O que mostrar: O sistema bloqueia ações sem sentido (ex: reverter 
-- uma ordem já em execução). A inteligência está na BD.

-- PASSO 2A: Sucesso (Mover a Ordem 1 de 'Pendente' para 'Em Execução')
CALL validar_estado_ordem(1, 'Em Execução');

-- PASSO 2B: Erro (Tentar mover a Ordem 1 de volta para 'Pendente')
-- EXPECTATIVA: Vai gerar um ERRO SQL ("Transicao de estado invalida para a ordem.")
CALL validar_estado_ordem(1, 'Pendente');


-- ============================================================
-- 3. BUSINESS INTELLIGENCE: LÓGICA CONDICIONAL E RELATÓRIOS
-- ============================================================
-- O que mostrar: Usar SQL avançado (DATEDIFF, múltiplos SELECTs) 
-- para gerar um painel dinâmico de gestão hospitalar.

-- PASSO 3: Procurar manutenções abertas há mais de 10 dias e ordens atrasadas
CALL listar_alertas(10, 10);


-- ============================================================
-- 4. GESTÃO DE TRANSAÇÕES: ROLLBACK E INTEGRIDADE (TUDO OU NADA)
-- ============================================================
-- O que mostrar: Inserir em múltiplas tabelas (Contacto + Técnico). 
-- Se falhar a meio, o COMMIT não acontece e nada é guardado.

-- PASSO 4A: Sucesso (Cria contacto e técnico em simultâneo)
CALL adicionar_tecnico('2020-01-01', 'João Mecânico', 'Mecânica Fina', '919999888', 'joao.mec@empresa.pt');

-- PASSO 4B: Erro (Nome é NULL, vai causar erro na tabela Tecnico)
-- EXPECTATIVA: O Contacto não pode ser inserido na BD se o Técnico falhar.
CALL adicionar_tecnico('2020-01-01', NULL, 'Mecânica Fina', '919999888', 'joao.mec2@empresa.pt');

