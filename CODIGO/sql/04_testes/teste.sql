-- ============================================================
--  SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
--  Ficheiro 01: Criação de Tabelas e Constraints
--  Compatível com MySQL 8.0+ / MySQL Workbench
--  Modelo: mod_conceptual_novas_modificacoes (versão corrigida)
-- ============================================================
--
--  ALTERAÇÕES FACE À VERSÃO ANTERIOR:
--  [1] Removida tabela MANUTENCAO_ORDEM (era N:M indevido)
--      → relação "origina" é N:1: FK id_ordem adicionada em MANUTENCAO
--  [2] Adicionada FK id_responsavel em ORDEM_SERVICO
--      → relação "aprova": 1 Responsável aprova N Ordens
--  [3] Adicionada tabela EQUIPAMENTO_RESPONSAVEL (N:M)
--      → relação "tem" entre Equipamento e Responsável
--  [4] Atributo "garantia" em PECA alinhado com o ER
--      (mantida validade_peca como alias — ver nota abaixo)
--  [5] Adicionado atributo idade_equipamento em EQUIPAMENTO
--      conforme o modelo ER
-- ============================================================
 
CREATE DATABASE IF NOT EXISTS gestao_equipamentos;
USE gestao_equipamentos;
 
-- ============================================================
-- LIMPEZA (descomente para reset completo)
-- ============================================================
/*
DROP TABLE IF EXISTS INTERVENCAO_TECNICO;
DROP TABLE IF EXISTS MANUTENCAO_PECA;
DROP TABLE IF EXISTS EQUIPAMENTO_RESPONSAVEL;
DROP TABLE IF EXISTS MANUTENCAO;
DROP TABLE IF EXISTS ORDEM_SERVICO;
DROP TABLE IF EXISTS PECA;
DROP TABLE IF EXISTS EQUIPAMENTO_CONTACTO_SUPORTE;
DROP TABLE IF EXISTS EQUIPAMENTO;
DROP TABLE IF EXISTS TECNICO_CONTACTO;
DROP TABLE IF EXISTS TECNICO;
DROP TABLE IF EXISTS RESPONSAVEL_CONTACTO;
DROP TABLE IF EXISTS RESPONSAVEL;
DROP TABLE IF EXISTS DEPARTAMENTO;
DROP TABLE IF EXISTS LOCALIZACAO;
DROP TABLE IF EXISTS AUDITORIA_EQUIPAMENTO;
*/
 
-- ============================================================
-- LOCALIZACAO: Localização física do equipamento
-- ============================================================
CREATE TABLE LOCALIZACAO (
    id_localizacao INT          NOT NULL AUTO_INCREMENT,
    descricao      VARCHAR(255),                          -- adicionado: atributo "descrição" do ER
    sala           VARCHAR(50)  NOT NULL,
    piso           VARCHAR(20)  NOT NULL,
    edificio       VARCHAR(100) NOT NULL,
    CONSTRAINT pk_localizacao PRIMARY KEY (id_localizacao)
) ENGINE=InnoDB;
 
-- ============================================================
-- DEPARTAMENTO: Departamentos clínicos do hospital
-- ============================================================
CREATE TABLE DEPARTAMENTO (
    id_departamento INT          NOT NULL AUTO_INCREMENT,
    designacao      VARCHAR(100) NOT NULL,
    descricao       VARCHAR(255),
    CONSTRAINT pk_departamento PRIMARY KEY (id_departamento)
) ENGINE=InnoDB;
 
-- ============================================================
-- RESPONSAVEL: Responsável por um departamento (N:1)
-- ============================================================
CREATE TABLE RESPONSAVEL (
    id_responsavel  INT          NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(150) NOT NULL,
    data_nascimento DATE         NOT NULL,
    id_departamento INT          NOT NULL,               -- FK: Responsável gere Departamento
    CONSTRAINT pk_responsavel PRIMARY KEY (id_responsavel),
    CONSTRAINT fk_resp_dept   FOREIGN KEY (id_departamento)
        REFERENCES DEPARTAMENTO(id_departamento)
) ENGINE=InnoDB;
 
