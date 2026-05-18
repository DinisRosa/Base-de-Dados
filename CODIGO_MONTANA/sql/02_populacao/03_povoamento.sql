-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 03: Povoamento de Dados (Exemplos)
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: modelo fisico.sql (Montana)
-- ============================================================
-- ATENÇÃO: Ordem de inserção respeita as dependências de FK:
--   Peca, contacto_responsavel, contacto_tecnico, Equipamento_contacto
--   → Manutencao → Ordem_servico → Responsavel
--   → Departamento → Localizacao
--   → Tecnico → Equipamento → Intervencao_Tecnico
-- ============================================================

USE `mydb`;

-- ============================================================
-- DADOS DE TESTE / EXEMPLO
-- ============================================================

-- ------------------------------------------------------------
-- Peca (sem dependências)
-- ------------------------------------------------------------
INSERT INTO `Peca` (`preco`, `designacao`, `garantia`) VALUES
    (50.00,  'Cabo ECG',             '2027-12-31'),
    (120.00, 'Filtro de ar',         '2026-06-30'),
    (200.00, 'Resistência Elétrica', '2028-03-31');

-- ------------------------------------------------------------
-- contacto_responsavel (sem dependências)
-- ------------------------------------------------------------
INSERT INTO `contacto_responsavel` (`contacto`, `email`) VALUES
    ('915555001', 'joao.silva@hospital.pt'),
    ('915555002', 'maria.santos@hospital.pt'),
    ('915555003', 'carlos.oliveira@hospital.pt');

-- ------------------------------------------------------------
-- contacto_tecnico (sem dependências)
-- ------------------------------------------------------------
INSERT INTO `contacto_tecnico` (`contacto`, `email`) VALUES
    ('919999001', 'pedro.tec@empresa.pt'),
    ('919999002', 'ana.tec@empresa.pt'),
    ('919999003', 'bruno.tec@empresa.pt');

-- ------------------------------------------------------------
-- Equipamento_contacto (sem dependências)
-- ------------------------------------------------------------
INSERT INTO `Equipamento_contacto` (`contacto`, `email`) VALUES
    ('212345678', 'suporte.ecg@philips.pt'),
    ('212345679', 'suporte.ct@siemens.pt'),
    ('212345680', 'suporte.bis@erbe.pt');

-- ------------------------------------------------------------
-- Manutencao (depende de Peca e Equipamento — inserção temporária)
-- NOTA: Equipamento ainda não existe; seguimos a ordem do modelo
--       físico que cria Manutencao → Ordem_servico → Responsavel.
--       Inserimos Manutencao com Equipamento_idEquipamento = 1,2,3
--       (serão criados a seguir e terão esses IDs auto_increment).
-- ------------------------------------------------------------
INSERT INTO `Manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `data_fim`,
                           `Peca_idPeca`, `Equipamento_idEquipamento`) VALUES
    (250.00,  'Preventiva', 'Manutenção preventiva do ECG',    '2025-05-01', '2025-05-03', 1, 1),
    (1500.00, 'Corretiva',  'Reparação do tomógrafo',          '2025-05-05', '2025-05-10', 2, 2),
    (100.00,  'Inspeção',   'Inspeção do bisturi elétrico',    '2025-05-02', '2025-05-02', 3, 3);

-- ------------------------------------------------------------
-- Ordem_servico (depende de Manutencao)
-- ------------------------------------------------------------
INSERT INTO `Ordem_servico` (`descricao`, `estado_atual`, `prioridade`,
                              `Manutencao_id_manutencao`) VALUES
    ('Manutenção ECG - Sala 101',       'Pendente',    'Normal', 1),
    ('Reparação Tomógrafo - Sala 202',  'Em Execução', 'Alta',   2),
    ('Inspeção Bisturi - Sala 301',     'Concluída',   'Baixa',  3);

-- ------------------------------------------------------------
-- Responsavel (depende de Ordem_servico e contacto_responsavel)
-- ------------------------------------------------------------
INSERT INTO `Responsavel` (`nome`, `data_nascimento`,
                            `Ordem_de_servico_idOrdem`,
                            `contacto_responsavel_idcontacto_responsavel`) VALUES
    ('Dr. João Silva',       '1970-05-15', 1, 1),
    ('Dra. Maria Santos',    '1975-08-20', 2, 2),
    ('Dr. Carlos Oliveira',  '1968-03-10', 3, 3);

-- ------------------------------------------------------------
-- Departamento (depende de Responsavel)
-- ------------------------------------------------------------
INSERT INTO `Departamento` (`designacao`, `descricao`, `idResponsavel`) VALUES
    ('Cardiologia', 'Departamento de Cardiologia', 1),
    ('Radiologia',  'Departamento de Radiologia',  2),
    ('Cirurgia',    'Departamento de Cirurgia',    3);

-- ------------------------------------------------------------
-- Localizacao (depende de Departamento)
-- ------------------------------------------------------------
INSERT INTO `Localizacao` (`descricao`, `sala`, `piso`, `edificio`,
                            `Departamento_idDepartamento`) VALUES
    ('Sala ECG Cardiologia',   '101', '1', 'Bloco A', 1),
    ('Sala TAC Radiologia',    '202', '2', 'Bloco B', 2),
    ('Sala Cirurgia Principal','301', '3', 'Bloco A', 3);

-- ------------------------------------------------------------
-- Tecnico (depende de contacto_tecnico)
-- ------------------------------------------------------------
INSERT INTO `Tecnico` (`data_inicio_carreira`, `nome`, `especialidade`,
                        `contacto_tecnico_idcontacto_tecnico`) VALUES
    ('2010-01-10', 'Técnico Pedro', 'Equipamentos Cardíacos', 1),
    ('2015-05-15', 'Técnico Ana',   'Imaging',                 2),
    ('2018-03-20', 'Técnico Bruno', 'Cirurgia',                3);

-- ------------------------------------------------------------
-- Equipamento (depende de Equipamento_contacto, Departamento, Localizacao)
-- ------------------------------------------------------------
INSERT INTO `Equipamento` (`estado`, `descricao`, `fabricante`, `designacao`, `data_aquisicao`,
                            `Equipamento_contacto_idEquipamento_contacto1`,
                            `Departamento_idDepartamento`,
                            `Localizacao_idLocalizacao`) VALUES
    ('Operacional',   'Dispositivo para aquisição de ECG',   'Philips', 'Eletrocardiograma', '2020-01-15', 1, 1, 1),
    ('Operacional',   'Tomógrafo de Tomografia Computada',   'Siemens', 'Tomógrafo',         '2018-06-20', 2, 2, 2),
    ('Em Manutenção', 'Bisturi elétrico para cirurgia',      'Erbe',    'Bisturi Elétrico',  '2021-03-10', 3, 3, 3);

-- ------------------------------------------------------------
-- Intervencao_Tecnico (depende de Tecnico e Manutencao)
-- ------------------------------------------------------------
INSERT INTO `Intervencao_Tecnico` (`Cargo`, `horas_trabalho`,
                                    `Tecnico_idTecnico`,
                                    `Manutencao_id_manutencao`) VALUES
    ('Técnico Responsável',  4,  1, 1),
    ('Técnico Especialista', 24, 2, 2),
    ('Técnico Inspetor',     2,  1, 3);

-- ============================================================
-- FIM DO FICHEIRO 03_povoamento.sql
-- ============================================================
