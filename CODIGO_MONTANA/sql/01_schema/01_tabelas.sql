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
CREATE TABLE IF NOT EXISTS `mydb`.`Peca` (
  `idPeca` INT NOT NULL AUTO_INCREMENT,
  `preco` DECIMAL NOT NULL,
  `designacao` VARCHAR(45) NOT NULL,
  `garantia` DATE NOT NULL,
  UNIQUE INDEX `idPeça_UNIQUE` (`idPeca` ASC) VISIBLE,
  PRIMARY KEY (`idPeca`))
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `mydb`.`contacto_responsavel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`contacto_responsavel` (
  `idcontacto_responsavel` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`idcontacto_responsavel`),
  UNIQUE INDEX `idcontacto_responsavel_UNIQUE` (`idcontacto_responsavel` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`contacto_tecnico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`contacto_tecnico` (
  `idcontacto_tecnico` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`idcontacto_tecnico`),
  UNIQUE INDEX `idcontacto_tecnico_UNIQUE` (`idcontacto_tecnico` ASC) VISIBLE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Equipamento_contacto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Equipamento_contacto` (
  `idEquipamento_contacto` INT NOT NULL AUTO_INCREMENT,
  `contacto` VARCHAR(15) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`idEquipamento_contacto`),
  UNIQUE INDEX `idEquipamento_contacto_UNIQUE` (`idEquipamento_contacto` ASC) VISIBLE)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `mydb`.`Responsavel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Responsavel` (
  `idResponsavel` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `Ordem de serviço_idOrdem` INT NOT NULL,
  `contacto_responsavel_idcontacto_responsavel` INT NOT NULL,
  INDEX `fk_Responsável_Ordem de serviço1_idx` (`Ordem de serviço_idOrdem` ASC) VISIBLE,
  UNIQUE INDEX `idResponsável_UNIQUE` (`idResponsavel` ASC) VISIBLE,
  PRIMARY KEY (`idResponsavel`, `contacto_responsavel_idcontacto_responsavel`),
  INDEX `fk_Responsavel_contacto_responsavel1_idx` (`contacto_responsavel_idcontacto_responsavel` ASC) VISIBLE,
  CONSTRAINT `fk_Responsável_Ordem de serviço1`
    FOREIGN KEY (`Ordem de serviço_idOrdem`)
    REFERENCES `mydb`.`Ordem_servico` (`idOrdem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Responsavel_contacto_responsavel1`
    FOREIGN KEY (`contacto_responsavel_idcontacto_responsavel`)
    REFERENCES `mydb`.`contacto_responsavel` (`idcontacto_responsavel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `mydb`.`Departamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Departamento` (
  `idDepartamento` INT NOT NULL AUTO_INCREMENT,
  `designacao` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NOT NULL,
  `idResponsavel` INT NOT NULL,
  PRIMARY KEY (`idDepartamento`),
  INDEX `fk_departamento_responsavel_idx` (`idResponsavel` ASC) VISIBLE,
  UNIQUE INDEX `idDepartamento_UNIQUE` (`idDepartamento` ASC) VISIBLE,
  CONSTRAINT `fk_departamento_responsavel`
    FOREIGN KEY (`idResponsavel`)
    REFERENCES `mydb`.`Responsavel` (`idResponsavel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `mydb`.`Localizacao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Localizacao` (
  `idLocalizacao` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NULL,
  `sala` VARCHAR(45) NOT NULL,
  `piso` VARCHAR(45) NOT NULL,
  `edificio` VARCHAR(45) NOT NULL,
  `Departamento_idDepartamento` INT NOT NULL,
  PRIMARY KEY (`idLocalizacao`),
  INDEX `fk_Localização_Departamento1_idx` (`Departamento_idDepartamento` ASC) VISIBLE,
  UNIQUE INDEX `descrição_UNIQUE` (`descricao` ASC) VISIBLE,
  UNIQUE INDEX `idLocalização_UNIQUE` (`idLocalizacao` ASC) VISIBLE,
  CONSTRAINT `fk_Localização_Departamento1`
    FOREIGN KEY (`Departamento_idDepartamento`)
    REFERENCES `mydb`.`Departamento` (`idDepartamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;




-- -----------------------------------------------------
-- Table `mydb`.`Tecnico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Tecnico` (
  `idTecnico` INT NOT NULL AUTO_INCREMENT,
  `data_início_carreira` VARCHAR(45) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `especialidade` VARCHAR(45) NOT NULL,
  `contacto_tecnico_idcontacto_tecnico` INT NOT NULL,
  PRIMARY KEY (`idTecnico`, `contacto_tecnico_idcontacto_tecnico`),
  UNIQUE INDEX `idTecnico_UNIQUE` (`idTecnico` ASC) VISIBLE,
  INDEX `fk_Tecnico_contacto_tecnico1_idx` (`contacto_tecnico_idcontacto_tecnico` ASC) VISIBLE,
  CONSTRAINT `fk_Tecnico_contacto_tecnico1`
    FOREIGN KEY (`contacto_tecnico_idcontacto_tecnico`)
    REFERENCES `mydb`.`contacto_tecnico` (`idcontacto_tecnico`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;




-- -----------------------------------------------------
-- Table `mydb`.`Equipamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Equipamento` (
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
    REFERENCES `mydb`.`Equipamento_contacto` (`idEquipamento_contacto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipamento_Departamento1`
    FOREIGN KEY (`Departamento_idDepartamento`)
    REFERENCES `mydb`.`Departamento` (`idDepartamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipamento_Localizacao1`
    FOREIGN KEY (`Localizacao_idLocalizacao`)
    REFERENCES `mydb`.`Localizacao` (`idLocalizacao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Manutencao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Manutencao` (
  `id_manutencao` INT NOT NULL AUTO_INCREMENT,
  `custo` DECIMAL NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NOT NULL,
  `Peca_idPeca` INT NOT NULL,
  `Equipamento_idEquipamento` INT NOT NULL,
  PRIMARY KEY (`id_manutencao`),
  UNIQUE INDEX `id_manutenção_UNIQUE` (`id_manutencao` ASC) VISIBLE,
  INDEX `fk_Manutenção_Peça1_idx` (`Peca_idPeca` ASC) VISIBLE,
  INDEX `fk_Manutencao_Equipamento1_idx` (`Equipamento_idEquipamento` ASC) VISIBLE,
  CONSTRAINT `fk_Manutenção_Peça1`
    FOREIGN KEY (`Peca_idPeca`)
    REFERENCES `mydb`.`Peca` (`idPeca`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Manutencao_Equipamento1`
    FOREIGN KEY (`Equipamento_idEquipamento`)
    REFERENCES `mydb`.`Equipamento` (`idEquipamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Ordem_servico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Ordem_servico` (
  `idOrdem` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NULL,
  `estado_atual` VARCHAR(45) NOT NULL,
  `prioridade` VARCHAR(45) NOT NULL,
  `Manutencao_id_manutencao` INT NOT NULL,
  PRIMARY KEY (`idOrdem`),
  INDEX `fk_Ordem de serviço_Manutenção1_idx` (`Manutencao_id_manutencao` ASC) VISIBLE,
  UNIQUE INDEX `idOrdem_UNIQUE` (`idOrdem` ASC) VISIBLE,
  CONSTRAINT `fk_Ordem de serviço_Manutenção1`
    FOREIGN KEY (`Manutencao_id_manutencao`)
    REFERENCES `mydb`.`Manutencao` (`id_manutencao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;




-- -----------------------------------------------------
-- Table `mydb`.`Intervencao_Tecnico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Intervencao_Tecnico` (
  `idIntervencao` INT NOT NULL AUTO_INCREMENT,
  `Cargo` VARCHAR(45) NOT NULL,
  `horas_trabalho` INT NOT NULL,
  `Tecnico_idTecnico` INT NOT NULL,
  `Manutencao_id_manutencao` INT NOT NULL,
  UNIQUE INDEX `idIntervenção_UNIQUE` (`idIntervencao` ASC) VISIBLE,
  PRIMARY KEY (`idIntervencao`),
  INDEX `fk_intervencao_tecnico_idx` (`Tecnico_idTecnico` ASC) VISIBLE,
  INDEX `fk_intervencao_manutencao_idx` (`Manutencao_id_manutencao` ASC) VISIBLE,
  CONSTRAINT `fk_intervencao_tecnico`
    FOREIGN KEY (`Tecnico_idTecnico`)
    REFERENCES `mydb`.`Tecnico` (`idTecnico`)
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
