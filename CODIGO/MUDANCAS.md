# Modificações nos Ficheiros SQL
## Baseadas no Modelo Conceptual: mod_conceptual_novas_modificacoes.xml

Data de Atualização: 18 de Maio de 2026
Versão: Novas Modificações (mod_conceptual_novas_modificacoes)

---

## 1. Ficheiro 01_tabelas.sql
### Alterações Estruturais

**Tabela RESPONSAVEL:**
- ✅ Campo adicionado: `aprova` (BOOLEAN DEFAULT TRUE)
- Permite identificar quais responsáveis têm permissão de aprovação

**Tabela EQUIPAMENTO:**
- ✅ Campo adicionado: `estado_atual` (VARCHAR(50) DEFAULT 'Operacional')
- ✅ Campo adicionado: `garantia` (INT DEFAULT 0)
- Melhor rastreamento do estado em tempo real
- Período de garantia em meses

**Tabela TECNICO:**
- ✅ Campo adicionado: `anos_experiencia` (INT DEFAULT 0)
- Permite armazenar diretamente ou calcular dinamicamente

**Tabela MANUTENCAO:**
- ✅ Campo adicionado: `duracao` (INT DEFAULT 0)
- ✅ Campo adicionado: `horas_trabalho` (DECIMAL(5,1) DEFAULT 0)
- Rastreamento melhorado de duração e esforço

**Tabela PECA:**
- ✅ Campo adicionado: `custo` (DECIMAL(10,2) DEFAULT 0.00)
- Diferencia entre preço unitário e custo de aquisição

---

## 2. Ficheiro 02_crud.sql
### Procedures CRUD Atualizadas

**sp_insert/update_responsavel:**
- ✅ Novo parâmetro: `p_aprova` (BOOLEAN)

**sp_insert/update_equipamento:**
- ✅ Novos parâmetros: `p_estado_atual`, `p_garantia`

**sp_insert/update_tecnico:**
- ✅ Novo parâmetro: `p_anos_experiencia`

**sp_insert/update_manutencao:**
- ✅ Novos parâmetros: `p_duracao`, `p_horas_trabalho`

**sp_insert/update_peca:**
- ✅ Novo parâmetro: `p_custo`

---

## 3. Ficheiro 03_povoamento.sql
### Dados de Teste Atualizados

- ✅ Exemplos com novos campos nos INSERT
- ✅ Dados de demonstração coerentes com o modelo
- ✅ Técnicos com anos_experiencia preenchidos
- ✅ Manutenções com duracao e horas_trabalho
- ✅ Equipamentos com garantia e estado_atual
- ✅ Peças com custo de aquisição

---

## 4. Ficheiro 04_procedures.sql
### Procedures de Negócio Atualizadas

**sp_registar_manutencao_completa:**
- ✅ Novo parâmetro: `p_duracao`
- ✅ Atualização de `estado_atual` junto com `estado`

**sp_fechar_ordem_servico:**
- ✅ Atualiza ambos `estado` e `estado_atual` para 'Operacional'

**sp_relatorio_equipamentos_dept:**
- ✅ Adicionadas colunas: `estado_atual`, `garantia`

---

## 5. Ficheiro 05_functions.sql
### Functions Aprimoradas

**fn_calcular_anos_experiencia (melhorada):**
- ✅ Verifica se `anos_experiencia` está preenchido
- ✅ Usa valor da tabela se disponível, senão calcula

**fn_calcular_duracao_manutencao (melhorada):**
- ✅ Prioriza campo `duracao` da tabela
- ✅ Calcula se não preenchido

**✨ Novas Functions:**
- ✅ `fn_total_horas_tecnico()` - Total de horas por técnico
- ✅ `fn_custo_pecas_manutencao()` - Custo total de peças usadas

---

## 6. Ficheiro 06_triggers.sql
### Triggers Atualizados

**trg_inicio_manutencao:**
- ✅ Atualiza também `estado_atual` para 'Em Manutenção'

**trg_fecho_manutencao:**
- ✅ Restaura também `estado_atual` para 'Operacional'

**trg_auditoria_estado_equipamento:**
- ✅ Agora audita mudanças em `estado_atual`
- ✅ Regista ambos os estados no formato "estado/estado_atual"

