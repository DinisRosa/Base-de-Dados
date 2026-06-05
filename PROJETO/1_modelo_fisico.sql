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
  `Cargo` VARCHAR(45) NOT NULL,s
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



