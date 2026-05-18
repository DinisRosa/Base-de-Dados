# Sistema de Gestão de Equipamentos Médicos (SQL)

Projeto académico em **MySQL 8+** para modelar e gerir o ciclo completo de equipamentos médicos hospitalares, incluindo manutenção preventiva/corretiva, gestão de técnicos, responsáveis e peças de reposição.

---

## 🎯 Funcionalidades Principais

- ✅ Schema moderno com nomes uniformizados (`snake_case`)
- ✅ 12 Stored Procedures para gestão operacional
- ✅ Validações de integridade e transações ACID
- ✅ Testes funcionais automatizados
- ✅ Setup completo via script shell
- ✅ Queries de sanidade para auditoria de dados

---

## 📁 Estrutura do Projeto

```
PORJETO DE BASE DE DADOS/
├── README.md                          # Esta documentação
├── setup.sh                           # Script de setup completo (recomendado)
├── drop.sql                           # Remove bases de dados existentes
├── modelo_fisico_uniforme.sql         # Schema mydb_uniforme (PADRÃO OFICIAL)
├── povoamento_uniforme.sql            # Dados de exemplo
├── queries_sanidade_1.sql             # Contagens e integridade referencial
├── queries_sanidade_2.sql             # Testes funcionais de procedures
├── procedures/
│   ├── registar_avaria.sql            # Abre avaria (manutencao + ordem + estado)
│   ├── concluir_manutencao.sql        # Fecha ciclo de manutencao
│   ├── adicionar_intervencao_tecnico.sql
│   ├── abater_equipamento.sql         # Marca como inativo, cancela ordens
│   ├── alterar_prioridade_ordem.sql
│   ├── abrir_manutencao.sql           # Alternativa a registar_avaria
│   ├── listar_alertas.sql             # Alertas operacionais
│   ├── validar_estado_ordem.sql       # Transicoes de estado
│   ├── adicionar_responsavel.sql      # Cria responsavel + contacto
│   ├── adicionar_tecnico.sql          # Cria tecnico + contacto
│   ├── adicionar_peca.sql
│   ├── abater_pecas.sql               # Remove pecas expiradas sem uso
│   └── procedures.txt                 # Catalogo funcional (referencia)
├── functions/
│   └── functions.txt                  # Catalogo de funcoes (referencia)
├── modelo_fisico.sql                  # Schema mydb (original, DESCONTINUADO)
├── povoamento.sql                     # Dados para mydb (DESCONTINUADO)
└── crud.sql                           # Procedures CRUD mydb (DESCONTINUADO)
```

---

## ⚡ Quick Start

### Opção 1: Setup Automático (Recomendado)

```bash
cd ~/Secretária/PORJETO\ DE\ BASE\ DE\ DADOS
./setup.sh dinisrosa minha_senha
```

Isto executa sequencialmente:
1. `drop.sql` — Remove bases existentes
2. `modelo_fisico_uniforme.sql` — Cria schema
3. `povoamento_uniforme.sql` — Insere dados
4. Todas as 12 procedures
5. `queries_sanidade_2.sql` — Testes

### Opção 2: Manual (Passo a Passo)

```bash
mysql -u dinisrosa -p < modelo_fisico_uniforme.sql
mysql -u dinisrosa -p < povoamento_uniforme.sql
mysql -u dinisrosa -p < procedures/registar_avaria.sql
# ... etc para cada procedure
mysql -u dinisrosa -p < queries_sanidade_2.sql
```

---

## 📋 Procedures Disponíveis

### Ciclo de Manutenção

| Procedure | Descrição |
|-----------|-----------|
| `registar_avaria(equipamento_id, peca_id, tipo, custo, descricao, prioridade)` | Abre manutencao + ordem + marca equipamento em manutencao |
| `concluir_manutencao(manutencao_id)` | Fecha manutencao + ordem + volta equipamento a operacional |
| `abrir_manutencao(...)` | Alternativa simplificada a `registar_avaria` |

### Gestão de Técnicos e Responsáveis

| Procedure | Descrição |
|-----------|-----------|
| `adicionar_tecnico(carreira_inicio, nome, especialidade, telefone, email)` | Cria tecnico + contacto numa transacao |
| `adicionar_responsavel(nome, data_nascimento, ordem_id, telefone, email)` | Cria responsavel + contacto |
| `adicionar_intervencao_tecnico(tecnico_id, manutencao_id, cargo, horas, mudar_ordem)` | Associa tecnico a manutencao |

### Gestão de Recursos e Ordens

| Procedure | Descrição |
|-----------|-----------|
| `adicionar_peca(preco, designacao, garantia)` | Regista peca nova no catalogo |
| `abater_pecas()` | Remove pecas com garantia expirada (sem uso) |
| `abater_equipamento(equipamento_id)` | Marca equipamento inativo, cancela ordens abertas |
| `alterar_prioridade_ordem(ordem_id, prioridade)` | Valida prioridade (Baixa/Media/Alta) |
| `validar_estado_ordem(ordem_id, novo_estado)` | Valida transicoes de estado (Pendente → Em Execucao → Concluida) |
| `listar_alertas(dias_manutencao, dias_ordem)` | Lista alertas operacionais (3 result sets) |

---

## 🧪 Testes

### Queries de Sanidade 1 (Integridade)

