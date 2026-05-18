# Guia de Testes - Sistema de Gestão de Equipamentos Médicos

## 📋 Descrição

Este guia explica como testar a integridade e funcionalidade da base de dados **gestao_equipamentos**.

## 🚀 Opção 1: Script Automático (Recomendado)

### Pré-requisitos
- MySQL 8.0+ instalado e a correr
- Acesso a linha de comando
- Script `teste_bd.sh`

### Execução

#### Linux / macOS
```bash
cd sql/
./teste_bd.sh
```

#### Windows (Git Bash / WSL)
```bash
cd sql
bash teste_bd.sh
```

#### Com Credenciais Customizadas
```bash
MYSQL_USER="seu_usuario" MYSQL_PASS="sua_password" ./teste_bd.sh
```

#### Especificar Host e Porta
```bash
MYSQL_HOST="192.168.1.100" MYSQL_PORT="3307" ./teste_bd.sh
```

### Output Esperado
```
[OK] Criando tabelas
[OK] Populando dados de exemplo
[OK] Criando procedures
[OK] Criando functions
[OK] Criando triggers
[OK] Criando views
[OK] Testes de integridade

✓ Base de Dados FUNCIONAL
```

---

## 🔧 Opção 2: MySQL Workbench (Interface Gráfica)

### Passos

1. **Abrir MySQL Workbench**

2. **Criar Nova Conexão** (se necessário)
   - Hostname: `localhost`
   - Port: `3306`
   - Username: `root` (ou seu utilizador)

3. **Executar Ficheiros em Ordem**
   ```
   1. 01_tabelas.sql         (Criar estrutura)
   2. 03_povoamento.sql      (Adicionar dados)
   3. 04_procedures.sql      (Procedures - opcional)
   4. 05_functions.sql       (Functions - opcional)
   5. 06_triggers.sql        (Triggers - opcional)
   6. 07_views.sql           (Views - opcional)
   7. 08_teste_funcional.sql (Executar Testes)
   ```

4. **Analisar Resultados**
   - Verifique a aba "Result Grid"
   - Todos os testes devem passar

---

## 🛠️ Opção 3: Linha de Comando (MySQL CLI)

### Passos

#### 1. Conectar ao MySQL
```bash
mysql -h localhost -u root -p
```

#### 2. Executar Ficheiros
```sql
-- Dentro do MySQL:
source ./01_tabelas.sql;
source ./03_povoamento.sql;
source ./04_procedures.sql;
source ./05_functions.sql;
source ./06_triggers.sql;
source ./07_views.sql;
source ./08_teste_funcional.sql;
```

Ou em um único comando:
```bash
mysql -u root -p < 01_tabelas.sql && \
mysql -u root -p < 03_povoamento.sql && \
mysql -u root -p < 08_teste_funcional.sql
```

---

## ✅ O que os Testes Verificam

### 1. **Estrutura de Tabelas**
- Todas as 14 tabelas criadas corretamente
- Colunas com tipos corretos

### 2. **Integridade Referencial**
- Foreign Keys funcionam
- Sem referências órfãs (NULL onde não permitido)

### 3. **Atributos Multivalorados**
- Tabelas de multivalorados populadas:
  - `RESPONSAVEL_CONTACTO` (5 contactos)
  - `TECNICO_CONTACTO` (4 contactos)
  - `EQUIPAMENTO_CONTACTO_SUPORTE` (3 contactos)

### 4. **Constraints de Validação**
- Estados de equipamento válidos
- Prioridades de ordens de serviço válidas
- Garantia >= 0
- Datas consistentes

### 5. **Relacionamentos 1:N**
- Equipamentos agrupados por departamento
- Técnicos com suas manutenções

### 6. **Queries Complexas**
- JOINs multi-tabela
- GROUP_CONCAT para atributos multivalor
- Agregações de dados

### 7. **Triggers e Auditoria**
- Log de auditoria preenchido (AUDITORIA_EQUIPAMENTO)
- Rastreabilidade de alterações

### 8. **Procedures e Functions**
- Disponíveis e funcionais

---

## 📊 Dados de Teste Incluídos

