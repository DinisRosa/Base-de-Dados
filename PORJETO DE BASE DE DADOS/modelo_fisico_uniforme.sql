-- Modelo fisico alternativo com nomes uniformes (snake_case)
-- Nao altera o ficheiro original: modelo_fisico.sql

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP SCHEMA IF EXISTS `mydb_uniforme`;
CREATE SCHEMA `mydb_uniforme` DEFAULT CHARACTER SET utf8mb4;
USE `mydb_uniforme`;

CREATE TABLE `peca` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `preco` DECIMAL(10,2) NOT NULL,
  `designacao` VARCHAR(45) NOT NULL,
  `garantia` DATE NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;


CREATE TABLE `responsavel` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `ordem_servico_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_responsavel_ordem_servico_id` (`ordem_servico_id`)
) ENGINE=InnoDB;

CREATE TABLE `contacto_responsavel` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `telefone` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  `responsavel_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_contacto_responsavel_responsavel_id` (`responsavel_id`),
  CONSTRAINT `fk_contacto_responsavel_responsavel`
    FOREIGN KEY (`responsavel_id`)
    REFERENCES `responsavel` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `departamento` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NOT NULL,
  `responsavel_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_departamento_responsavel_id` (`responsavel_id`),
  CONSTRAINT `fk_departamento_responsavel`
    FOREIGN KEY (`responsavel_id`)
    REFERENCES `responsavel` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `localizacao` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NULL,
  `sala` VARCHAR(45) NOT NULL,
  `piso` VARCHAR(45) NOT NULL,
  `edificio` VARCHAR(45) NOT NULL,
  `departamento_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uq_localizacao_descricao` (`descricao`),
  INDEX `idx_localizacao_departamento_id` (`departamento_id`),
  CONSTRAINT `fk_localizacao_departamento`
    FOREIGN KEY (`departamento_id`)
    REFERENCES `departamento` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `tecnico` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `data_inicio_carreira` VARCHAR(45) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `especialidade` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `contacto_tecnico` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `telefone` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  `tecnico_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_contacto_tecnico_tecnico_id` (`tecnico_id`),
  CONSTRAINT `fk_contacto_tecnico_tecnico`
    FOREIGN KEY (`tecnico_id`)
    REFERENCES `tecnico` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `equipamento` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `estado` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NULL,
  `fabricante` VARCHAR(45) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `data_aquisicao` DATE NOT NULL,
  `departamento_id` INT NOT NULL,
  `localizacao_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_equipamento_departamento_id` (`departamento_id`),
  INDEX `idx_equipamento_localizacao_id` (`localizacao_id`),
  CONSTRAINT `fk_equipamento_departamento`
    FOREIGN KEY (`departamento_id`)
    REFERENCES `departamento` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_equipamento_localizacao`
    FOREIGN KEY (`localizacao_id`)
    REFERENCES `localizacao` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `contacto_equipamento` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `telefone` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  `equipamento_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_contacto_equipamento_equipamento_id` (`equipamento_id`),
  CONSTRAINT `fk_contacto_equipamento_equipamento`
    FOREIGN KEY (`equipamento_id`)
    REFERENCES `equipamento` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `manutencao` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `custo` DECIMAL(10,2) NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NULL,
  `peca_id` INT NOT NULL,
  `equipamento_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_manutencao_peca_id` (`peca_id`),
  INDEX `idx_manutencao_equipamento_id` (`equipamento_id`),
  CONSTRAINT `fk_manutencao_peca`
    FOREIGN KEY (`peca_id`)
    REFERENCES `peca` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_manutencao_equipamento`
    FOREIGN KEY (`equipamento_id`)
    REFERENCES `equipamento` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `ordem_servico` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NULL,
  `estado_atual` VARCHAR(45) NOT NULL,
  `prioridade` VARCHAR(45) NOT NULL,
  `manutencao_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_ordem_servico_manutencao_id` (`manutencao_id`),
  CONSTRAINT `fk_ordem_servico_manutencao`
    FOREIGN KEY (`manutencao_id`)
    REFERENCES `manutencao` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE `intervencao_tecnico` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cargo` VARCHAR(45) NOT NULL,
  `horas_trabalho` INT NOT NULL,
  `tecnico_id` INT NOT NULL,
  `manutencao_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_intervencao_tecnico_tecnico_id` (`tecnico_id`),
  INDEX `idx_intervencao_tecnico_manutencao_id` (`manutencao_id`),
  CONSTRAINT `fk_intervencao_tecnico_tecnico`
    FOREIGN KEY (`tecnico_id`)
    REFERENCES `tecnico` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_intervencao_tecnico_manutencao`
    FOREIGN KEY (`manutencao_id`)
    REFERENCES `manutencao` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
