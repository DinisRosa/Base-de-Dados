SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE reinicia o AUTO_INCREMENT
-- ============================================================================
-- POVOAMENTO
-- ============================================================================

TRUNCATE TABLE Contacto_responsavel;
TRUNCATE TABLE Equipamento_contacto;
TRUNCATE TABLE contacto_tecnico;
TRUNCATE TABLE Peca;
TRUNCATE TABLE Tecnico;
TRUNCATE TABLE Responsavel;
TRUNCATE TABLE Departamento;
TRUNCATE TABLE Localizacao;
TRUNCATE TABLE Equipamento;
TRUNCATE TABLE Manutencao;
TRUNCATE TABLE Ordem_servico;
TRUNCATE TABLE Intervencao_Tecnico;

-- ============================================================================
-- 1. TABELAS DE CONTACTOS 
-- ============================================================================

INSERT INTO Contacto_responsavel (contacto, email) VALUES
('912345678', 'ana.martins@hospital.pt'),
('922334455', 'carlos.santos@hospital.pt'),
('933445566', 'ricardo.pereira@hospital.pt'),
('966778899', 'sofia.oliveira@hospital.pt'),
('911223344', 'miguel.ferreira@hospital.pt');

INSERT INTO Equipamento_contacto (contacto, email) VALUES
('912345678', 'suporte.draeger@medical.pt'),
('922334455', 'suporte.ge@medical.pt'),
('933445566', 'suporte.philips@medical.pt'),
('966778899', 'suporte.zoll@medical.pt'),
('911223344', 'suporte.bbraun@medical.pt'),
('922887766', 'suporte.mortara@medical.pt'),
('933554433', 'suporte.medela@medical.pt'),
('911001122', 'suporte.masimo@medical.pt'),
('966009988', 'suporte.welchallyn@medical.pt'),
('911998877', 'suporte.omron@medical.pt');

INSERT INTO contacto_tecnico (contacto, email) VALUES
('911222333', 'ricardo.pereira@tech.hospital.pt'),
('922333444', 'marta.silveira@tech.hospital.pt'),
('933444555', 'joao.gouveia@tech.hospital.pt'),
('966555666', 'antonio.costa@tech.hospital.pt'),
('911888999', 'beatriz.lopes@tech.hospital.pt');

-- ============================================================================
-- 2. TABELA PECA
-- ============================================================================

INSERT INTO Peca (preco, designacao, garantia) VALUES
(85.00, 'Filtro de ar HEPA ventilador', '2027-12-31'),
(210.00, 'Sonda ecografica convexa', '2028-06-30'),
(320.00, 'Ecra tatil monitor sinais vitais', '2029-01-01'),
(95.00, 'Bateria Li-ion desfibrilhador', '2026-12-31'),
(140.00, 'Rotor bomba de infusao', '2027-06-30'),
(60.00, 'Cabo de electrodos ECG', '2028-01-01'),
(45.00, 'Filtro aspirador secrecoes', '2027-03-31'),
(175.00, 'Sensor SpO2 oximetro de pulso', '2028-09-30'),
(30.00, 'Pilhas alcalinas termometro', '2026-06-30'),
(55.00, 'Manguito esfigmomanometro adulto', '2027-12-31');

-- ============================================================================
-- 3. TABELA TECNICO
-- ============================================================================

INSERT INTO Tecnico (data_inicio_carreira, nome, especialidade, contacto_tecnico_id_contacto_tecnico) VALUES
('2015-01-15', 'Ricardo Pereira', 'Eletronica Medica', 1),
('2010-03-20', 'Marta Silveira', 'Imagiologia/Ressonancia', 2),
('2020-09-01', 'Joao Gouveia', 'Sistemas de Ventilacao', 3),
('2005-05-10', 'Antonio Costa', 'Instrumentacao Cirurgica', 4),
('2018-02-01', 'Beatriz Lopes', 'Monitorizacao Parametrica', 5);

-- ============================================================================
-- 4. TABELA RESPONSAVEL
-- ============================================================================

INSERT INTO Responsavel (nome, data_nascimento, Ordem_servico_id_ordem, Contacto_responsavel_id_contacto_responsavel) VALUES
('Dra. Ana Martins', '1975-03-12', 1, 1),
('Dr. Carlos Santos', '1982-07-25', 2, 2),
('Eng. Ricardo Pereira', '1980-11-05', 3, 3),
('Dra. Sofia Oliveira', '1988-01-30', 4, 4),
('Dr. Miguel Ferreira', '1970-05-18', 5, 5);

-- ============================================================================
-- 5. TABELA DEPARTAMENTO
-- ============================================================================

INSERT INTO Departamento (designacao, descricao, id_responsavel) VALUES
('Cardiologia', 'Unidade de cuidados e diagnosticos cardiacos', 1),
('Imagiologia', 'Servico de exames radiologicos e ecografias', 2),
('Urgencias', 'Atendimento permanente de cuidados agudos', 3),
('Manutencao Tecnica', 'Gestao de infraestruturas e biomedica', 4),
('Cuidados Intensivos', 'Unidade de monitorizacao critica (UCI)', 5);

-- ============================================================================
-- 6. TABELA LOCALIZACAO
-- ============================================================================

INSERT INTO Localizacao (descricao, sala, piso, edificio, Departamento_id_departamento) VALUES
('Sala de Servidores Principal', '101', '1', '1', 4),
('Laboratorio de Informatica', '202', '2', '2', 2), 
('Armazem de Equipamentos', '001', '0', '3', 4),
('Sala de Reunioes Norte', '301', '3', '1', 1),
('Centro de Controlo', '100', '1', '4', 4),
('Oficina de Manutencao', '050', '0', '2', 4),
('Sala de Comunicacoes', '205', '2', '1', 4),
('Deposito Tecnico', '010', '0', '3', 4),
('Sala de Monitorizacao', '401', '4', '4', 5),
('Rececao Principal', '001', '0', '1', 3);