### Departamentos (3)
- Cardiologia
- Radiologia
- Cirurgia

### Equipamentos (3)
- Eletrocardiograma (Cardio)
- Tomógrafo (Radiologia)
- Bisturi Elétrico (Cirurgia)

### Técnicos (3)
- Técnico Pedro (Equipamentos Cardíacos)
- Técnica Ana (Imaging)
- Técnico Bruno (Cirurgia)

### Manutenções (3)
- Preventiva (ECG)
- Corretiva (Tomógrafo)
- Inspeção (Bisturi)

---

## 🔍 Verificações Manuais Importantes

Após executar os testes, verifique manualmente:

### 1. Equipamento Sem Departamento (FK Nula)
```sql
SELECT * FROM EQUIPAMENTO WHERE id_departamento IS NULL;
-- Deve estar vazio se tudo estiver correto
```

### 2. Contactos de um Equipamento
```sql
SELECT 
    e.designacao,
    GROUP_CONCAT(cs.contacto_suporte SEPARATOR ', ') AS contactos
FROM EQUIPAMENTO e
LEFT JOIN EQUIPAMENTO_CONTACTO_SUPORTE cs ON e.id_equipamento = cs.id_equipamento
WHERE e.id_equipamento = 1
GROUP BY e.id_equipamento;
```

### 3. Custo Total de Manutenções
```sql
SELECT SUM(custo) as custo_total FROM MANUTENCAO;
```

### 4. Equipamentos por Estado
```sql
SELECT estado, COUNT(*) FROM EQUIPAMENTO GROUP BY estado;
```

---

## ⚠️ Troubleshooting

### Erro: "Database doesn't exist"
```bash
# Certifique-se que 01_tabelas.sql foi executado primeiro
mysql -u root -p < 01_tabelas.sql
```

### Erro: "Access denied for user"
```bash
# Use credenciais corretas:
MYSQL_USER="seu_user" MYSQL_PASS="sua_pass" ./teste_bd.sh
```

### Erro: "MySQL server not running"
```bash
# Inicie o serviço MySQL:
# Linux:
sudo systemctl start mysql
# macOS:
brew services start mysql
# Windows: Use Services (services.msc)
```

### Erro: "Foreign key constraint fails"
- Verifique que 01_tabelas.sql foi executado completamente
- Verifique a ordem das inserções em 03_povoamento.sql

---

## 📝 Notas Importantes

1. **Ordem de Execução**: Sempre execute na ordem:
   - 01_tabelas.sql (primeira)
   - 03_povoamento.sql
   - 04-07 (optional)
   - 08_teste_funcional.sql (última)

2. **Reset Completo**: Para limpar tudo e recomeçar:
   ```sql
   DROP DATABASE gestao_equipamentos;
   -- Depois execute 01_tabelas.sql novamente
   ```

3. **Dados Persistem**: Após criar as tabelas, os dados só desaparecem se:
   - Executar DROP TABLE / DROP DATABASE
   - Modificar ficheiro 01_tabelas.sql com DELETE statements

4. **Logs de Auditoria**: Verifique `AUDITORIA_EQUIPAMENTO` após alterações

---

## 🎯 Status de Sucesso

Tudo está funcionando corretamente quando você vê:

```
========== 1. TABELAS CRIADAS ==========
✓ 14 tabelas criadas

========== 2. INTEGRIDADE REFERENCIAL ==========
✓ Sem violações detectadas

========== 3. ATRIBUTOS MULTIVALORADOS ==========
✓ 5 contactos de responsáveis
✓ 4 contactos de técnicos
✓ 3 contactos de equipamentos

========== RESUMO FINAL ==========
Base de Dados: gestao_equipamentos - FUNCIONAL
Tabelas: 14 criadas
Registos: 23+ populados
Integridade: Sem violações
Constraints: Validadas
```

---

## 📞 Suporte

Em caso de problemas:
1. Verifique a ordem de execução
2. Verifique as credenciais MySQL
3. Consulte os logs de erro
4. Recrie a base de dados do zero

---

**Versão**: 1.0  
**Data**: Maio 2026  
**Compatibilidade**: MySQL 8.0+

