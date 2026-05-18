-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 02: População de Dados de Exemplo
-- ============================================================

USE `mydb`;

-- ============================================================
-- Inserção de Dados: contacto_responsavel
-- ============================================================
INSERT INTO `contacto_responsavel` (`idcontacto_responsavel`, `contacto`, `email`) VALUES
(1, '217123456', 'joao.silva@hospital.pt'),
(2, '217234567', 'maria.santos@hospital.pt'),
(3, '217345678', 'carlos.oliveira@hospital.pt'),
(4, '217456789', 'ana.costa@hospital.pt'),
(5, '217567890', 'pedro.gomes@hospital.pt');

-- ============================================================
-- Inserção de Dados: contacto_tecnico
-- ============================================================
INSERT INTO `contacto_tecnico` (`idcontacto_tecnico`, `contacto`, `email`) VALUES
(1, '912345678', 'tecnico1@manutencao.pt'),
(2, '912456789', 'tecnico2@manutencao.pt'),
(3, '912567890', 'tecnico3@manutencao.pt'),
(4, '912678901', 'tecnico4@manutencao.pt'),
(5, '912789012', 'tecnico5@manutencao.pt');

-- ============================================================
-- Inserção de Dados: Equipamento_contacto
-- ============================================================
INSERT INTO `Equipamento_contacto` (`idEquipamento_contacto`, `contacto`, `email`) VALUES
(1, '211111111', 'suporte1@fabricante.pt'),
(2, '211222222', 'suporte2@fabricante.pt'),
(3, '211333333', 'suporte3@fabricante.pt'),
(4, '211444444', 'suporte4@fabricante.pt'),
(5, '211555555', 'suporte5@fabricante.pt');

-- ============================================================
-- Inserção de Dados: Responsavel
-- ============================================================
INSERT INTO `Responsavel` (`idResponsavel`, `nome`, `data_nascimento`, `contacto_responsavel_idcontacto_responsavel`) VALUES
(1, 'João Silva', '1975-03-15', 1),
(2, 'Maria Santos', '1980-07-22', 2),
(3, 'Carlos Oliveira', '1978-11-08', 3),
(4, 'Ana Costa', '1982-05-19', 4),
(5, 'Pedro Gomes', '1976-09-12', 5);

-- ============================================================
-- Inserção de Dados: Departamento
-- ============================================================
INSERT INTO `Departamento` (`idDepartamento`, `designacao`, `descricao`, `idResponsavel`) VALUES
(1, 'Cardiologia', 'Departamento de Cardiologia', 1),
(2, 'Radiologia', 'Departamento de Radiologia', 2),
(3, 'Laboratório', 'Departamento de Análises Clínicas', 3),
(4, 'Oftalmologia', 'Departamento de Oftalmologia', 4),
(5, 'Cirurgia', 'Departamento de Cirurgia', 5);

-- ============================================================
-- Inserção de Dados: Localizacao
-- ============================================================
INSERT INTO `Localizacao` (`idLocalizacao`, `descricao`, `sala`, `piso`, `edificio`, `Departamento_idDepartamento`) VALUES
(1, 'Sala de Ecocardiografia', '101', '1', 'Bloco A', 1),
(2, 'Sala de Radiologia', '201', '2', 'Bloco A', 2),
(3, 'Sala de Análises', '301', '3', 'Bloco B', 3),
(4, 'Consultório Oftalmologia', '102', '1', 'Bloco B', 4),
(5, 'Bloco Operatório', '401', '4', 'Bloco C', 5);

-- ============================================================
-- Inserção de Dados: Peca
-- ============================================================
INSERT INTO `Peca` (`idPeca`, `preco`, `designacao`, `garantia`) VALUES
(1, 1500.00, 'Probe Ecocardiografia', '2026-12-31'),
(2, 850.00, 'Tubo de Raios-X', '2027-06-30'),
(3, 350.00, 'Filtro de Centrífuga', '2025-12-31'),
(4, 2200.00, 'Lente Oftalmológica', '2028-03-31'),
(5, 5000.00, 'Válvula Cirúrgica Esterilizável', '2027-09-30');