```bash
mysql -u dinisrosa -p < queries_sanidade_1.sql
```

Valida:
- Contagens por tabela
- Orfaos (registos órfãos sem FK associada)
- JOINs de inspeção rápida

### Queries de Sanidade 2 (Procedures)

```bash
mysql -u dinisrosa -p < queries_sanidade_2.sql
```

Executa todos os 12 procedures e valida resultados com `SELECT`s de confirmação.

---

## 💡 Exemplos de Uso

### Exemplo 1: Registar uma Avaria

```sql
USE `mydb_uniforme`;

-- Equipamento 2 apresenta problema no componente (peca 2)
CALL `registar_avaria`(
  2,                                    -- equipamento_id
  2,                                    -- peca_id
  'Corretiva',                          -- tipo
  150.00,                               -- custo_estimado
  'Componente defeituoso detectado',    -- descricao
  'Alta'                                -- prioridade
);

-- Verificar estado do equipamento
SELECT id, nome, estado FROM `equipamento` WHERE id = 2;
-- resultado: estado = 'Em Manutencao'

-- Verificar ordem criada
SELECT id, estado_atual, prioridade FROM `ordem_servico` WHERE manutencao_id = 4;
```

### Exemplo 2: Adicionar Técnico e Registar Intervenção

```sql
-- Criar novo tecnico
CALL `adicionar_tecnico`(
  '2020-06-01',
  'João Silva',
  'Equipamentos Cardiacos',
  '919999999',
  'joao.silva@empresa.pt'
);
-- Retorna: tecnico_id = 4

-- Associar a uma manutencao
CALL `adicionar_intervencao_tecnico`(
  4,                    -- tecnico_id
  1,                    -- manutencao_id
  'Tecnico Responsavel',
  4,                    -- horas_trabalho
  1                     -- mudar_ordem_execucao (1 = sim)
);

-- Verificar ordem mudou para "Em Execucao"
SELECT estado_atual FROM `ordem_servico` WHERE id = 1;
```

### Exemplo 3: Concluir Manutenção

```sql
-- Depois de terminar a manutencao
CALL `concluir_manutencao`(1);

-- Verificar: manutencao tem data_fim, ordem e concluida, equipamento voltou a operacional
SELECT id, data_fim FROM `manutencao` WHERE id = 1;
SELECT id, estado_atual FROM `ordem_servico` WHERE manutencao_id = 1;
SELECT id, estado FROM `equipamento` WHERE id = 1;
```

### Exemplo 4: Listar Alertas Operacionais

```sql
-- Manutencoes abertas ha mais de 7 dias
-- Ordens pendentes ha mais de 3 dias
-- Equipamentos nao operacionais
CALL `listar_alertas`(7, 3);
-- Retorna 3 result sets com alertas
```

---

## ⚠️ Notas Importantes

### Schema Oficial

**O esquema `mydb_uniforme` é o padrão obrigatório** para este projeto. Todo o desenvolvimento futuro deve ser feito nesta base de dados. Os ficheiros do `mydb` original são apenas histórico de transição e estão **descontinuados**.

### Validações e Transações

Todas as procedures:
- ✅ Validam entradas (FK, ranges, enums)
- ✅ Usam transações (`START TRANSACTION ... COMMIT/ROLLBACK`)
- ✅ Retornam mensagens de sucesso/erro
- ✅ Têm `EXIT HANDLER` para rollback automático em erros

### Integridade Referencial

As FKs são configuradas com `ON DELETE NO ACTION / ON UPDATE NO ACTION`, isto é:
- Não é possível apagar um `responsavel` se tem um `departamento` ligado
- Não é possível apagar um `equipamento` se tem `manutencao` ligada
- Use `abater_equipamento()` para desativar sem violar constraints

---

## 🔧 Troubleshooting

### Error: "Failed to open file 'registar_avaria.sql', error: 2"

**Causa**: Paths relativos em `SOURCE` não funcionam quando corres de diretório diferente.

**Solução**: Sempre corre `setup.sh` da raiz do projeto, ou especifica caminhos absolutos.

### Error: "Equipamento inexistente" ao chamar `registar_avaria`

**Causa**: ID de equipamento não existe.

**Solução**: Verifica IDs disponíveis:
```sql
SELECT id, nome FROM `equipamento`;
```

### Error: "Manutencao ja concluida"

**Causa**: Tentaste concluir uma manutenção que já tem `data_fim` preenchida.

**Solução**: Verifica se já foi concluída:
```sql
SELECT id, data_fim FROM `manutencao` WHERE id = X;
```

---

## 📊 Schema (Visão Geral)

```
peca
├── manutencao
│   ├── ordem_servico
│   │   └── responsavel
│   │       └── contacto_responsavel
│   └── intervencao_tecnico
│       └── tecnico
│           └── contacto_tecnico
└── equipamento
    ├── departamento
    │   └── responsavel (FK alternativa)
    └── localizacao
        ├── contacto_equipamento
        └── departamento
```

---

## 📝 Referências

- `functions/functions.txt` — Catálogo de funções planeadas
- `procedures/procedures.txt` — Catálogo de procedures planeadas
- MySQL Docs: https://dev.mysql.com/doc/
- Transações ACID: https://pt.wikipedia.org/wiki/ACID

---

## 👤 Autor

Projeto académico — Sistema de Gestão de Equipamentos Médicos