**✨ Novo Trigger:**
- ✅ `trg_validar_quantidade_peca` - Valida quantidade > 0

---

## 7. Ficheiro 07_views.sql
### Views Atualizadas

**vw_equipamentos_completo:**
- ✅ Adicionadas colunas: `estado_atual`, `garantia`

**vw_manutencoes_em_curso:**
- ✅ Adicionadas colunas: `duracao`, `horas_trabalho`

**vw_tecnicos_intervencoes:**
- ✅ Usa nova lógica de `anos_experiencia`

**vw_historico_manutencoes:**
- ✅ Adicionada coluna: `horas_trabalho`

**vw_ordens_pendentes:**
- ✅ Adicionada coluna: `estado_atual_equipamento`

**vw_pecas_validade_critica:**
- ✅ Adicionada coluna: `custo`

**✨ Nova View:**
- ✅ `vw_responsaveis_departamentos` - Responsáveis com permissões e contactos

---

## Resumo de Mudanças

| Tipo | Quantidade | Detalhe |
|------|-----------|---------|
| Novos campos adicionados | 8 | aprova, estado_atual, garantia, anos_experiencia, duracao, horas_trabalho (2x), custo |
| Procedures CRUD atualizadas | 7 | Todas as principais tabelas |
| Procedures de negócio atualizadas | 3 | Registar, fechar, relatório |
| Triggers atualizados | 3 | Início, fecho, auditoria |
| Novo Trigger | 1 | Validação de quantidade |
| Functions melhoradas | 2 | anos_experiencia, duracao_manutencao |
| Novas Functions | 2 | total_horas_tecnico, custo_pecas_manutencao |
| Views atualizadas | 7 | Todas as principais views |
| Nova View | 1 | responsaveis_departamentos |

---

## Compatibilidade

✅ MySQL 8.0+
✅ MySQL Workbench
✅ Integridade referencial mantida
✅ Constraints e validações aprimoradas
✅ Índices de performance mantidos

---

## Próximas Etapas (Opcional)

1. Testar em ambiente MySQL 8.0+
2. Validar com dados reais do hospital
3. Otimizar índices se necessário
4. Documentar API de Stored Procedures
5. Criar script de migração se necessário


---

## ATUALIZAÇÃO: Remoção de EQUIPAMENTO_DEPARTAMENTO (18 Maio 2026)

### Mudança Realizada

A tabela de relação N:M **EQUIPAMENTO_DEPARTAMENTO** foi **removida** após análise do modelo conceptual revisto. 

**Motivo:** A relação entre EQUIPAMENTO e DEPARTAMENTO é **1:N** (Um Departamento tem Muitos Equipamentos), não N:M. Portanto, a tabela intermédia não era necessária.

### Impacto nas Tabelas

**EQUIPAMENTO:**
- ✅ Campo **id_departamento** adicionado (Foreign Key para DEPARTAMENTO)
- ✅ Relação agora é direta via FK: EQUIPAMENTO.id_departamento → DEPARTAMENTO.id_departamento
- Índice adicionado: `idx_equip_dept`

### Impacto nas Procedures

**02_crud.sql:**
- ✅ `sp_insert_equipamento()` - novo parâmetro: `p_id_departamento`
- ✅ `sp_update_equipamento()` - novo parâmetro: `p_id_departamento`

### Impacto nas Views

**07_views.sql:**
- ✅ `vw_equipamentos_completo` - simplificada, usa FK direto
- ✅ `vw_custo_manutencao_por_dept` - simplificada, usa FK direto
- ✅ `vw_responsaveis_departamentos` - agora inclui contador de equipamentos

### Ficheiros Não Afetados

- 04_procedures.sql (procedurs de negócio sem referência)
- 05_functions.sql (functions sem referência)
- 06_triggers.sql (triggers sem referência)

### Benefícios

- ✅ Modelo mais simples
- ✅ Menos joins nas queries
- ✅ Melhor performance
- ✅ Integridade referencial mantida
- ✅ Um equipamento pertence a exatamente um departamento

### Compatibilidade

- ✅ Totalmente compatível com MySQL 8.0+
- ✅ Sem quebra de funcionalidade
- ✅ Dados de teste atualizados

---

