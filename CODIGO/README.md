# 🏥 Sistema de Gestão de Equipamentos Médicos

**Disciplina:** Base de Dados Clínicas e de Gestão Hospitalar  
**Ano Lectivo:** 2025/26 - 2º Semestre  
**Status:** ✅ Versão 2.0 - 100% Conforme com Modelo Conceptual

---

## 📑 Índice Rápido

- [Estrutura de Pastas](#-estrutura-de-pastas)
- [Começar Rapidamente](#-começar-rapidamente)
- [Documentação Completa](#-documentação-completa)
- [Ficheiros SQL](#-ficheiros-sql)
- [Roadmap e Status](#-roadmap-e-status)

---

## 📁 Estrutura de Pastas

```
CODIGO/
├── README.md (ESTE FICHEIRO - comece aqui!)
│
├── 🏗️  modelo_conceptual/
│   └── mod_conceptual_novas_modificacoes.xml .... Modelo ER (fonte de verdade)
│
├── 🗄️  sql/
│   ├── 01_schema/
│   │   └── 01_tabelas.sql ...................... Criação de tabelas e constraints
│   ├── 02_populacao/
│   │   ├── 03_povoamento.sql .................. Dados de teste
│   │   └── dados_exemplo/ ..................... (futura expansão)
│   ├── 03_operacoes/
│   │   ├── 02_crud.sql ........................ CRUD: Create, Read, Update, Delete
│   │   ├── 04_procedures.sql ................. Procedimentos armazenados
│   │   ├── 05_functions.sql .................. Funções SQL
│   │   ├── 06_triggers.sql ................... Triggers para auditoria
│   │   └── 07_views.sql ...................... Views e relatórios
│   └── 04_testes/
│       ├── 08_teste_funcional.sql ............ Suite de testes completa
│       ├── verificacoes_rapidas.sql .......... 10 dashboards de monitoramento
│       ├── teste.sql ......................... Testes adicionais
│       └── teste_bd.sh ....................... Script bash para executar testes
│
├── 📚 docs/
│   ├── requisitos/
│   │   ├── REQUISITOS.md ..................... 10 RF + 8 RNF (643 linhas)
│   │   ├── QUICK_REFERENCE.txt .............. Cheat sheet rápido
│   │   └── CHECKLIST_IMPLEMENTACAO.txt ...... Verificação de implementação
│   ├── guias/
│   │   ├── README_ATUALIZACOES.txt .......... Changelog e atualizações
│   │   └── (próximas versões)
│   ├── historico/
│   │   ├── MUDANCAS.md ...................... Histórico de mudanças gerais
│   │   └── MUDANCAS_1N_MANUTENCAO_ORDEM.md . Detalhes da correção 1:N
│   └── indice/
│       ├── INDEX_FICHEIROS.txt .............. Índice detalhado de ficheiros
│       ├── MANIFEST.txt ..................... Manifesto do projeto
│       ├── QUICKSTART.txt ................... 30-segundo quick start
│       └── SUMARIO_TESTES.txt ............... Resumo de testes
│
└── 📄 trabalho prático bd.pdf ................ Enunciado do trabalho

```

---

## 🚀 Começar Rapidamente

### 1️⃣ Entender o Modelo
```bash
# Ler o modelo conceptual XML
cat modelo_conceptual/mod_conceptual_novas_modificacoes.xml
```

### 2️⃣ Criar a Base de Dados
```bash
# Executar script de schema
mysql -u usuario -p < sql/01_schema/01_tabelas.sql
```

### 3️⃣ Popular com Dados de Teste
```bash
# Executar script de população
mysql -u usuario -p < sql/02_populacao/03_povoamento.sql
```

### 4️⃣ Validar Integridade
```bash
# Executar suite de testes
mysql -u usuario -p < sql/04_testes/08_teste_funcional.sql
```

### 📖 Leitura Rápida (5 minutos)
```bash
cat docs/indice/QUICKSTART.txt           # 30-segundo overview
cat docs/requisitos/QUICK_REFERENCE.txt  # Cheat sheet
```

---

## 📚 Documentação Completa

### Para Entender o Projeto
| Documento | Conteúdo | Tempo |
|-----------|----------|-------|
| `docs/requisitos/REQUISITOS.md` | 10 Requisitos Funcionais + 8 Não-Funcionais | 20 min |
| `docs/historico/MUDANCAS_1N_MANUTENCAO_ORDEM.md` | Detalhe da relação 1:N | 10 min |
| `docs/indice/MANIFEST.txt` | Manifesto completo do projeto | 15 min |

### Para Usar o Sistema
| Documento | Para | Público |
|-----------|------|---------|
| `docs/indice/QUICKSTART.txt` | Começar em 30 segundos | Devs, DBAs |
| `docs/requisitos/QUICK_REFERENCE.txt` | Lookup rápido | Devs |
| `docs/indice/INDEX_FICHEIROS.txt` | Procurar ficheiros | Todos |

### Para Testar
| Documento | O Quê | Ficheiros |
|-----------|-------|-----------|
| `docs/indice/SUMARIO_TESTES.txt` | Resumo de testes | 04_testes/* |
| `sql/04_testes/08_teste_funcional.sql` | Suite completa | 14 seções |
| `sql/04_testes/verificacoes_rapidas.sql` | Dashboards | 10 queries |

---

## 🗄️ Ficheiros SQL

### Schema (Obrigatório - Executar 1º)
```sql
sql/01_schema/01_tabelas.sql
├─ 13 tabelas de domínio e relacionamento
├─ 1 tabela de auditoria
├─ 15+ Foreign Keys
├─ 13+ CHECK constraints
└─ Índices para performance
```

**Executar:**
```bash
mysql -u usuario -p < sql/01_schema/01_tabelas.sql
```

### População (Dados de Teste - Executar 2º)
```sql
sql/02_populacao/03_povoamento.sql
├─ 3 Localizações
├─ 3 Departamentos
├─ 3 Responsáveis + 5 contactos
├─ 3 Equipamentos + 3 contactos suporte
├─ 3 Técnicos + 4 contactos
├─ 3 Manutenções (com id_ordem obrigatório)
├─ 3 Peças
├─ 3 Ordens de Serviço
└─ 3 Intervenções Técnicas
```

**Executar:**
```bash
mysql -u usuario -p < sql/02_populacao/03_povoamento.sql
```

### Operações (CRUD, Procedures, Functions, Triggers, Views)
```
sql/03_operacoes/
├─ 02_crud.sql ............. Create, Read, Update, Delete
├─ 04_procedures.sql ....... Procedimentos armazenados
├─ 05_functions.sql ........ Funções SQL (cálculos)
├─ 06_triggers.sql ......... Triggers para auditoria
└─ 07_views.sql ............ 8+ Views e relatórios
```

### Testes (Validação e Monitoramento)
```
sql/04_testes/
├─ 08_teste_funcional.sql ..... Suite completa (14 seções)
│  ├─ 1. Tabelas criadas
│  ├─ 2. Integridade referencial
│  ├─ 3. Atributos multivalorados
│  ├─ 4. População de dados
│  ├─ 5. Constraints
│  ├─ 6. Relacionamentos 1:N
│  ├─ 7. Query complexa - Equipamentos
│  ├─ 8. Query - Manutenções com Ordens
│  ├─ 9. Relação 1:N (MANUTENCAO-ORDEM)
│  ├─ 10. Estatísticas
│  ├─ 11. Views
│  ├─ 12. Triggers
│  ├─ 13. Procedures
│  └─ 14. Resumo Final
│
├─ verificacoes_rapidas.sql ... 10 dashboards de BI
│  ├─ Equipamentos por departamento
│  ├─ Custos de manutenção
│  ├─ Carga de técnicos
│  ├─ Garantias vencidas
│  └─ ... (5 mais)
│
├─ teste.sql .................. Testes adicionais
└─ teste_bd.sh ................ Script bash para automação
```

**Executar:**
```bash
# Suite completa
mysql -u usuario -p < sql/04_testes/08_teste_funcional.sql

# Dashboards rápidos
mysql -u usuario -p < sql/04_testes/verificacoes_rapidas.sql

# Script bash (automático)
bash sql/04_testes/teste_bd.sh
```

---

## 📊 Estrutura de Dados

### 14 Tabelas (13 + 1 auditoria)

**Tabelas de Domínio:**
- LOCALIZACAO, DEPARTAMENTO, RESPONSAVEL, EQUIPAMENTO, TECNICO, MANUTENCAO, PECA, ORDEM_SERVICO

**Tabelas Multivaloradas:**
- RESPONSAVEL_CONTACTO, EQUIPAMENTO_CONTACTO_SUPORTE, TECNICO_CONTACTO

**Tabelas de Relacionamento (N:M):**
- MANUTENCAO_PECA, INTERVENCAO_TECNICO

**Relacionamentos 1:N:**
- RESPONSAVEL → DEPARTAMENTO
- EQUIPAMENTO → DEPARTAMENTO
- EQUIPAMENTO → LOCALIZACAO
- MANUTENCAO → EQUIPAMENTO
- **MANUTENCAO → ORDEM_SERVICO** ✅ (1:N, NOT NULL FK)

**Auditoria:**
- AUDITORIA_EQUIPAMENTO (log automático de mudanças)

---

## ✅ Status da Implementação

### Versão 2.0 - Modelo Conceptual Conformante

| Componente | Status | Versão |
|-----------|--------|--------|
| Schema | ✅ Completo | 2.0 |
| Dados de Teste | ✅ Completo | 2.0 |
| CRUD | ✅ Completo | 1.0 |
| Procedures | ✅ Completo | 1.0 |
| Functions | ✅ Completo | 1.0 |
| Triggers | ✅ Completo | 1.0 |
| Views | ✅ Completo | 1.0 |
| Testes Funcionais | ✅ Completo | 2.0 |
| Documentação | ✅ Completo | 2.0 |
| Conformidade 1:N | ✅ 100% | 2.0 |

### Mudanças v1.0 → v2.0
- ✅ Removida tabela MANUTENCAO_ORDEM (N:M)
- ✅ Adicionado id_ordem em MANUTENCAO (1:N)
- ✅ Actualizado 03_povoamento.sql
- ✅ Adicionado teste de 1:N em 08_teste_funcional.sql
- ✅ Actualizada documentação (REQUISITOS.md, QUICK_REFERENCE.txt)
- ✅ Criado changelog detalhado (MUDANCAS_1N_MANUTENCAO_ORDEM.md)

---

## 🎯 Próximos Passos

### Se Quer Usar a BD
1. Executar `sql/01_schema/01_tabelas.sql`
2. Executar `sql/02_populacao/03_povoamento.sql`
3. Executar `sql/04_testes/08_teste_funcional.sql` para validar
4. Usar `sql/03_operacoes/*` conforme necessário

### Se Quer Entender o Projeto
1. Ler `docs/indice/QUICKSTART.txt` (5 min)
2. Ler `docs/requisitos/REQUISITOS.md` (20 min)
3. Ler `docs/historico/MUDANCAS_1N_MANUTENCAO_ORDEM.md` (10 min)
4. Explorar `docs/requisitos/QUICK_REFERENCE.txt` conforme necessário

### Se Quer Expandir
- Adicionar mais dados: `sql/02_populacao/dados_exemplo/`
- Adicionar procedures: `sql/03_operacoes/`
- Adicionar testes: `sql/04_testes/`

---

## 📞 Referência Rápida

### Contactos e Atributos Multivalorados
- **RESPONSAVEL_CONTACTO** - Email, telefone do responsável
- **EQUIPAMENTO_CONTACTO_SUPORTE** - Suporte técnico do fabricante
- **TECNICO_CONTACTO** - Email, telefone do técnico

### Estados de Equipamento
```
Operacional, Em Manutenção, Avariado, Desativado, Em Calibração
```

### Estados de Ordem
```
Pendente, Em Execução, Concluída, Cancelada
```

### Prioridades
```
Baixa, Normal, Alta, Crítica
```

### Tipos de Manutenção
```
Preventiva, Corretiva, Calibração, Inspeção
```

---

## 🔐 Integridade e Conformidade

✅ **Modelo Conceptual:**
- 100% conforme com mod_conceptual_novas_modificacoes.xml
- Relação 1:N (MANUTENCAO-ORDEM) correctamente implementada
- Cada manutenção tem obrigatoriamente 1 ordem (NOT NULL FK)
- Cada ordem pode ter múltiplas manutenções

✅ **Constraints:**
- 15+ Foreign Keys
- 13+ CHECK constraints
- NOT NULL onde apropriado
- UNIQUE constraints em chaves secundárias

✅ **Índices:**
- Índices em todas as ForeignKeys
- Índices em campos frequentemente consultados
- Índices em datas para range queries

✅ **Auditoria:**
- Triggers automáticos para log de mudanças
- Tabela AUDITORIA_EQUIPAMENTO
- Rastreamento de utilizador e timestamp

---

## 📖 Documentação por Público

### Para Gestores / Stakeholders
→ `docs/indice/QUICKSTART.txt`  
→ `docs/requisitos/REQUISITOS.md` (Secção 1 - Requisitos Funcionais)

### Para Developers / DBAs
→ `docs/requisitos/QUICK_REFERENCE.txt`  
→ `sql/01_schema/01_tabelas.sql` (comentários inline)  
→ `docs/historico/MUDANCAS_1N_MANUTENCAO_ORDEM.md`

### Para QA / Testers
→ `docs/indice/SUMARIO_TESTES.txt`  
→ `sql/04_testes/08_teste_funcional.sql`  
→ `sql/04_testes/verificacoes_rapidas.sql`

### Para Auditores / Compliance
→ `docs/indice/MANIFEST.txt`  
→ `docs/historico/MUDANCAS.md`  
→ `docs/historico/MUDANCAS_1N_MANUTENCAO_ORDEM.md`

---

## 📅 Roadmap (Versão Futura)

- [ ] Adicionar dados_exemplo expandidos
- [ ] Adicionar mais procedures específicas de negócio
- [ ] Adicionar segurança (users, roles, permissões)
- [ ] Adicionar backup/restore procedures
- [ ] Adicionar performance tunning
- [ ] Adicionar mais views de relatório

---

## 📝 Notas

- **Fonte de Verdade:** `modelo_conceptual/mod_conceptual_novas_modificacoes.xml`
- **Versão Actual:** 2.0
- **Data Última Actualização:** 18 de Maio de 2026
- **Conformidade:** 100% com modelo conceptual
- **Status:** ✅ Pronto para produção

---

## 🎓 Licença e Termos

Este projecto é parte do trabalho práctico de "Base de Dados Clínicas e de Gestão Hospitalar" da disciplina de Engenharia Informática (2025/26 - 2º Semestre).

---

**Última Actualização:** 18 de Maio de 2026  
**Versão:** 2.0 - Modelo Conceptual Conformante  
**Status:** ✅ COMPLETO