-- ============================================================================
-- 7. TABELA EQUIPAMENTO
-- ============================================================================

INSERT INTO Equipamento (estado, descricao, fabricante, designacao, data_aquisicao, Equipamento_contacto_id_equipamento_contacto, Departamento_id_departamento, Localizacao_id_localizacao) VALUES
('Operacional', 'Ventilador Pulmonar Avancado', 'Draeger', 'Evita V500', '2023-05-15', 1, 5, 9),
('Operacional', 'Ecografo Portatil 4D', 'GE Healthcare', 'Vivid iq', '2022-11-20', 2, 2, 2),
('Em Manutencao', 'Monitor de Sinais Vitais', 'Philips', 'IntelliVue MX450', '2024-01-10', 3, 5, 9),
('Operacional', 'Desfibrilhador Automatico', 'Zoll', 'R Series', '2023-08-05', 4, 1, 4),
('Avariado', 'Bomba de Infusao Continua', 'B. Braun', 'Infusomat P', '2021-03-30', 5, 5, 9),
('Operacional', 'Eletrocardiografo 12 Canais', 'Mortara', 'ELI 250', '2022-06-12', 6, 1, 4),
('Operacional', 'Aspirador de Secrecoes Hospitalar', 'Medela', 'Dominant Flex', '2023-12-01', 7, 3, 10),
('Em Manutencao', 'Oximetro de Pulso de Mesa', 'Masimo', 'Rad-97', '2024-02-15', 8, 5, 9),
('Operacional', 'Termometro de Infravermelhos Pro', 'Welch Allyn', 'CareTemp', '2024-03-01', 9, 3, 10),
('Operacional', 'Esfigmomanometro Digital', 'Omron', 'HBP-1320', '2023-09-20', 10, 3, 10);

-- ============================================================================
-- 8. TABELA MANUTENCAO
-- ============================================================================

INSERT INTO Manutencao (custo, tipo, descricao, data_inicio, data_fim, Peca_id_peca, Equipamento_id_equipamento) VALUES
(350.00, 'Preventiva', 'Manutencao preventiva anual do ventilador', '2025-01-12', '2025-01-12', 1, 1),
(220.00, 'Calibracao', 'Calibracao e ajuste do ecografo portatil', '2025-02-07', '2025-02-07', 2, 2),
(480.00, 'Corretiva', 'Substituicao de ecra do monitor de sinais vitais', '2025-03-03', null, 3, 3),
(150.00, 'Corretiva', 'Substituicao de bateria interna do desfibrilhador', '2025-01-22', '2025-01-22', null, 4),
(310.00, 'Preventiva', 'Revisao geral da bomba de infusao continua', '2025-03-17', null, 5, 5),
(180.00, 'Preventiva', 'Revisao e limpeza do eletrocardiografo', '2025-02-20', '2025-02-20', 6, 6),
(90.00, 'Preventiva', 'Limpeza e teste funcional do aspirador', '2025-01-29', '2025-01-29', 7, 7),
(260.00, 'Corretiva', 'Diagnostico e reparacao do oximetro de pulso', '2025-03-11', null, 8, 8),
(70.00, 'Calibracao', 'Verificacao de precisao do termometro', '2025-02-26', '2025-02-26', 9, 9),
(120.00, 'Calibracao', 'Calibracao do esfigmomanometro digital', '2025-03-22', null, 10, 10);

-- ============================================================================
-- 9. TABELA ORDEM DE SERVICO
-- ============================================================================

INSERT INTO Ordem_servico (descricao, estado_atual, prioridade, Manutencao_id_manutencao) VALUES
('Verificacao anual do ventilador pulmonar', 'Concluida', 'Alta', 1),
('Calibracao do ecografo portatil', 'Concluida', 'Media', 2),
('Reparacao do monitor de sinais vitais', 'Em Curso', 'Alta', 3),
('Substituicao de bateria do desfibrilhador', 'Concluida', 'Alta', 4),
('Manutencao preventiva da bomba de infusao', 'Pendente', 'Media', 5),
('Revisao do eletrocardiografo', 'Concluida', 'Baixa', 6),
('Limpeza e teste do aspirador de secrecoes', 'Concluida', 'Baixa', 7),
('Diagnostico do oximetro de pulso', 'Em Curso', 'Alta', 8),
('Verificacao do termometro de infravermelhos', 'Concluida', 'Baixa', 9),
('Calibracao do esfigmomanometro digital', 'Pendente', 'Media', 10);

-- ============================================================================
-- 10. TABELA INTERVENCAO_TECNICO
-- ============================================================================

INSERT INTO Intervencao_Tecnico (Cargo, horas_trabalho, Tecnico_id_tecnico, Manutencao_id_manutencao) VALUES
('Tecnico Responsavel', 4, 1, 1),
('Tecnico Responsavel', 3, 2, 2),
('Tecnico Senior', 8, 3, 3),
('Tecnico Responsavel', 2, 4, 4),
('Tecnico Senior', 5, 5, 5),
('Tecnico Responsavel', 3, 1, 6),
('Tecnico Assistente', 2, 3, 7),
('Tecnico Senior', 6, 2, 8),
('Tecnico Assistente', 1, 5, 9),
('Tecnico Responsavel', 2, 4, 10);

SET FOREIGN_KEY_CHECKS = 1;


