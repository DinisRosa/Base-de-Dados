-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS - MODELO FÍSICO
-- Ficheiro 01: Criação de Tabelas e Constraints
-- Compatível com MySQL 8.0+
-- Modelo: modelo_fisico.sql (Montana)
-- ============================================================

-- Criar schema
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;
USE `mydb`;

-- ============================================================
-- LIMPEZA (descomente para reset completo)
-- ============================================================
/*
DROP TABLE IF EXISTS `Intervencao_Tecnico`;
DROP TABLE IF EXISTS `Manutencao`;
DROP TABLE IF EXISTS `Ordem_servico`;
DROP TABLE IF EXISTS `Equipamento`;
DROP TABLE IF EXISTS `Tecnico`;
DROP TABLE IF EXISTS `Localizacao`;
DROP TABLE IF EXISTS `Departamento`;
DROP TABLE IF EXISTS `Responsavel`;
DROP TABLE IF EXISTS `Peca`;
DROP TABLE IF EXISTS `contacto_tecnico`;
DROP TABLE IF EXISTS `contacto_responsavel`;
DROP TABLE IF EXISTS `Equipamento_contacto`;
*/

-- ============================================================
-- Table: Peca
-- Descrição: Peças e componentes do equipamento
-- ============================================================
CREATE TABLE IF NOT EXISTS `Peca` (
  `idPeca` INT NOT NULL AUTO_INCREMENT,
  `preco` DECIMAL(10,2) NOT NULL,
  `designacao` VARCHAR(45) NOT NULL,
  `garantia` DATE NOT NULL,
  UNIQUE INDEX `idPeça_UNIQUE` (`idPeca` ASC) VISIBLE,
  PRIMARY KEY (`idPeca`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: contacto_responsavel
-- Descrição: Contactos dos responsáveis
-- ============================================================
CREATE TABLE IF NOT EXISTS `contacto_responsavel` (
  `idcontacto_responsavel` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`idcontacto_responsavel`),
  UNIQUE INDEX `idcontacto_responsavel_UNIQUE` (`idcontacto_responsavel` ASC) VISIBLE
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: contacto_tecnico
-- Descrição: Contactos dos técnicos
-- ============================================================
CREATE TABLE IF NOT EXISTS `contacto_tecnico` (
  `idcontacto_tecnico` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`idcontacto_tecnico`),
  UNIQUE INDEX `idcontacto_tecnico_UNIQUE` (`idcontacto_tecnico` ASC) VISIBLE
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Equipamento_contacto
-- Descrição: Contactos de suporte dos equipamentos
-- ============================================================
CREATE TABLE IF NOT EXISTS `Equipamento_contacto` (
  `idEquipamento_contacto` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`idEquipamento_contacto`),
  UNIQUE INDEX `idEquipamento_contacto_UNIQUE` (`idEquipamento_contacto` ASC) VISIBLE
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Responsavel
-- Descrição: Responsáveis pelos departamentos
-- ============================================================
CREATE TABLE IF NOT EXISTS `Responsavel` (
  `idResponsavel` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `Ordem_de_servico_idOrdem` INT,
  `contacto_responsavel_idcontacto_responsavel` INT NOT NULL,
  INDEX `fk_Responsavel_Ordem_de_servico1_idx` (`Ordem_de_servico_idOrdem` ASC) VISIBLE,
  UNIQUE INDEX `idResponsavel_UNIQUE` (`idResponsavel` ASC) VISIBLE,
  PRIMARY KEY (`idResponsavel`),
  INDEX `fk_Responsavel_contacto_responsavel1_idx` (`contacto_responsavel_idcontacto_responsavel` ASC) VISIBLE,
  CONSTRAINT `fk_Responsavel_contacto_responsavel1`
    FOREIGN KEY (`contacto_responsavel_idcontacto_responsavel`)
    REFERENCES `contacto_responsavel` (`idcontacto_responsavel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Departamento
-- Descrição: Departamentos clínicos do hospital
-- ============================================================
CREATE TABLE IF NOT EXISTS `Departamento` (
  `idDepartamento` INT NOT NULL AUTO_INCREMENT,
  `designacao` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NOT NULL,
  `idResponsavel` INT NOT NULL,
  PRIMARY KEY (`idDepartamento`),
  INDEX `fk_departamento_responsavel_idx` (`idResponsavel` ASC) VISIBLE,
  UNIQUE INDEX `idDepartamento_UNIQUE` (`idDepartamento` ASC) VISIBLE,
  CONSTRAINT `fk_departamento_responsavel`
    FOREIGN KEY (`idResponsavel`)
    REFERENCES `Responsavel` (`idResponsavel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Localizacao
-- Descrição: Localização física dos equipamentos
-- ============================================================
CREATE TABLE IF NOT EXISTS `Localizacao` (
  `idLocalizacao` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NULL,
  `sala` VARCHAR(45) NOT NULL,
  `piso` VARCHAR(45) NOT NULL,
  `edificio` VARCHAR(45) NOT NULL,
  `Departamento_idDepartamento` INT NOT NULL,
  PRIMARY KEY (`idLocalizacao`),
  INDEX `fk_Localizacao_Departamento1_idx` (`Departamento_idDepartamento` ASC) VISIBLE,
  UNIQUE INDEX `descrição_UNIQUE` (`descricao` ASC) VISIBLE,
  UNIQUE INDEX `idLocalizacao_UNIQUE` (`idLocalizacao` ASC) VISIBLE,
  CONSTRAINT `fk_Localizacao_Departamento1`
    FOREIGN KEY (`Departamento_idDepartamento`)
    REFERENCES `Departamento` (`idDepartamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Tecnico
-- Descrição: Técnicos de manutenção
-- ============================================================
CREATE TABLE IF NOT EXISTS `Tecnico` (
  `idTecnico` INT NOT NULL AUTO_INCREMENT,
  `data_inicio_carreira` VARCHAR(45) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `especialidade` VARCHAR(45) NOT NULL,
  `contacto_tecnico_idcontacto_tecnico` INT NOT NULL,
  PRIMARY KEY (`idTecnico`),
  UNIQUE INDEX `idTecnico_UNIQUE` (`idTecnico` ASC) VISIBLE,
  INDEX `fk_Tecnico_contacto_tecnico1_idx` (`contacto_tecnico_idcontacto_tecnico` ASC) VISIBLE,
  CONSTRAINT `fk_Tecnico_contacto_tecnico1`
    FOREIGN KEY (`contacto_tecnico_idcontacto_tecnico`)
    REFERENCES `contacto_tecnico` (`idcontacto_tecnico`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Equipamento
-- Descrição: Equipamentos médicos
-- ============================================================
CREATE TABLE IF NOT EXISTS `Equipamento` (
  `idEquipamento` INT NOT NULL AUTO_INCREMENT,
  `estado` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NULL,
  `fabricante` VARCHAR(45) NOT NULL,
  `designacao` VARCHAR(45) NOT NULL,
  `data_aquisicao` DATE NOT NULL,
  `Equipamento_contacto_idEquipamento_contacto1` INT NOT NULL,
  `Departamento_idDepartamento` INT NOT NULL,
  `Localizacao_idLocalizacao` INT NOT NULL,
  PRIMARY KEY (`idEquipamento`),
  UNIQUE INDEX `idEquipamento_UNIQUE` (`idEquipamento` ASC) VISIBLE,
  INDEX `fk_Equipamento_Equipamento_contacto1_idx` (`Equipamento_contacto_idEquipamento_contacto1` ASC) VISIBLE,
  INDEX `fk_Equipamento_Departamento1_idx` (`Departamento_idDepartamento` ASC) VISIBLE,
  INDEX `fk_Equipamento_Localizacao1_idx` (`Localizacao_idLocalizacao` ASC) VISIBLE,
  CONSTRAINT `fk_Equipamento_Equipamento_contacto1`
    FOREIGN KEY (`Equipamento_contacto_idEquipamento_contacto1`)
    REFERENCES `Equipamento_contacto` (`idEquipamento_contacto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipamento_Departamento1`
    FOREIGN KEY (`Departamento_idDepartamento`)
    REFERENCES `Departamento` (`idDepartamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipamento_Localizacao1`
    FOREIGN KEY (`Localizacao_idLocalizacao`)
    REFERENCES `Localizacao` (`idLocalizacao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Manutencao
-- Descrição: Registos de manutenção de equipamentos
-- ============================================================
CREATE TABLE IF NOT EXISTS `Manutencao` (
  `id_manutencao` INT NOT NULL AUTO_INCREMENT,
  `custo` DECIMAL(10,2) NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NOT NULL,
  `Peca_idPeca` INT NOT NULL,
  `Equipamento_idEquipamento` INT NOT NULL,
  PRIMARY KEY (`id_manutencao`),
  UNIQUE INDEX `id_manutencao_UNIQUE` (`id_manutencao` ASC) VISIBLE,
  INDEX `fk_Manutencao_Peca1_idx` (`Peca_idPeca` ASC) VISIBLE,
  INDEX `fk_Manutencao_Equipamento1_idx` (`Equipamento_idEquipamento` ASC) VISIBLE,
  CONSTRAINT `fk_Manutencao_Peca1`
    FOREIGN KEY (`Peca_idPeca`)
    REFERENCES `Peca` (`idPeca`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Manutencao_Equipamento1`
    FOREIGN KEY (`Equipamento_idEquipamento`)
    REFERENCES `Equipamento` (`idEquipamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Ordem_servico
-- Descrição: Ordens de serviço de manutenção
-- ============================================================
CREATE TABLE IF NOT EXISTS `Ordem_servico` (
  `idOrdem` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NULL,
  `estado_atual` VARCHAR(45) NOT NULL,
  `prioridade` VARCHAR(45) NOT NULL,
  `Manutencao_id_manutencao` INT NOT NULL,
  PRIMARY KEY (`idOrdem`),
  INDEX `fk_Ordem_servico_Manutencao1_idx` (`Manutencao_id_manutencao` ASC) VISIBLE,
  UNIQUE INDEX `idOrdem_UNIQUE` (`idOrdem` ASC) VISIBLE,
  CONSTRAINT `fk_Ordem_servico_Manutencao1`
    FOREIGN KEY (`Manutencao_id_manutencao`)
    REFERENCES `Manutencao` (`id_manutencao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Table: Intervencao_Tecnico
-- Descrição: Intervenções dos técnicos em manutenções
-- ============================================================
CREATE TABLE IF NOT EXISTS `Intervencao_Tecnico` (
  `idIntervencao` INT NOT NULL AUTO_INCREMENT,
  `Cargo` VARCHAR(45) NOT NULL,
  `horas_trabalho` INT NOT NULL,
  `Tecnico_idTecnico` INT NOT NULL,
  `Manutencao_id_manutencao` INT NOT NULL,
  UNIQUE INDEX `idIntervencao_UNIQUE` (`idIntervencao` ASC) VISIBLE,
  PRIMARY KEY (`idIntervencao`),
  INDEX `fk_intervencao_tecnico_idx` (`Tecnico_idTecnico` ASC) VISIBLE,
  INDEX `fk_intervencao_manutencao_idx` (`Manutencao_id_manutencao` ASC) VISIBLE,
  CONSTRAINT `fk_intervencao_tecnico`
    FOREIGN KEY (`Tecnico_idTecnico`)
    REFERENCES `Tecnico` (`idTecnico`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_intervencao_manutencao`
    FOREIGN KEY (`Manutencao_id_manutencao`)
    REFERENCES `Manutencao` (`id_manutencao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- ============================================================
-- Fim da Criação de Tabelas
-- ============================================================