-- Atributo multivalorado: contactos do responsável
CREATE TABLE RESPONSAVEL_CONTACTO (
    id_responsavel INT          NOT NULL,
    contacto       VARCHAR(100) NOT NULL,
    CONSTRAINT pk_resp_cont  PRIMARY KEY (id_responsavel, contacto),
    CONSTRAINT fk_rcont_resp FOREIGN KEY (id_responsavel)
        REFERENCES RESPONSAVEL(id_responsavel) ON DELETE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================
-- EQUIPAMENTO: Equipamento médico
-- ============================================================
CREATE TABLE EQUIPAMENTO (
    id_equipamento    INT           NOT NULL AUTO_INCREMENT,
    designacao        VARCHAR(150)  NOT NULL,
    descricao         VARCHAR(500),
    fabricante        VARCHAR(100)  NOT NULL,
    estado            VARCHAR(50)   NOT NULL DEFAULT 'Operacional',
    data_aquisicao    DATE          NOT NULL,
    idade_equipamento INT           DEFAULT 0,           -- [5] adicionado conforme ER
    id_localizacao    INT,                               -- FK: Equipamento tem Localização (N:1)
    id_departamento   INT,                               -- FK: Equipamento pertence Departamento (N:1)
    CONSTRAINT pk_equipamento PRIMARY KEY (id_equipamento),
    CONSTRAINT fk_equip_loc   FOREIGN KEY (id_localizacao)
        REFERENCES LOCALIZACAO(id_localizacao),
    CONSTRAINT fk_equip_dept  FOREIGN KEY (id_departamento)
        REFERENCES DEPARTAMENTO(id_departamento),
    CONSTRAINT chk_estado     CHECK (estado IN (
        'Operacional','Em Manutenção','Avariado','Desativado','Em Calibração')),
    CONSTRAINT chk_idade      CHECK (idade_equipamento >= 0)
) ENGINE=InnoDB;
 
-- Atributo multivalorado: contactos de suporte do fabricante
CREATE TABLE EQUIPAMENTO_CONTACTO_SUPORTE (
    id_equipamento   INT          NOT NULL,
    contacto_suporte VARCHAR(100) NOT NULL,
    CONSTRAINT pk_equip_cont  PRIMARY KEY (id_equipamento, contacto_suporte),
    CONSTRAINT fk_econt_equip FOREIGN KEY (id_equipamento)
        REFERENCES EQUIPAMENTO(id_equipamento) ON DELETE CASCADE
) ENGINE=InnoDB;
 
-- [3] Tabela associativa N:M: Equipamento tem Responsável
CREATE TABLE EQUIPAMENTO_RESPONSAVEL (
    id_equipamento INT NOT NULL,
    id_responsavel INT NOT NULL,
    CONSTRAINT pk_equip_resp  PRIMARY KEY (id_equipamento, id_responsavel),
    CONSTRAINT fk_er_equip    FOREIGN KEY (id_equipamento)
        REFERENCES EQUIPAMENTO(id_equipamento) ON DELETE CASCADE,
    CONSTRAINT fk_er_resp     FOREIGN KEY (id_responsavel)
        REFERENCES RESPONSAVEL(id_responsavel)
) ENGINE=InnoDB;
 
-- ============================================================
-- TECNICO: Técnico de manutenção de equipamentos médicos
-- ============================================================
CREATE TABLE TECNICO (
    id_tecnico           INT          NOT NULL AUTO_INCREMENT,
    nome                 VARCHAR(150) NOT NULL,
    especialidade        VARCHAR(100) NOT NULL,
    data_inicio_carreira DATE         NOT NULL,
    anos_experiencia     INT          DEFAULT 0,
    CONSTRAINT pk_tecnico    PRIMARY KEY (id_tecnico),
    CONSTRAINT chk_anos_exp  CHECK (anos_experiencia >= 0)
) ENGINE=InnoDB;
 
-- Atributo multivalorado: contactos do técnico
CREATE TABLE TECNICO_CONTACTO (
    id_tecnico INT          NOT NULL,
    contacto   VARCHAR(100) NOT NULL,
    CONSTRAINT pk_tec_cont  PRIMARY KEY (id_tecnico, contacto),
    CONSTRAINT fk_tcont_tec FOREIGN KEY (id_tecnico)
        REFERENCES TECNICO(id_tecnico) ON DELETE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================
-- PECA: Peças de substituição usadas nas manutenções
-- ============================================================
CREATE TABLE PECA (
    id_peca       INT           NOT NULL AUTO_INCREMENT,
    designacao    VARCHAR(150)  NOT NULL,
    preco         DECIMAL(10,2) NOT NULL,
    garantia      DATE,                                  -- [4] nome alinhado com ER (= validade_peca)
    CONSTRAINT pk_peca    PRIMARY KEY (id_peca),
    CONSTRAINT chk_preco  CHECK (preco >= 0)
) ENGINE=InnoDB;
 
-- ============================================================
-- ORDEM_SERVICO: Ordens de serviço
-- ============================================================
CREATE TABLE ORDEM_SERVICO (
    id_ordem       INT          NOT NULL AUTO_INCREMENT,
    descricao      VARCHAR(500) NOT NULL,
    estado_atual   VARCHAR(50)  NOT NULL DEFAULT 'Pendente',
    data_criacao   DATE         NOT NULL DEFAULT (CURDATE()),
    prioridade     VARCHAR(20)  NOT NULL DEFAULT 'Normal',
    id_responsavel INT,                                  -- [2] FK: Responsável aprova Ordem (N:1)
    CONSTRAINT pk_ordem       PRIMARY KEY (id_ordem),
    CONSTRAINT fk_os_resp     FOREIGN KEY (id_responsavel)
        REFERENCES RESPONSAVEL(id_responsavel),
    CONSTRAINT chk_estado_os  CHECK (estado_atual IN (
        'Pendente','Em Curso','Concluída','Cancelada')),
    CONSTRAINT chk_prioridade CHECK (prioridade IN (
        'Baixa','Normal','Alta','Crítica'))
) ENGINE=InnoDB;
 
-- ============================================================
-- MANUTENCAO: Registo de manutenção efetuada a um equipamento
-- ============================================================
CREATE TABLE MANUTENCAO (
    id_manutencao  INT            NOT NULL AUTO_INCREMENT,
    tipo           VARCHAR(50)    NOT NULL,
    descricao      VARCHAR(500),
    custo          DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    duracao        INT            DEFAULT 0,
    data_inicio    DATE           NOT NULL,
    data_fim       DATE,
    id_equipamento INT            NOT NULL,              -- FK: Manutenção pertence a Equipamento (N:1)
    id_ordem       INT,                                  -- [1] FK: Manutenção origina Ordem (N:1)
    CONSTRAINT pk_manutencao  PRIMARY KEY (id_manutencao),
    CONSTRAINT fk_man_equip   FOREIGN KEY (id_equipamento)
        REFERENCES EQUIPAMENTO(id_equipamento),
    CONSTRAINT fk_man_ordem   FOREIGN KEY (id_ordem)
        REFERENCES ORDEM_SERVICO(id_ordem),
    CONSTRAINT chk_tipo_man   CHECK (tipo IN (
        'Preventiva','Corretiva','Calibração','Inspeção')),
    CONSTRAINT chk_custo      CHECK (custo >= 0),
    CONSTRAINT chk_duracao    CHECK (duracao >= 0),
    CONSTRAINT chk_datas_man  CHECK (data_fim IS NULL OR data_fim >= data_inicio)
) ENGINE=InnoDB;
 
-- Tabela associativa N:M: Manutenção utiliza Peça
CREATE TABLE MANUTENCAO_PECA (
    id_manutencao INT          NOT NULL,
    id_peca       INT          NOT NULL,
    quantidade    INT          NOT NULL DEFAULT 1,
    CONSTRAINT pk_man_peca PRIMARY KEY (id_manutencao, id_peca),
    CONSTRAINT fk_mp_man   FOREIGN KEY (id_manutencao)
        REFERENCES MANUTENCAO(id_manutencao) ON DELETE CASCADE,
    CONSTRAINT fk_mp_peca  FOREIGN KEY (id_peca)
        REFERENCES PECA(id_peca),
    CONSTRAINT chk_qtd     CHECK (quantidade > 0)
) ENGINE=InnoDB;
 
-- ============================================================
-- INTERVENCAO_TECNICO: Entidade relacional N:M
-- Liga MANUTENCAO e TECNICO com atributos próprios
-- ============================================================
CREATE TABLE INTERVENCAO_TECNICO (
    id_intervencao INT           NOT NULL AUTO_INCREMENT,
    id_manutencao  INT           NOT NULL,
    id_tecnico     INT           NOT NULL,
    cargo          VARCHAR(100)  NOT NULL,
    horas_trabalho DECIMAL(5,1)  NOT NULL,
    CONSTRAINT pk_intervencao PRIMARY KEY (id_intervencao),
    CONSTRAINT uq_man_tec     UNIQUE (id_manutencao, id_tecnico),
    CONSTRAINT fk_it_man      FOREIGN KEY (id_manutencao)
        REFERENCES MANUTENCAO(id_manutencao) ON DELETE CASCADE,
    CONSTRAINT fk_it_tec      FOREIGN KEY (id_tecnico)
        REFERENCES TECNICO(id_tecnico),
    CONSTRAINT chk_horas      CHECK (horas_trabalho > 0)
) ENGINE=InnoDB;
 
-- ============================================================
-- AUDITORIA_EQUIPAMENTO: Log automático de mudanças de estado
-- ============================================================
CREATE TABLE AUDITORIA_EQUIPAMENTO (
    id_auditoria   INT          NOT NULL AUTO_INCREMENT,
    id_equipamento INT          NOT NULL,
    estado_antigo  VARCHAR(50),
    estado_novo    VARCHAR(50),
    data_alteracao DATETIME     NOT NULL DEFAULT NOW(),
    utilizador     VARCHAR(100) DEFAULT (USER()),
    CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria)
) ENGINE=InnoDB;
 
-- ============================================================
-- ÍNDICES para performance
-- ============================================================
CREATE INDEX idx_equip_loc    ON EQUIPAMENTO(id_localizacao);
CREATE INDEX idx_equip_dept   ON EQUIPAMENTO(id_departamento);
CREATE INDEX idx_equip_estado ON EQUIPAMENTO(estado);
CREATE INDEX idx_man_equip    ON MANUTENCAO(id_equipamento);
CREATE INDEX idx_man_ordem    ON MANUTENCAO(id_ordem);
CREATE INDEX idx_man_datas    ON MANUTENCAO(data_inicio, data_fim);
CREATE INDEX idx_os_estado    ON ORDEM_SERVICO(estado_atual, prioridade);
CREATE INDEX idx_os_resp      ON ORDEM_SERVICO(id_responsavel);
CREATE INDEX idx_aud_equip    ON AUDITORIA_EQUIPAMENTO(id_equipamento);
CREATE INDEX idx_it_tec       ON INTERVENCAO_TECNICO(id_tecnico);
 
-- ============================================================
-- FIM DO FICHEIRO 01_tabelas_corrigido.sql
-- ============================================================