-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 03: Povoamento de Dados (Exemplos)
-- Compatível com MySQL 8.0+ / MySQL Workbench
-- Modelo: mod_conceptual_novas_modificacoes (Sem EQUIPAMENTO_DEPARTAMENTO)
-- ============================================================

USE gestao_equipamentos;

-- ============================================================
-- DADOS DE TESTE / EXEMPLO
-- ============================================================

-- LOCALIZACAO
INSERT INTO LOCALIZACAO (sala, piso, edificio) VALUES
    ('101', '1', 'Bloco A'),
    ('202', '2', 'Bloco B'),
    ('301', '3', 'Bloco A');

-- DEPARTAMENTO
INSERT INTO DEPARTAMENTO (designacao, descricao) VALUES
    ('Cardiologia', 'Departamento de Cardiologia'),
    ('Radiologia', 'Departamento de Radiologia'),
    ('Cirurgia', 'Departamento de Cirurgia');

-- RESPONSAVEL (com campo aprova adicionado)
INSERT INTO RESPONSAVEL (nome, data_nascimento, id_departamento, aprova) VALUES
    ('Dr. João Silva', '1970-05-15', 1, TRUE),
    ('Dra. Maria Santos', '1975-08-20', 2, TRUE),
    ('Dr. Carlos Oliveira', '1968-03-10', 3, FALSE);

-- RESPONSAVEL_CONTACTO
INSERT INTO RESPONSAVEL_CONTACTO (id_responsavel, contacto) VALUES
    (1, '915555001'),
    (1, 'joao.silva@hospital.pt'),
    (2, '915555002'),
    (2, 'maria.santos@hospital.pt'),
    (3, '915555003');

-- EQUIPAMENTO (com campos estado_atual, garantia, id_departamento adicionados - sem EQUIPAMENTO_DEPARTAMENTO)
INSERT INTO EQUIPAMENTO (designacao, data_aquisicao, fabricante, estado, estado_atual, 
                         descricao, garantia, id_localizacao, id_departamento) VALUES
    ('Eletrocardiograma', '2020-01-15', 'Philips', 'Operacional', 'Operacional', 
     'Dispositivo para aquisição de ECG', 24, 1, 1),
    ('Tomógrafo', '2018-06-20', 'Siemens', 'Operacional', 'Operacional', 
     'Tomógrafo de Tomografia Computada', 36, 2, 2),
    ('Bisturi Elétrico', '2021-03-10', 'Erbe', 'Em Manutenção', 'Em Manutenção', 
     'Bisturi elétrico para cirurgia', 12, 3, 3);

-- EQUIPAMENTO_CONTACTO_SUPORTE
INSERT INTO EQUIPAMENTO_CONTACTO_SUPORTE (id_equipamento, contacto_suporte) VALUES
    (1, '212345678'),
    (2, '212345679'),
    (3, '212345680');

-- TECNICO (com campo anos_experiencia adicionado)
INSERT INTO TECNICO (nome, especialidade, data_inicio_carreira, anos_experiencia) VALUES
    ('Técnico Pedro', 'Equipamentos Cardíacos', '2010-01-10', 14),
    ('Técnico Ana', 'Imaging', '2015-05-15', 9),
    ('Técnico Bruno', 'Cirurgia', '2018-03-20', 6);

-- TECNICO_CONTACTO
INSERT INTO TECNICO_CONTACTO (id_tecnico, contacto) VALUES
    (1, '919999001'),
    (1, 'pedro.tec@empresa.pt'),
    (2, '919999002'),
    (3, '919999003');

-- MANUTENCAO (com campos duracao e horas_trabalho adicionados, agora com id_ordem)
INSERT INTO MANUTENCAO (tipo, data_inicio, data_fim, descricao, custo, duracao, 
                       horas_trabalho, id_equipamento, id_ordem) VALUES
    ('Preventiva', '2025-05-01', '2025-05-03', 'Manutenção preventiva do ECG', 250.00, 2, 4.5, 1, 1),
    ('Corretiva', '2025-05-05', '2025-05-10', 'Reparação do tomógrafo', 1500.00, 5, 24.0, 2, 2),
    ('Inspeção', '2025-05-02', '2025-05-02', 'Inspeção do bisturi', 100.00, 1, 2.0, 3, 3);

-- PECA (com campo custo adicionado)
INSERT INTO PECA (designacao, preco, custo, validade_peca) VALUES
    ('Cabo ECG', 50.00, 15.00, '2027-12-31'),
    ('Filtro de ar', 120.00, 40.00, '2026-06-30'),
    ('Resistência Elétrica', 200.00, 60.00, '2028-03-31');

-- ORDEM_SERVICO
INSERT INTO ORDEM_SERVICO (descricao, estado_atual, prioridade) VALUES
    ('Manutenção ECG - Sala 101', 'Pendente', 'Normal'),
    ('Reparação Tomógrafo - Sala 202', 'Em Execução', 'Alta'),
    ('Inspeção Bisturi - Sala 301', 'Concluída', 'Baixa');


-- MANUTENCAO_PECA
INSERT INTO MANUTENCAO_PECA (id_manutencao, id_peca, quantidade) VALUES
    (1, 1, 2),
    (2, 2, 1),
    (3, 3, 1);

-- INTERVENCAO_TECNICO
INSERT INTO INTERVENCAO_TECNICO (id_manutencao, id_tecnico, cargo, horas_trabalho) VALUES
    (1, 1, 'Técnico Responsável', 4.5),
    (2, 2, 'Técnico Especialista', 24.0),
    (3, 1, 'Técnico Inspetor', 2.0);

-- ============================================================
-- FIM DO FICHEIRO 03_povoamento.sql
-- ============================================================
