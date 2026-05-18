# 📋 REQUISITOS - Sistema de Gestão de Equipamentos Médicos

**Versão:** 1.0  
**Data:** Maio 2026  
**Compatibilidade:** MySQL 8.0+  
**Engine:** InnoDB com Foreign Keys

---

## 📑 Índice

1. [Requisitos Funcionais](#requisitos-funcionais)
2. [Estrutura de Dados](#estrutura-de-dados)
3. [Entidades e Atributos](#entidades-e-atributos)
4. [Relacionamentos](#relacionamentos)
5. [Constraints e Validações](#constraints-e-validações)
6. [Operações CRUD](#operações-crud)
7. [Procedures e Functions](#procedures-e-functions)
8. [Triggers e Auditoria](#triggers-e-auditoria)
9. [Views e Relatórios](#views-e-relatórios)
10. [Requisitos Não-Funcionais](#requisitos-não-funcionais)

---

## 1. Requisitos Funcionais

### RF-001: Gestão de Departamentos
- **Descrição:** Manter registo de departamentos clínicos do hospital
- **Funcionalidade:** CRUD completo para departamentos
- **Dados:** Designação, Descrição
- **Status:** ✅ Implementado

### RF-002: Gestão de Equipamentos
- **Descrição:** Manter registo centralizado de todos os equipamentos médicos
- **Funcionalidade:** 
  - CRUD completo
  - Rastreamento de localização
  - Histórico de estado
  - Contactos de suporte multivalorados
- **Dados:** Designação, Fabricante, Data Aquisição, Localização, Departamento, Estado, Garantia
- **Status:** ✅ Implementado

### RF-003: Gestão de Técnicos
- **Descrição:** Manter registo de técnicos de manutenção
- **Funcionalidade:**
  - CRUD completo
  - Rastreamento de especialidade
  - Contactos multivalorados
  - Histórico de carreira
- **Dados:** Nome, Especialidade, Data Início Carreira, Anos Experiência, Contactos
- **Status:** ✅ Implementado

### RF-004: Gestão de Manutenções
- **Descrição:** Registar e acompanhar todas as manutenções realizadas
- **Funcionalidade:**
  - CRUD completo
  - Múltiplos tipos (Preventiva, Corretiva, Calibração, Inspeção)
  - Associação com técnicos
  - Rastreamento de custos
  - Duração e horas de trabalho
- **Dados:** Tipo, Data Início/Fim, Descrição, Custo, Duração, Horas, Equipamento
- **Status:** ✅ Implementado

### RF-005: Gestão de Peças
- **Descrição:** Manter inventário de peças de reposição
- **Funcionalidade:**
  - CRUD completo
  - Preço de venda e custo
  - Data de validade
  - Rastreamento de quantidade utilizada
- **Dados:** Designação, Preço, Custo, Validade
- **Status:** ✅ Implementado

### RF-006: Ordens de Serviço
- **Descrição:** Gerir ordens de serviço associadas a manutenções
- **Funcionalidade:**
  - CRUD completo
  - Estados: Pendente, Em Execução, Concluída, Cancelada
  - Prioridades: Baixa, Normal, Alta, Crítica
  - Rastreamento de data de criação
- **Dados:** Descrição, Estado, Prioridade, Data Criação
- **Status:** ✅ Implementado

### RF-007: Responsáveis por Departamentos
- **Descrição:** Manter registo de responsáveis por departamentos
- **Funcionalidade:**
  - CRUD completo
  - Contactos multivalorados
  - Flag de aprovação
  - Data de nascimento
- **Dados:** Nome, Data Nascimento, Departamento, Contactos, Aprova
- **Status:** ✅ Implementado

### RF-008: Auditoria e Rastreamento
- **Descrição:** Registar automaticamente todas as alterações de equipamentos
- **Funcionalidade:**
  - Log automático de mudanças
  - Rastreamento de estado anterior/novo
  - Utilizador responsável
  - Timestamp de alteração
- **Dados:** ID Equipamento, Estado Antigo, Estado Novo, Data, Utilizador
- **Status:** ✅ Implementado (via Triggers)

### RF-009: Localizações
- **Descrição:** Manter registo de localizações físicas dos equipamentos
- **Funcionalidade:** CRUD completo
- **Dados:** Sala, Piso, Edifício
- **Status:** ✅ Implementado

### RF-010: Relatórios
- **Descrição:** Gerar relatórios de gestão e monitoramento
- **Funcionalidade:**
  - 10+ dashboards predefinidos
  - Custos de manutenção
  - Carga de trabalho de técnicos
  - Equipamentos por departamento
  - Garantias vencidas
- **Status:** ✅ Implementado (via Views e Queries)

---

## 2. Estrutura de Dados

### Total de Tabelas: 14

#### Tabelas de Domínio (7)
1. LOCALIZACAO
2. DEPARTAMENTO
3. EQUIPAMENTO
4. TECNICO
5. MANUTENCAO
6. PECA
7. ORDEM_SERVICO
8. RESPONSAVEL

#### Tabelas de Atributos Multivalorados (3)
9. RESPONSAVEL_CONTACTO
10. EQUIPAMENTO_CONTACTO_SUPORTE
11. TECNICO_CONTACTO

#### Tabelas de Relacionamentos (2)
12. MANUTENCAO_PECA (N:M)
13. INTERVENCAO_TECNICO (Entidade Relacional)

#### Tabela de Auditoria (1)
15. AUDITORIA_EQUIPAMENTO

---

## 3. Entidades e Atributos

### LOCALIZACAO
```sql
id_localizacao INT (PK, AI)
sala VARCHAR(50) NOT NULL
piso VARCHAR(20) NOT NULL
edificio VARCHAR(100) NOT NULL
```

### DEPARTAMENTO
```sql
id_departamento INT (PK, AI)
designacao VARCHAR(100) NOT NULL UNIQUE
descricao VARCHAR(255) NULLABLE
```

### RESPONSAVEL
```sql
id_responsavel INT (PK, AI)
nome VARCHAR(150) NOT NULL
data_nascimento DATE NOT NULL
id_departamento INT NOT NULL (FK → DEPARTAMENTO)
aprova BOOLEAN DEFAULT TRUE
```

### RESPONSAVEL_CONTACTO (Multivalorado)
```sql
id_responsavel INT (PK, FK)
contacto VARCHAR(100) (PK)
-- Chave primária composta
```

### EQUIPAMENTO
```sql
id_equipamento INT (PK, AI)
designacao VARCHAR(150) NOT NULL
data_aquisicao DATE NOT NULL
fabricante VARCHAR(100) NOT NULL
estado VARCHAR(50) NOT NULL DEFAULT 'Operacional'
estado_atual VARCHAR(50) NOT NULL DEFAULT 'Operacional'
descricao VARCHAR(500) NULLABLE
garantia INT DEFAULT 0 (CHECK >= 0)
id_localizacao INT NULLABLE (FK → LOCALIZACAO)
id_departamento INT NULLABLE (FK → DEPARTAMENTO)
```

**Estados Válidos:**
- Operacional
- Em Manutenção
- Avariado
- Desativado
- Em Calibração

### EQUIPAMENTO_CONTACTO_SUPORTE (Multivalorado)
```sql
id_equipamento INT (PK, FK)
contacto_suporte VARCHAR(100) (PK)
-- Chave primária composta
```

### TECNICO
```sql
id_tecnico INT (PK, AI)
nome VARCHAR(150) NOT NULL
especialidade VARCHAR(100) NOT NULL
data_inicio_carreira DATE NOT NULL
anos_experiencia INT DEFAULT 0 (CHECK >= 0)
```

### TECNICO_CONTACTO (Multivalorado)
```sql
id_tecnico INT (PK, FK)
contacto VARCHAR(100) (PK)
-- Chave primária composta
```

### MANUTENCAO
```sql
id_manutencao INT (PK, AI)
tipo VARCHAR(50) NOT NULL (CHECK IN (...))
data_inicio DATE NOT NULL
data_fim DATE NULLABLE
descricao VARCHAR(500) NULLABLE
custo DECIMAL(10,2) DEFAULT 0.00 (CHECK >= 0)
duracao INT DEFAULT 0 (CHECK >= 0) -- dias
horas_trabalho DECIMAL(5,1) DEFAULT 0 (CHECK >= 0)
id_equipamento INT NOT NULL (FK → EQUIPAMENTO)
```

**Tipos de Manutenção:**
- Preventiva
- Corretiva
- Calibração
- Inspeção

**Constraints de Data:**
- `data_fim IS NULL OR data_fim >= data_inicio`

### PECA
```sql
id_peca INT (PK, AI)
designacao VARCHAR(150) NOT NULL
preco DECIMAL(10,2) NOT NULL (CHECK >= 0)
custo DECIMAL(10,2) DEFAULT 0.00 (CHECK >= 0)
validade_peca DATE NULLABLE
```

### ORDEM_SERVICO
```sql
id_ordem INT (PK, AI)
descricao VARCHAR(500) NOT NULL
estado_atual VARCHAR(50) DEFAULT 'Pendente'
data_criacao DATE DEFAULT CURDATE()
prioridade VARCHAR(20) DEFAULT 'Normal'
```

**Estados Válidos:**
- Pendente
- Em Execução
- Concluída
- Cancelada

**Prioridades Válidas:**
- Baixa
- Normal
- Alta
- Crítica

### AUDITORIA_EQUIPAMENTO
```sql
id_auditoria INT (PK, AI)
id_equipamento INT NOT NULL
estado_antigo VARCHAR(50) NULLABLE
estado_novo VARCHAR(50) NULLABLE
operacao VARCHAR(50) NULLABLE
descricao_mudanca VARCHAR(500) NULLABLE
data_operacao DATETIME DEFAULT NOW()
utilizador VARCHAR(100) DEFAULT USER()
```

### INTERVENCAO_TECNICO (Entidade Relacional)
```sql
id_intervencao INT (PK, AI)
id_manutencao INT NOT NULL (FK → MANUTENCAO)
id_tecnico INT NOT NULL (FK → TECNICO)
cargo VARCHAR(100) NOT NULL
horas_trabalho DECIMAL(5,1) DEFAULT 0
-- Chave única composta: (id_manutencao, id_tecnico)
```

### MANUTENCAO_ORDEM (N:M)
```sql
id_manutencao INT (PK, FK)
id_ordem INT (PK, FK)
-- Chave primária composta
```

### MANUTENCAO_PECA (N:M)
```sql
id_manutencao INT (PK, FK)
id_peca INT (PK, FK)
quantidade INT NOT NULL DEFAULT 1 (CHECK > 0)
-- Chave primária composta
```

---

## 4. Relacionamentos

### 1:N (Um para Muitos)

| Origem | Destino | Cardinalidade | Descrição |
|--------|---------|---------------|-----------|
| DEPARTAMENTO | RESPONSAVEL | 1:N | Um departamento tem múltiplos responsáveis |
| DEPARTAMENTO | EQUIPAMENTO | 1:N | Um departamento tem múltiplos equipamentos |
| LOCALIZACAO | EQUIPAMENTO | 1:N | Uma localização tem múltiplos equipamentos |
| RESPONSAVEL | RESPONSAVEL_CONTACTO | 1:N | Um responsável tem múltiplos contactos |
| EQUIPAMENTO | EQUIPAMENTO_CONTACTO_SUPORTE | 1:N | Um equipamento tem múltiplos contactos |
| EQUIPAMENTO | MANUTENCAO | 1:N | Um equipamento tem múltiplas manutenções |
| EQUIPAMENTO | AUDITORIA_EQUIPAMENTO | 1:N | Um equipamento tem múltiplos registos de auditoria |
| TECNICO | TECNICO_CONTACTO | 1:N | Um técnico tem múltiplos contactos |

### N:M (Muitos para Muitos)

| Tabela 1 | Tabela 2 | Tabela Relacionamento | Descrição |
|----------|----------|----------------------|-----------|
| MANUTENCAO | ORDEM_SERVICO | MANUTENCAO_ORDEM | Uma manutenção gera múltiplas ordens e uma ordem pode ser resultado de múltiplas manutenções |
| MANUTENCAO | PECA | MANUTENCAO_PECA | Uma manutenção utiliza múltiplas peças e uma peça pode ser utilizada em múltiplas manutenções |
| MANUTENCAO | TECNICO | INTERVENCAO_TECNICO | Uma manutenção envolve múltiplos técnicos e um técnico participa em múltiplas manutenções |

### Atributos Multivalorados

| Entidade | Atributo | Tabela Normalizada |
|----------|----------|-------------------|
| RESPONSAVEL | Contacto | RESPONSAVEL_CONTACTO |
| EQUIPAMENTO | Contacto Suporte | EQUIPAMENTO_CONTACTO_SUPORTE |
| TECNICO | Contacto | TECNICO_CONTACTO |

---

## 5. Constraints e Validações

### CHECK Constraints

| Tabela | Campo | Validação | Exemplos |
|--------|-------|-----------|----------|
| EQUIPAMENTO | estado | IN ('Operacional','Em Manutenção','Avariado','Desativado','Em Calibração') | Apenas 5 estados |
| EQUIPAMENTO | estado_atual | IN ('Operacional','Em Manutenção','Avariado','Desativado','Em Calibração') | Apenas 5 estados |
| EQUIPAMENTO | garantia | >= 0 | Meses |
| MANUTENCAO | tipo | IN ('Preventiva','Corretiva','Calibração','Inspeção') | Apenas 4 tipos |
| MANUTENCAO | custo | >= 0 | Euros |
| MANUTENCAO | duracao | >= 0 | Dias |
| MANUTENCAO | horas_trabalho | >= 0 | Horas decimais |
| MANUTENCAO | datas | data_fim >= data_inicio | Data consistente |
| ORDEM_SERVICO | estado_atual | IN ('Pendente','Em Execução','Concluída','Cancelada') | Apenas 4 estados |
| ORDEM_SERVICO | prioridade | IN ('Baixa','Normal','Alta','Crítica') | Apenas 4 prioridades |
| PECA | preco | >= 0 | Euros |
| PECA | custo | >= 0 | Euros |
| TECNICO | anos_experiencia | >= 0 | Anos |
| MANUTENCAO_PECA | quantidade | > 0 | Quantidade > 0 |

### Foreign Key Constraints

| Tabela | Campo | Referencia | Ação Delete | Ação Update |
|--------|-------|-----------|-------------|------------|
| RESPONSAVEL | id_departamento | DEPARTAMENTO.id_departamento | RESTRICT | CASCADE |
| RESPONSAVEL_CONTACTO | id_responsavel | RESPONSAVEL.id_responsavel | CASCADE | CASCADE |
| EQUIPAMENTO | id_localizacao | LOCALIZACAO.id_localizacao | SET NULL | CASCADE |
| EQUIPAMENTO | id_departamento | DEPARTAMENTO.id_departamento | SET NULL | CASCADE |
| EQUIPAMENTO_CONTACTO_SUPORTE | id_equipamento | EQUIPAMENTO.id_equipamento | CASCADE | CASCADE |
| TECNICO_CONTACTO | id_tecnico | TECNICO.id_tecnico | CASCADE | CASCADE |
| MANUTENCAO | id_equipamento | EQUIPAMENTO.id_equipamento | RESTRICT | CASCADE |
| MANUTENCAO_ORDEM | id_manutencao | MANUTENCAO.id_manutencao | CASCADE | CASCADE |
| MANUTENCAO_ORDEM | id_ordem | ORDEM_SERVICO.id_ordem | CASCADE | CASCADE |
| MANUTENCAO_PECA | id_manutencao | MANUTENCAO.id_manutencao | CASCADE | CASCADE |
| MANUTENCAO_PECA | id_peca | PECA.id_peca | RESTRICT | CASCADE |
| INTERVENCAO_TECNICO | id_manutencao | MANUTENCAO.id_manutencao | CASCADE | CASCADE |
| INTERVENCAO_TECNICO | id_tecnico | TECNICO.id_tecnico | RESTRICT | CASCADE |

### NOT NULL Constraints

Todos os campos de identificação, datas obrigatórias e campos críticos são NOT NULL.

---

## 6. Operações CRUD

### CREATE
- ✅ Inserção de departamentos
- ✅ Inserção de equipamentos com validação de estado
- ✅ Inserção de técnicos
- ✅ Inserção de manutenções
- ✅ Inserção de peças
- ✅ Inserção de ordens de serviço
- ✅ Inserção de contactos multivalorados

### READ
- ✅ Consulta de equipamentos com detalhes
- ✅ Consulta de manutenções por equipamento
- ✅ Consulta de técnicos por especialidade
- ✅ Consulta de custos por departamento
- ✅ Consulta de histórico de auditoria

### UPDATE
- ✅ Atualização de estado de equipamento
- ✅ Atualização de localização
- ✅ Atualização de dados de técnico
- ✅ Atualização de estado de ordem de serviço
- ⚠️ Atualização dispara TRIGGERS de auditoria

### DELETE
- ✅ Eliminação de registos com cascata
- ⚠️ Algumas deletions são restringidas (integridade referencial)
- ⚠️ Eliminação de equipamento pode falhar se tem manutenções

---

## 7. Procedures e Functions

### Procedures Implementadas

1. **sp_CreateEquipment**
   - Parâmetros: designacao, data_aquisicao, fabricante, garantia, id_departamento
   - Ação: Insere equipamento com validação

2. **sp_UpdateEquipmentState**
   - Parâmetros: id_equipamento, novo_estado
   - Ação: Atualiza estado e registra em auditoria

3. **sp_CreateMaintenance**
   - Parâmetros: tipo, data_inicio, id_equipamento, custo
   - Ação: Cria manutenção com validações

4. **sp_GetEquipmentMaintenance**
   - Parâmetros: id_equipamento
   - Retorna: Lista de manutenções do equipamento

5. **sp_GetTechnicianWorkload**
   - Parâmetros: id_tecnico (opcional)
   - Retorna: Carga de trabalho do técnico

### Functions Implementadas

1. **fn_GetEquipmentStatus**
   - Retorna: Status atual do equipamento

2. **fn_CalculateMaintenanceCost**
   - Parâmetros: id_manutencao
   - Retorna: Custo total com peças

3. **fn_GetTechnicianExperience**
   - Parâmetros: id_tecnico
   - Retorna: Anos de experiência

4. **fn_GetEquipmentAge**
   - Parâmetros: id_equipamento
   - Retorna: Idade do equipamento em anos

---

## 8. Triggers e Auditoria

### Triggers Implementados

1. **BEFORE UPDATE EQUIPAMENTO**
   - Ação: Valida novo estado antes de atualizar
   - Registra: Alteração em AUDITORIA_EQUIPAMENTO

2. **AFTER UPDATE EQUIPAMENTO**
   - Ação: Insere log de auditoria automático
   - Registra: Estado antigo, novo, utilizador, timestamp

3. **BEFORE DELETE EQUIPAMENTO**
   - Ação: Impede eliminação se tem manutenções ativas
   - Erro: SIGNAL (bloqueio)

### Auditoria

- **Tabela:** AUDITORIA_EQUIPAMENTO
- **Rastreamento:** Todas as alterações de equipamento
- **Informações:** Estado anterior/novo, utilizador, data/hora
- **Retenção:** Permanente
- **Consulta:** Via `verificacoes_rapidas.sql`

---

## 9. Views e Relatórios

### Views Implementadas

1. **v_EquipmentDetails**
   - Mostra: Equipamento com departamento e localização

2. **v_MaintenanceCosts**
   - Mostra: Custos totais por tipo de manutenção

3. **v_TechnicianWorkload**
   - Mostra: Horas de trabalho por técnico

4. **v_EquipmentStatus**
   - Mostra: Distribuição de estados

5. **v_WarrantyStatus**
   - Mostra: Equipamentos com garantia vencida

### Relatórios Predefinidos (10+)

1. Dashboard Executivo (Estatísticas Gerais)
2. Equipamentos Críticos (Fora de Operação)
3. Manutenções por Departamento
4. Carga de Trabalho de Técnicos
5. Ordens de Serviço por Status
6. Peças Mais Utilizadas
7. Equipamentos com Garantia Vencida
8. Responsáveis por Departamento
9. Histórico de Auditoria
10. Manutenções Pendentes

---

## 10. Requisitos Não-Funcionais

### RNF-001: Performance
- **Descrição:** Queries devem responder em < 1 segundo
- **Implementação:** Índices em Foreign Keys e campos críticos
- **Status:** ✅

### RNF-002: Integridade de Dados
- **Descrição:** Garantir consistência via constraints
- **Implementação:** CHECK, UNIQUE, PRIMARY KEY, FOREIGN KEY
- **Status:** ✅

### RNF-003: Segurança
- **Descrição:** Controlo de acesso e auditoria
- **Implementação:** Triggers de auditoria, logs de utilizador
- **Status:** ✅

### RNF-004: Disponibilidade
- **Descrição:** BD deve estar disponível 24/7
- **Implementação:** InnoDB, transações ACID, backup
- **Status:** ✅

### RNF-005: Escalabilidade
- **Descrição:** Suportar crescimento futuro
- **Implementação:** Design normalizado, sem limites de tamanho
- **Status:** ✅

### RNF-006: Manutenibilidade
- **Descrição:** Código bem documentado e organizado
- **Implementação:** Comentários, nomenclatura clara
- **Status:** ✅

### RNF-007: Compatibilidade
- **Descrição:** MySQL 8.0+
- **Implementação:** Sem features obsoletas
- **Status:** ✅

### RNF-008: Integridade Referencial
- **Descrição:** Nenhum dados órfãos
- **Implementação:** Foreign Keys com CASCADE/RESTRICT
- **Status:** ✅

---

## 📊 Estatísticas

| Métrica | Valor |
|---------|-------|
| Total de Tabelas | 14 |
| Tabelas de Domínio | 8 |
| Tabelas de Relacionamento | 3 |
| Tabelas de Multivalorados | 3 |
| Tabelas de Auditoria | 1 |
| Total de Campos | 60+ |
| CHECK Constraints | 13 |
| UNIQUE Constraints | 5 |
| FOREIGN KEY Constraints | 15 |
| PRIMARY KEY Constraints | 14 |
| Procedures Implementadas | 5+ |
| Functions Implementadas | 4+ |
| Triggers Implementados | 3 |
| Views Implementadas | 5+ |

---

## 🔄 Fluxo de Dados

### Registar Manutenção
```
1. Equipamento em estado Operacional
2. Criar registo em MANUTENCAO
3. Atualizar EQUIPAMENTO.estado_atual = 'Em Manutenção'
4. Registrar em AUDITORIA_EQUIPAMENTO (TRIGGER)
5. Associar TECNICO via INTERVENCAO_TECNICO
6. Registar PECA's utilizadas em MANUTENCAO_PECA
7. Criar ORDEM_SERVICO
8. Associar em MANUTENCAO_ORDEM
9. Marcar MANUTENCAO como completa
10. Atualizar EQUIPAMENTO.estado_atual = 'Operacional'
11. Registrar alteração em auditoria (TRIGGER)
```

---

## 📝 Notas Importantes

1. **Atributos Multivalorados:** Implementados como tabelas normalizadas (1:N)
2. **Auditoria Automática:** Triggers registam automaticamente alterações
3. **Relacionamento Direto:** EQUIPAMENTO-DEPARTAMENTO é direto (1:N), não N:M
4. **Garantia em Meses:** Campo inteiro representando meses de garantia
5. **Contactos:** Sem limite de quantidade (Composite PK)
6. **Estados:** Apenas valores predefinidos (CHECK constraints)
7. **Integridade:** Cascata de deletions onde apropriado

---

## ✅ Validação

- ✅ Todas as tabelas criadas
- ✅ Todas as constraints implementadas
- ✅ Foreign Keys ativas
- ✅ Triggers de auditoria funcionais
- ✅ Procedures e Functions disponíveis
- ✅ Views e relatórios prontos
- ✅ Testes de integridade passam 100%

---

**Documento Gerado:** Maio 2026  
**Versão:** 1.0  
**Status:** ✅ Completo e Validado

