-- Povoamento para modelo_fisico_uniforme.sql
-- Ordem de insercao alinhada com as FKs do esquema mydb_uniforme

USE `mydb_uniforme`;

-- 1) peca
INSERT INTO `peca` (`preco`, `designacao`, `garantia`) VALUES
  (50.00,  'Cabo ECG',             '2027-12-31'),
  (120.00, 'Filtro de ar',         '2026-06-30'),
  (200.00, 'Resistencia Eletrica', '2028-03-31');

-- 2) responsavel
-- ordem_servico_id ainda nao tem FK ativa no modelo uniforme
INSERT INTO `responsavel` (`nome`, `data_nascimento`, `ordem_servico_id`) VALUES
  ('Dr. Joao Silva',      '1970-05-15', 1),
  ('Dra. Maria Santos',   '1975-08-20', 2),
  ('Dr. Carlos Oliveira', '1968-03-10', 3);

-- 3) contacto_responsavel (FK para responsavel)
INSERT INTO `contacto_responsavel` (`telefone`, `email`, `responsavel_id`) VALUES
  ('915555001', 'joao.silva@hospital.pt', 1),
  ('915555002', 'maria.santos@hospital.pt', 2),
  ('915555003', 'carlos.oliveira@hospital.pt', 3);

-- 4) departamento (FK para responsavel)
INSERT INTO `departamento` (`nome`, `descricao`, `responsavel_id`) VALUES
  ('Cardiologia', 'Departamento de Cardiologia', 1),
  ('Radiologia',  'Departamento de Radiologia',  2),
  ('Cirurgia',    'Departamento de Cirurgia',    3);

-- 5) localizacao (FK para departamento)
INSERT INTO `localizacao` (`descricao`, `sala`, `piso`, `edificio`, `departamento_id`) VALUES
  ('Sala ECG Cardiologia',    '101', '1', 'Bloco A', 1),
  ('Sala TAC Radiologia',     '202', '2', 'Bloco B', 2),
  ('Sala Cirurgia Principal', '301', '3', 'Bloco A', 3);

-- 6) tecnico
INSERT INTO `tecnico` (`data_inicio_carreira`, `nome`, `especialidade`) VALUES
  ('2010-01-10', 'Tecnico Pedro', 'Equipamentos Cardiacos'),
  ('2015-05-15', 'Tecnico Ana',   'Imaging'),
  ('2018-03-20', 'Tecnico Bruno', 'Cirurgia');

-- 7) contacto_tecnico (FK para tecnico)
INSERT INTO `contacto_tecnico` (`telefone`, `email`, `tecnico_id`) VALUES
  ('919999001', 'pedro.tec@empresa.pt', 1),
  ('919999002', 'ana.tec@empresa.pt',   2),
  ('919999003', 'bruno.tec@empresa.pt', 3);

-- 8) equipamento (FK para departamento e localizacao)
INSERT INTO `equipamento` (`estado`, `descricao`, `fabricante`, `nome`, `data_aquisicao`, `departamento_id`, `localizacao_id`) VALUES
  ('Operacional',   'Dispositivo para aquisicao de ECG', 'Philips', 'Eletrocardiograma', '2020-01-15', 1, 1),
  ('Operacional',   'Tomografo de Tomografia Computada', 'Siemens', 'Tomografo',         '2018-06-20', 2, 2),
  ('Em Manutencao', 'Bisturi eletrico para cirurgia',    'Erbe',    'Bisturi Eletrico',  '2021-03-10', 3, 3);

-- 9) contacto_equipamento (FK para equipamento)
INSERT INTO `contacto_equipamento` (`telefone`, `email`, `equipamento_id`) VALUES
  ('212345678', 'suporte.ecg@philips.pt', 1),
  ('212345679', 'suporte.ct@siemens.pt',  2),
  ('212345680', 'suporte.bis@erbe.pt',    3);

-- 10) manutencao (FK para peca e equipamento)
INSERT INTO `manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `data_fim`, `peca_id`, `equipamento_id`) VALUES
  (250.00,  'Preventiva', 'Manutencao preventiva do ECG', '2025-05-01', '2025-05-03', 1, 1),
  (1500.00, 'Corretiva',  'Reparacao do tomografo',       '2025-05-05', '2025-05-10', 2, 2),
  (100.00,  'Inspecao',   'Inspecao do bisturi eletrico', '2025-05-02', '2025-05-02', 3, 3);

-- 11) ordem_servico (FK para manutencao)
INSERT INTO `ordem_servico` (`descricao`, `estado_atual`, `prioridade`, `manutencao_id`) VALUES
  ('Manutencao ECG - Sala 101',      'Pendente',    'Normal', 1),
  ('Reparacao Tomografo - Sala 202', 'Em Execucao', 'Alta',   2),
  ('Inspecao Bisturi - Sala 301',    'Concluida',   'Baixa',  3);

-- 12) intervencao_tecnico (FK para tecnico e manutencao)
INSERT INTO `intervencao_tecnico` (`cargo`, `horas_trabalho`, `tecnico_id`, `manutencao_id`) VALUES
  ('Tecnico Responsavel',  4, 1, 1),
  ('Tecnico Especialista', 24, 2, 2),
  ('Tecnico Inspetor',     2, 1, 3);