-- ============================================================
-- Inserção de Dados: Tecnico
-- ============================================================
INSERT INTO `Tecnico` (`idTecnico`, `data_inicio_carreira`, `nome`, `especialidade`, `contacto_tecnico_idcontacto_tecnico`) VALUES
(1, '2010-01-15', 'António Ferreira', 'Ecocardiografia', 1),
(2, '2012-05-20', 'Ricardo Martins', 'Radiologia', 2),
(3, '2015-09-10', 'Nuno Santos', 'Análises Clínicas', 3),
(4, '2011-03-25', 'Miguel Rodrigues', 'Oftalmologia', 4),
(5, '2018-07-01', 'Paulo Lopes', 'Equipamento Cirúrgico', 5);

-- ============================================================
-- Inserção de Dados: Equipamento
-- ============================================================
INSERT INTO `Equipamento` (`idEquipamento`, `estado`, `descricao`, `fabricante`, `designacao`, `data_aquisicao`, `Equipamento_contacto_idEquipamento_contacto1`, `Departamento_idDepartamento`, `Localizacao_idLocalizacao`) VALUES
(1, 'Operacional', 'Ecocardiógrafo modelo premium', 'GE Healthcare', 'GE Vivid E95', '2020-05-15', 1, 1, 1),
(2, 'Operacional', 'Sistema de Radiologia Digital', 'Philips', 'Philips DigitalDiagnost C90', '2019-08-20', 2, 2, 2),
(3, 'Operacional', 'Centrifugadora automática', 'Siemens', 'Siemens RAPIDLAB 1200', '2021-03-10', 3, 3, 3),
(4, 'Manutenção Preventiva', 'Microscópio Oftalmológico', 'Zeiss', 'Zeiss OPMI Lumera 700', '2018-11-05', 4, 4, 4),
(5, 'Operacional', 'Esterilizador Cirúrgico', 'Getinge', 'Getinge AMSCO 250P', '2022-01-25', 5, 5, 5);

-- ============================================================
-- Inserção de Dados: Manutencao
-- ============================================================
INSERT INTO `Manutencao` (`id_manutencao`, `custo`, `tipo`, `descricao`, `data_inicio`, `data_fim`, `Peca_idPeca`, `Equipamento_idEquipamento`) VALUES
(1, 2350.00, 'Preventiva', 'Manutenção anual Ecocardiógraf', '2025-01-10', '2025-01-15', 1, 1),
(2, 1200.00, 'Corretiva', 'Substituição de Tubo de Raios-X', '2025-02-01', '2025-02-05', 2, 2),
(3, 450.00, 'Preventiva', 'Limpeza e calibração', '2025-02-15', '2025-02-18', 3, 3),
(4, 3500.00, 'Preventiva', 'Manutenção geral oftalmológica', '2025-03-01', '2025-03-08', 4, 4),
(5, 6200.00, 'Corretiva', 'Reparação do motor esterilizador', '2025-03-10', '2025-03-20', 5, 5);

-- ============================================================
-- Inserção de Dados: Ordem_servico
-- ============================================================
INSERT INTO `Ordem_servico` (`idOrdem`, `descricao`, `estado_atual`, `prioridade`, `Manutencao_id_manutencao`) VALUES
(1, 'Manutenção preventiva anual Ecocardiógraf', 'Concluída', 'Normal', 1),
(2, 'Reparação urgente Radiologia', 'Em Progresso', 'Alta', 2),
(3, 'Limpeza de filtros', 'Agendada', 'Baixa', 3),
(4, 'Revisão oftalmológica completa', 'Concluída', 'Normal', 4),
(5, 'Reparação crítica - Esterilizador', 'Em Progresso', 'Crítica', 5);

-- ============================================================
-- Inserção de Dados: Intervencao_Tecnico
-- ============================================================
INSERT INTO `Intervencao_Tecnico` (`idIntervencao`, `Cargo`, `horas_trabalho`, `Tecnico_idTecnico`, `Manutencao_id_manutencao`) VALUES
(1, 'Técnico Senior', 8, 1, 1),
(2, 'Técnico Especialista', 12, 2, 2),
(3, 'Técnico Junior', 4, 3, 3),
(4, 'Técnico Senior', 16, 4, 4),
(5, 'Técnico Especialista', 20, 5, 5);

-- ============================================================
-- Fim da População de Dados
-- ============================================================
