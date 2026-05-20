-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Peca`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Peca` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Peca` (
  `id_peca` INT NOT NULL AUTO_INCREMENT,
  `preco` DECIMAL NOT NULL,
  `designacao` VARCHAR(45) NOT NULL,
  `garantia` DATE NOT NULL,
  UNIQUE INDEX `idPeça_UNIQUE` (`id_peca` ASC) VISIBLE,
  PRIMARY KEY (`id_peca`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Contacto_responsavel`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Contacto_responsavel` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Contacto_responsavel` (
  `id_contacto_responsavel` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`id_contacto_responsavel`),
  UNIQUE INDEX `idcontacto_responsavel_UNIQUE` (`id_contacto_responsavel` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`contacto_tecnico`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`contacto_tecnico` ;

CREATE TABLE IF NOT EXISTS `mydb`.`contacto_tecnico` (
  `id_contacto_tecnico` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`id_contacto_tecnico`),
  UNIQUE INDEX `idcontacto_tecnico_UNIQUE` (`id_contacto_tecnico` ASC) VISIBLE)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `mydb`.`Equipamento_contacto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Equipamento_contacto` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Equipamento_contacto` (
  `id_equipamento_contacto` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`id_equipamento_contacto`),
  UNIQUE INDEX `idEquipamento_contacto_UNIQUE` (`id_equipamento_contacto` ASC) VISIBLE)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `mydb`.`Responsavel`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Responsavel` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Responsavel` (
  `id_responsavel` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `Ordem_de_servico_id_ordem` INT NOT NULL,
  `Contacto_responsavel_id_contacto_responsavel` INT NOT NULL,
  INDEX `fk_Responsável_Ordem de serviço1_idx` (`Ordem_de_servico_id_ordem` ASC) VISIBLE,
  UNIQUE INDEX `idResponsável_UNIQUE` (`id_responsavel` ASC) VISIBLE,
  PRIMARY KEY (`id_responsavel`),
  INDEX `fk_Responsavel_contacto_responsavel1_idx` (`Contacto_responsavel_id_contacto_responsavel` ASC) VISIBLE,
  CONSTRAINT `fk_Responsável_Ordem de serviço1`
    FOREIGN KEY (`Ordem_de_servico_id_ordem`)
    REFERENCES `mydb`.`Ordem_servico` (`id_ordem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Responsavel_contacto_responsavel1`
    FOREIGN KEY (`Contacto_responsavel_id_contacto_responsavel`)
    REFERENCES `mydb`.`Contacto_responsavel` (`id_contacto_responsavel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Departamento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Departamento` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Departamento` (
  `id_departamento` INT NOT NULL AUTO_INCREMENT,
  `designacao` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(100) NULL,
  `id_responsavel` INT NOT NULL,
  PRIMARY KEY (`id_departamento`),
  INDEX `fk_departamento_responsavel_idx` (`id_responsavel` ASC) VISIBLE,
  UNIQUE INDEX `idDepartamento_UNIQUE` (`id_departamento` ASC) VISIBLE,
  CONSTRAINT `fk_departamento_responsavel`
    FOREIGN KEY (`id_responsavel`)
    REFERENCES `mydb`.`Responsavel` (`id_responsavel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Localizacao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Localizacao` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Localizacao` (
  `id_localizacao` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(100) NULL,
  `sala` VARCHAR(45) NOT NULL,
  `piso` VARCHAR(45) NOT NULL,
  `edificio` VARCHAR(45) NOT NULL,
  `Departamento_id_departamento` INT NOT NULL,
  PRIMARY KEY (`id_localizacao`),
  INDEX `fk_Localização_Departamento1_idx` (`Departamento_id_departamento` ASC) VISIBLE,
  UNIQUE INDEX `idLocalização_UNIQUE` (`id_localizacao` ASC) VISIBLE,
  CONSTRAINT `fk_Localização_Departamento1`
    FOREIGN KEY (`Departamento_id_departamento`)
    REFERENCES `mydb`.`Departamento` (`id_departamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Tecnico`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Tecnico` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Tecnico` (
  `id_tecnico` INT NOT NULL AUTO_INCREMENT,
  `data_inicio_carreira` DATE NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `especialidade` VARCHAR(45) NOT NULL,
  `contacto_tecnico_id_contacto_tecnico` INT NOT NULL,
  PRIMARY KEY (`id_tecnico`),
  UNIQUE INDEX `idTecnico_UNIQUE` (`id_tecnico` ASC) VISIBLE,
  INDEX `fk_Tecnico_contacto_tecnico1_idx` (`contacto_tecnico_id_contacto_tecnico` ASC) VISIBLE,
  CONSTRAINT `fk_Tecnico_contacto_tecnico1`
    FOREIGN KEY (`contacto_tecnico_id_contacto_tecnico`)
    REFERENCES `mydb`.`contacto_tecnico` (`id_contacto_tecnico`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Equipamento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Equipamento` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Equipamento` (
  `id_equipamento` INT NOT NULL AUTO_INCREMENT,
  `estado` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(100) NULL,
  `fabricante` VARCHAR(45) NOT NULL,
  `designacao` VARCHAR(45) NOT NULL,
  `data_aquisicao` DATE NOT NULL,
  `Equipamento_contacto_id_equipamento_contacto` INT NOT NULL,
  `Departamento_id_departamento` INT NOT NULL,
  `Localizacao_id_localizacao` INT NOT NULL,
  PRIMARY KEY (`id_equipamento`),
  UNIQUE INDEX `idEquipamento_UNIQUE` (`id_equipamento` ASC) VISIBLE,
  INDEX `fk_Equipamento_Equipamento_contacto1_idx` (`Equipamento_contacto_id_equipamento_contacto` ASC) VISIBLE,
  INDEX `fk_Equipamento_Departamento1_idx` (`Departamento_id_departamento` ASC) VISIBLE,
  INDEX `fk_Equipamento_Localizacao1_idx` (`Localizacao_id_localizacao` ASC) VISIBLE,
  CONSTRAINT `fk_Equipamento_Equipamento_contacto1`
    FOREIGN KEY (`Equipamento_contacto_id_equipamento_contacto`)
    REFERENCES `mydb`.`Equipamento_contacto` (`id_equipamento_contacto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipamento_Departamento1`
    FOREIGN KEY (`Departamento_id_departamento`)
    REFERENCES `mydb`.`Departamento` (`id_departamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipamento_Localizacao1`
    FOREIGN KEY (`Localizacao_id_localizacao`)
    REFERENCES `mydb`.`Localizacao` (`id_localizacao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Manutencao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Manutencao` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Manutencao` (
  `id_manutencao` INT NOT NULL AUTO_INCREMENT,
  `custo` DECIMAL NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(100) NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NULL,
  `Peca_id_peca` INT NOT NULL,
  `Equipamento_id_equipamento` INT NOT NULL,
  PRIMARY KEY (`id_manutencao`),
  UNIQUE INDEX `id_manutenção_UNIQUE` (`id_manutencao` ASC) VISIBLE,
  INDEX `fk_Manutenção_Peça1_idx` (`Peca_id_peca` ASC) VISIBLE,
  INDEX `fk_Manutencao_Equipamento1_idx` (`Equipamento_id_equipamento` ASC) VISIBLE,
  CONSTRAINT `fk_Manutenção_Peça1`
    FOREIGN KEY (`Peca_id_peca`)
    REFERENCES `mydb`.`Peca` (`id_peca`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Manutencao_Equipamento1`
    FOREIGN KEY (`Equipamento_id_equipamento`)
    REFERENCES `mydb`.`Equipamento` (`id_equipamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Ordem_servico`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Ordem_servico` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Ordem_servico` (
  `id_ordem` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(100) NULL,
  `estado_atual` VARCHAR(45) NOT NULL,
  `prioridade` VARCHAR(45) NOT NULL,
  `Manutencao_id_manutencao` INT NOT NULL,
  PRIMARY KEY (`id_ordem`),
  INDEX `fk_Ordem de serviço_Manutenção1_idx` (`Manutencao_id_manutencao` ASC) VISIBLE,
  UNIQUE INDEX `idOrdem_UNIQUE` (`id_ordem` ASC) VISIBLE,
  CONSTRAINT `fk_Ordem de serviço_Manutenção1`
    FOREIGN KEY (`Manutencao_id_manutencao`)
    REFERENCES `mydb`.`Manutencao` (`id_manutencao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;






-- -----------------------------------------------------
-- Table `mydb`.`Intervencao_Tecnico`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Intervencao_Tecnico` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Intervencao_Tecnico` (
  `id_intervencao` INT NOT NULL AUTO_INCREMENT,
  `Cargo` VARCHAR(45) NOT NULL,
  `horas_trabalho` INT NOT NULL,
  `Tecnico_id_tecnico` INT NOT NULL,
  `Manutencao_id_manutencao` INT NOT NULL,
  UNIQUE INDEX `idIntervenção_UNIQUE` (`id_intervencao` ASC) VISIBLE,
  PRIMARY KEY (`id_intervencao`),
  INDEX `fk_intervencao_tecnico_idx` (`Tecnico_id_tecnico` ASC) VISIBLE,
  INDEX `fk_intervencao_manutencao_idx` (`Manutencao_id_manutencao` ASC) VISIBLE,
  CONSTRAINT `fk_intervencao_tecnico`
    FOREIGN KEY (`Tecnico_id_tecnico`)
    REFERENCES `mydb`.`Tecnico` (`id_tecnico`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_intervencao_manutencao`
    FOREIGN KEY (`Manutencao_id_manutencao`)
    REFERENCES `mydb`.`Manutencao` (`id_manutencao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


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

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- ============================================================================
-- FUNÇÃO 1: Calcular idade do equipamento (atributo derivado)
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS calcular_idade_equipamento$$
CREATE FUNCTION calcular_idade_equipamento(p_id_equipamento INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE anos INT;
    SELECT TIMESTAMPDIFF(YEAR, data_aquisicao, CURDATE())
    INTO anos
    FROM Equipamento
    WHERE id_equipamento = p_id_equipamento;
    RETURN anos;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 2: Calcular duração de uma manutenção em dias (atributo derivado)
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS calcular_duracao_manutencao$$
CREATE FUNCTION calcular_duracao_manutencao(p_id_manutencao INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE dias INT;
    SELECT DATEDIFF(data_fim, data_inicio)
    INTO dias
    FROM Manutencao
    WHERE id_manutencao = p_id_manutencao;
    RETURN dias;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 3: Calcular anos de experiência do técnico (atributo derivado)
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS calcular_experiencia_tecnico$$
CREATE FUNCTION calcular_experiencia_tecnico(p_id_tecnico INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE anos INT;
    SELECT TIMESTAMPDIFF(YEAR, data_inicio_carreira, CURDATE())
    INTO anos
    FROM Tecnico
    WHERE id_tecnico = p_id_tecnico;
    RETURN anos;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 4: Verificar se equipamento tem manutenções ativas
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS equipamento_tem_manutencao_ativa$$
CREATE FUNCTION equipamento_tem_manutencao_ativa(p_id_equipamento INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*)
    INTO total
    FROM Manutencao m
    JOIN Ordem_servico o ON o.Manutencao_id_manutencao = m.id_manutencao
    WHERE m.Equipamento_id_equipamento = p_id_equipamento
      AND o.estado_atual NOT IN ('Concluida', 'Cancelada');
    RETURN total > 0;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 5: Obter localização completa de um equipamento
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS obter_localizacao_equipamento$$
CREATE FUNCTION obter_localizacao_equipamento(p_id_equipamento INT)
RETURNS VARCHAR(150)
DETERMINISTIC
BEGIN
    DECLARE resultado VARCHAR(150);
    SELECT CONCAT('Edificio: ', l.edificio, ' | Piso: ', l.piso, ' | Sala: ', l.sala)
    INTO resultado
    FROM Equipamento e
    JOIN Localizacao l ON l.id_localizacao = e.Localizacao_id_localizacao
    WHERE e.id_equipamento = p_id_equipamento;
    RETURN resultado;
END$$
DELIMITER ;

-- ============================================================================
-- FUNÇÃO 6: Calcular custo total de manutenções de um equipamento
-- ============================================================================
DELIMITER $$
DROP FUNCTION IF EXISTS custo_total_manutencoes$$
CREATE FUNCTION custo_total_manutencoes(p_id_equipamento INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT COALESCE(SUM(custo), 0)
    INTO total
    FROM Manutencao
    WHERE Equipamento_id_equipamento = p_id_equipamento;
    RETURN total;
END$$
DELIMITER ;









-- ============================================================
--   TRIGGERS
-- ============================================================

DELIMITER $$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 1: Validar datas e impedir dupla manutenção (BEFORE INSERT)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_validar_datas_insert$$
CREATE TRIGGER trg_manutencao_validar_datas_insert
BEFORE INSERT ON Manutencao
FOR EACH ROW
BEGIN
    DECLARE v_manutencoes_ativas INT DEFAULT 0;

    -- 1. Verifica se o equipamento já está em manutenção
    SELECT COUNT(*) INTO v_manutencoes_ativas
    FROM Manutencao
    WHERE Equipamento_id_equipamento = NEW.Equipamento_id_equipamento
      AND data_fim IS NULL;

    IF v_manutencoes_ativas > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: O equipamento já possui uma manutenção em curso. Conclua-a primeiro.';
    END IF;

    -- 2. Validação de datas
    IF NEW.data_inicio IS NOT NULL AND NEW.data_fim IS NOT NULL THEN
        IF NEW.data_inicio > NEW.data_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro: A data de início não pode ser posterior à data de fim.';
        END IF;
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 2: Validar datas na atualização (BEFORE UPDATE)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_validar_datas_update$$
CREATE TRIGGER trg_manutencao_validar_datas_update
BEFORE UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    IF NEW.data_inicio IS NOT NULL AND NEW.data_fim IS NOT NULL THEN
        IF NEW.data_inicio > NEW.data_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro: A data de início não pode ser posterior à data de fim.';
        END IF;
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 3: Atualizar estado do equipamento para Em Manutencao (AFTER INSERT)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_estado_equipamento_insert$$
CREATE TRIGGER trg_manutencao_estado_equipamento_insert
AFTER INSERT ON Manutencao
FOR EACH ROW
BEGIN
    IF NEW.data_fim IS NULL THEN
        UPDATE Equipamento
        SET estado = 'Em Manutencao'
        WHERE id_equipamento = NEW.Equipamento_id_equipamento; 
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 4: Repor estado do equipamento e fechar OS (AFTER UPDATE)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_estado_equipamento_update$$
CREATE TRIGGER trg_manutencao_estado_equipamento_update
AFTER UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    -- Se a manutenção recebeu data de fim (terminou)
    IF NEW.data_fim IS NOT NULL AND OLD.data_fim IS NULL THEN
        
        -- 1. Repõe o estado do equipamento
        UPDATE Equipamento
        SET estado = 'Operacional'
        WHERE id_equipamento = NEW.Equipamento_id_equipamento;
        
        -- 2. Fecha a Ordem de Serviço associada
        UPDATE Ordem_servico
        SET estado_atual = 'Concluida'
        WHERE Manutencao_id_manutencao = NEW.id_manutencao;
        
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 5A e 5B: Validar domínios da ordem de serviço
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_ordem_servico_validar_dominios_insert$$
CREATE TRIGGER trg_ordem_servico_validar_dominios_insert
BEFORE INSERT ON Ordem_servico
FOR EACH ROW
BEGIN
    IF NEW.prioridade NOT IN ('Baixa', 'Media', 'Alta', 'Urgente') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Prioridade inválida.';
    END IF;
    IF NEW.estado_atual NOT IN ('Pendente', 'Em Curso', 'Concluida', 'Cancelada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado atual inválido.';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_ordem_servico_validar_dominios_update$$
CREATE TRIGGER trg_ordem_servico_validar_dominios_update
BEFORE UPDATE ON Ordem_servico
FOR EACH ROW
BEGIN
    IF NEW.prioridade NOT IN ('Baixa', 'Media', 'Alta', 'Urgente') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Prioridade inválida.';
    END IF;
    IF NEW.estado_atual NOT IN ('Pendente', 'Em Curso', 'Concluida', 'Cancelada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado atual inválido.';
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 6A e 6B: Validar domínios do estado do Equipamento
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_equipamento_validar_estado_insert$$
CREATE TRIGGER trg_equipamento_validar_estado_insert
BEFORE INSERT ON Equipamento
FOR EACH ROW
BEGIN
    IF NEW.estado NOT IN ('Operacional', 'Em Manutencao', 'Avariado', 'Abatido') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado inválido.';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_equipamento_validar_estado_update$$
CREATE TRIGGER trg_equipamento_validar_estado_update
BEFORE UPDATE ON Equipamento
FOR EACH ROW
BEGIN
    IF NEW.estado NOT IN ('Operacional', 'Em Manutencao', 'Avariado', 'Abatido') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estado inválido.';
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 7: Impedir eliminação de equipamento com histórico ativo
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_equipamento_proteger_delete$$
CREATE TRIGGER trg_equipamento_proteger_delete
BEFORE DELETE ON Equipamento
FOR EACH ROW
BEGIN
    DECLARE v_manutencoes_ativas INT DEFAULT 0;
    DECLARE v_ordens_abertas INT DEFAULT 0;

    SELECT COUNT(*) INTO v_manutencoes_ativas FROM Manutencao
    WHERE Equipamento_id_equipamento = OLD.id_equipamento AND data_fim IS NULL;

    IF v_manutencoes_ativas > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Não é possível eliminar equipamento com manutenções ativas.';
    END IF;

    SELECT COUNT(*) INTO v_ordens_abertas FROM Ordem_servico os
    INNER JOIN Manutencao m ON os.Manutencao_id_manutencao = m.id_manutencao
    WHERE m.Equipamento_id_equipamento = OLD.id_equipamento AND os.estado_atual != 'Concluida';

    IF v_ordens_abertas > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Não é possível eliminar equipamento com ordens abertas.';
    END IF;
END$$

-- ─────────────────────────────────────────────────────────────
-- TRIGGER 8: Validar coerência de custos (Custo Manutenção >= Custo Peça)
-- ─────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_manutencao_validar_custo_insert$$
CREATE TRIGGER trg_manutencao_validar_custo_insert
BEFORE INSERT ON Manutencao
FOR EACH ROW
BEGIN
    DECLARE v_preco_peca DECIMAL(10,2);

    IF NEW.Peca_id_peca IS NOT NULL THEN
        SELECT preco INTO v_preco_peca
        FROM Peca
        WHERE id_peca = NEW.Peca_id_peca;

        IF NEW.custo < v_preco_peca THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro Financeiro: O custo da manutencao nao pode ser inferior ao preco da peca.';
        END IF;
    END IF;
END$$

DELIMITER ;

--1. registar_avaria
--Abre uma avaria: cria manutencao, cria ordem_servico e marca o equipamento como "Em Manutencao".
USE `mydb`;
DROP PROCEDURE IF EXISTS `registar_avaria`;
DELIMITER $$
CREATE PROCEDURE `registar_avaria`(
   IN p_equipamento_id INT,
   IN p_peca_id INT,
   IN p_tipo_manutencao VARCHAR(45),
   IN p_custo_estimado DECIMAL(10,2),
   IN p_descricao VARCHAR(45),
   IN p_prioridade VARCHAR(45)
)
BEGIN
   DECLARE v_manutencao_id INT;
   DECLARE v_exists INT;
   SELECT COUNT(*) INTO v_exists
   FROM `Equipamento`
   WHERE `id_equipamento` = p_equipamento_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Equipamento inexistente.';
   END IF;
   SELECT COUNT(*) INTO v_exists
   FROM `Peca`
   WHERE `id_peca` = p_peca_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Peca inexistente.';
   END IF;
   -- 1. Regista a manutenção com a data de início atual
   INSERT INTO `Manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `Peca_id_peca`, `Equipamento_id_equipamento`)
   VALUES (p_custo_estimado, p_tipo_manutencao, p_descricao, CURDATE(), p_peca_id, p_equipamento_id);
   -- Captura o ID da manutenção que acabou de ser inserida
   SET v_manutencao_id = LAST_INSERT_ID();
   -- 2. Cria automaticamente a Ordem de Serviço ligada a essa manutenção
   INSERT INTO `Ordem_servico` (`descricao`, `estado_atual`, `prioridade`, `Manutencao_id_manutencao`)
   VALUES (p_descricao, 'Pendente', p_prioridade, v_manutencao_id);
END$$
DELIMITER ;


--2. concluir_manutencao
--Fecha o ciclo: define data_fim da manutencao, conclui ordem_servico e volta equipamento para "Operacional".
USE `mydb`;
DROP PROCEDURE IF EXISTS `concluir_manutencao`;
DELIMITER $$
CREATE PROCEDURE `concluir_manutencao`(
   IN p_manutencao_id INT
)
BEGIN
   DECLARE v_equipamento_id INT;
   DECLARE v_data_fim DATE;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
    SELECT `Equipamento_id_equipamento`, `data_fim`
    INTO v_equipamento_id, v_data_fim
    FROM `Manutencao`
    WHERE `id_manutencao` = p_manutencao_id;
   IF v_equipamento_id IS NULL THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Manutencao inexistente.';
   END IF;
   IF v_data_fim IS NOT NULL THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Manutencao ja concluida.';
   END IF;
   START TRANSACTION;
   -- 1. Fecha a manutencao na data atual
    UPDATE `Manutencao`
    SET `data_fim` = CURDATE()
    WHERE `id_manutencao` = p_manutencao_id;
   COMMIT;
END$$
DELIMITER ;


--3. adicionar_intervencao_tecnico
--Associa tecnico a manutencao/intervencao com cargo e horas iniciais; opcionalmente muda ordem para "Em Execucao".
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_intervencao_tecnico`;
DELIMITER $$
CREATE PROCEDURE `adicionar_intervencao_tecnico`(
   IN p_tecnico_id INT,
   IN p_manutencao_id INT,
   IN p_cargo VARCHAR(45),
   IN p_horas_trabalho INT,
   IN p_mudar_ordem_execucao TINYINT
)
BEGIN
   DECLARE v_exists INT;
   DECLARE v_intervencao_id INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
   IF p_horas_trabalho <= 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Horas de trabalho tem de ser maior que zero.';
   END IF;
    SELECT COUNT(*) INTO v_exists
    FROM `Tecnico`
    WHERE `id_tecnico` = p_tecnico_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Tecnico inexistente.';
   END IF;
    SELECT COUNT(*) INTO v_exists
    FROM `Manutencao`
    WHERE `id_manutencao` = p_manutencao_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Manutencao inexistente.';
   END IF;
   START TRANSACTION;
    INSERT INTO `Intervencao_Tecnico` (`Cargo`, `horas_trabalho`, `Tecnico_id_tecnico`, `Manutencao_id_manutencao`)
    VALUES (p_cargo, p_horas_trabalho, p_tecnico_id, p_manutencao_id);
   SET v_intervencao_id = LAST_INSERT_ID();
   IF p_mudar_ordem_execucao = 1 THEN
             UPDATE `Ordem_servico`
             SET `estado_atual` = 'Em Execução'
             WHERE `Manutencao_id_manutencao` = p_manutencao_id
                 AND `estado_atual` = 'Pendente';
   END IF;
   COMMIT;
   SELECT v_intervencao_id AS intervencao_id, 'Intervencao registada.' AS mensagem;
END$$
DELIMITER ;


--4. abater_equipamento
--Marca equipamento como "Abatido/Inativo" e cancela ordens pendentes relacionadas.
USE `mydb`;
DROP PROCEDURE IF EXISTS `abater_equipamento`;
DELIMITER $$
CREATE PROCEDURE `abater_equipamento`(
   IN p_equipamento_id INT
)
BEGIN
   DECLARE v_exists INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
   SELECT COUNT(*) INTO v_exists
    FROM `Equipamento`
    WHERE `id_equipamento` = p_equipamento_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Equipamento inexistente.';
   END IF;
   START TRANSACTION;
     UPDATE `Equipamento`
     SET `estado` = 'Inativo'
     WHERE `id_equipamento` = p_equipamento_id;
     UPDATE `Ordem_servico` os
     JOIN `Manutencao` m ON m.`id_manutencao` = os.`Manutencao_id_manutencao`
     SET os.`estado_atual` = 'Cancelada'
     WHERE m.`Equipamento_id_equipamento` = p_equipamento_id
         AND os.`estado_atual` IN ('Pendente', 'Em Execução');
   COMMIT;
END$$
DELIMITER ;


--5. alterar_prioridade_ordem
--Atualiza prioridade da ordem_servico validando valores permitidos (Baixa, Media, Alta).
USE `mydb`;
DROP PROCEDURE IF EXISTS `alterar_prioridade_ordem`;
DELIMITER $$
CREATE PROCEDURE `alterar_prioridade_ordem`(
   IN p_ordem_id INT,
   IN p_nova_prioridade VARCHAR(45)
)
BEGIN

   UPDATE `Ordem_servico`
   SET `prioridade` = p_nova_prioridade
   WHERE `id_ordem` = p_ordem_id;
   IF ROW_COUNT() = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
   END IF;
END$$
DELIMITER ;





--7. listar_alertas
--Lista alertas operacionais (ex.: manutencoes antigas, ordens pendentes ha muito tempo, equipamentos parados).
USE `mydb`;
DROP PROCEDURE IF EXISTS `listar_alertas`;
DELIMITER $$
CREATE PROCEDURE `listar_alertas`(
   IN p_dias_manutencao_aberta INT,
   IN p_dias_ordem_pendente INT
)
BEGIN
   IF p_dias_manutencao_aberta <= 0 OR p_dias_ordem_pendente <= 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Os limites de dias devem ser maiores que zero.';
   END IF;
     SELECT
             'MANUTENCAO_ABERTA_ANTIGA' AS alerta,
             m.`id_manutencao` AS manutencao_id,
             e.`id_equipamento` AS equipamento_id,
             e.`designacao` AS equipamento_nome,
             m.`data_inicio`,
             DATEDIFF(CURDATE(), m.`data_inicio`) AS dias_aberta
     FROM `Manutencao` m
     JOIN `Equipamento` e ON e.`id_equipamento` = m.`Equipamento_id_equipamento`
     WHERE m.`data_fim` IS NULL
         AND DATEDIFF(CURDATE(), m.`data_inicio`) >= p_dias_manutencao_aberta
     ORDER BY dias_aberta DESC;
     SELECT
             'ORDEM_PENDENTE_ANTIGA' AS alerta,
             os.`id_ordem` AS ordem_id,
             os.`prioridade`,
             m.`id_manutencao` AS manutencao_id,
             e.`id_equipamento` AS equipamento_id,
             DATEDIFF(CURDATE(), m.`data_inicio`) AS dias_desde_abertura
     FROM `Ordem_servico` os
     JOIN `Manutencao` m ON m.`id_manutencao` = os.`Manutencao_id_manutencao`
     JOIN `Equipamento` e ON e.`id_equipamento` = m.`Equipamento_id_equipamento`
     WHERE os.`estado_atual` = 'Pendente'
         AND DATEDIFF(CURDATE(), m.`data_inicio`) >= p_dias_ordem_pendente
     ORDER BY dias_desde_abertura DESC;
   SELECT
       'EQUIPAMENTO_NAO_OPERACIONAL' AS alerta,
       e.`id_equipamento` AS equipamento_id,
       e.`designacao` AS equipamento_nome,
       e.`estado`
   FROM `Equipamento` e
   WHERE e.`estado` IN ('Em Manutenção', 'Inativo')
   ORDER BY e.`id_equipamento`;
END$$
DELIMITER ;


--8. validar_estado_ordem
--Valida transicoes de estado da ordem_servico (ex.: Pendente -> Em Execucao -> Concluida).
--CORRIGIDO: Agora aceita variantes com e sem acentos em TODAS as comparações
USE `mydb`;
DROP PROCEDURE IF EXISTS `validar_estado_ordem`;
DELIMITER $$
CREATE PROCEDURE `validar_estado_ordem`(
   IN p_ordem_id INT,
   IN p_novo_estado VARCHAR(45)
)
BEGIN
   DECLARE v_estado_atual VARCHAR(45);
   DECLARE v_estado_normalizado VARCHAR(45);
   DECLARE v_transicao_valida TINYINT DEFAULT 0;

   -- Normalizar o novo estado para versão com acentos (padrão da BD)
   SET v_estado_normalizado = CASE p_novo_estado
       WHEN 'Em Execucao' THEN 'Em Execução'
       WHEN 'Concluida' THEN 'Concluída'
       ELSE p_novo_estado
   END;


   SELECT `estado_atual`
   INTO v_estado_atual
   FROM `Ordem_servico`
   WHERE `id_ordem` = p_ordem_id;
   IF v_estado_atual IS NULL THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
   END IF;

   -- Verificar transições válidas (aceitar ambas variantes)
   IF v_estado_atual = v_estado_normalizado THEN
       SET v_transicao_valida = 1;
   ELSEIF (v_estado_atual = 'Pendente' AND v_estado_normalizado IN ('Em Execução', 'Cancelada')) THEN
       SET v_transicao_valida = 1;
   ELSEIF (v_estado_atual = 'Em Execução' AND v_estado_normalizado IN ('Concluída', 'Cancelada')) THEN
       SET v_transicao_valida = 1;
   END IF;

   IF v_transicao_valida = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Transicao de estado invalida para a ordem.';
   END IF;

   -- Usar a versão normalizada para manter consistência
   UPDATE `Ordem_servico`
   SET `estado_atual` = v_estado_normalizado
   WHERE `id_ordem` = p_ordem_id;
END$$
DELIMITER ;


--9. adicionar_responsavel
--Cria responsavel e respetivo contacto_responsavel na mesma operacao/transacao.
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_responsavel`;
DELIMITER $$
CREATE PROCEDURE `adicionar_responsavel`(
   IN p_nome VARCHAR(45),
   IN p_data_nascimento DATE,
   IN p_ordem_servico_id INT,
   IN p_telefone VARCHAR(45),
   IN p_email VARCHAR(45)
)
BEGIN
   DECLARE v_exists INT;
   DECLARE v_responsavel_id INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
   SELECT COUNT(*) INTO v_exists
   FROM `Ordem_servico`
   WHERE `id_ordem` = p_ordem_servico_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
   END IF;
   START TRANSACTION;
   -- criar primeiro o contacto e depois o responsável (conforme modelo lógico)
   INSERT INTO `Contacto_responsavel` (`contacto`, `email`)
   VALUES (p_telefone, p_email);
   SET @v_contacto_id = LAST_INSERT_ID();
   INSERT INTO `Responsavel` (`nome`, `data_nascimento`, `Ordem_de_servico_id_ordem`, `Contacto_responsavel_id_contacto_responsavel`)
   VALUES (p_nome, p_data_nascimento, p_ordem_servico_id, @v_contacto_id);
   SET v_responsavel_id = LAST_INSERT_ID();
   COMMIT;
   SELECT v_responsavel_id AS responsavel_id, 'Responsavel e contacto criados.' AS mensagem;
END$$
DELIMITER ;


--10. adicionar_tecnico
--Cria tecnico e respetivo contacto_tecnico na mesma operacao/transacao.
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_tecnico`;
DELIMITER $$
CREATE PROCEDURE `adicionar_tecnico`(
   IN p_data_inicio_carreira VARCHAR(45),
   IN p_nome VARCHAR(45),
   IN p_especialidade VARCHAR(45),
   IN p_telefone VARCHAR(15),
   IN p_email VARCHAR(45)
)
BEGIN
   DECLARE v_tecnico_id INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
    START TRANSACTION;
    -- criar primeiro o contacto_tecnico e depois o tecnico referenciando-o (modelo lógico)
    INSERT INTO `contacto_tecnico` (`contacto`, `email`)
    VALUES (p_telefone, p_email);
    SET @v_contacto_id = LAST_INSERT_ID();
    INSERT INTO `Tecnico` (`data_inicio_carreira`, `nome`, `especialidade`, `contacto_tecnico_id_contacto_tecnico`)
    VALUES (p_data_inicio_carreira, p_nome, p_especialidade, @v_contacto_id);
    SET v_tecnico_id = LAST_INSERT_ID();
   COMMIT;
   SELECT v_tecnico_id AS tecnico_id, 'Tecnico e contacto criados.' AS mensagem;
END$$
DELIMITER ;


--11. adicionar_peca
--Cria nova peca no catalogo de manutencao (preco, designacao, garantia).
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_peca`;
DELIMITER $$
CREATE PROCEDURE `adicionar_peca`(
   IN p_preco DECIMAL(10,2),
   IN p_designacao VARCHAR(45),
   IN p_garantia DATE
)
BEGIN
   IF p_preco < 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Preco invalido.';
   END IF;
   INSERT INTO `Peca` (`preco`, `designacao`, `garantia`)
   VALUES (p_preco, p_designacao, p_garantia);
   SELECT LAST_INSERT_ID() AS peca_id, 'Peca adicionada.' AS mensagem;
END$$
DELIMITER ;


--12. abater_pecas
--Abate em lote todas as pecas com garantia expirada e sem uso no historico de manutencoes.
USE `mydb`;
DROP PROCEDURE IF EXISTS `abater_pecas`;
DELIMITER $$
CREATE PROCEDURE `abater_pecas`()
BEGIN
     DELETE FROM `Peca` p
     WHERE p.`garantia` < CURDATE()
         AND NOT EXISTS (
                 SELECT 1
                 FROM `Manutencao` m
                 WHERE m.`Peca_id_peca` = p.`id_peca`
         );
     SELECT ROW_COUNT() AS pecas_abatidas, 'Abate de pecas concluido.' AS mensagem;
END$$
DELIMITER ;

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



