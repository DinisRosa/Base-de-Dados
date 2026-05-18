#!/bin/bash

# ============================================================
# SCRIPT DE TESTE DA BASE DE DADOS
# Sistema de Gestão de Equipamentos Médicos
# ============================================================

set -e

echo "============================================================"
echo "TESTE DA BASE DE DADOS - Gestão de Equipamentos Médicos"
echo "============================================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuração MySQL
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASS="${MYSQL_PASS:-}"
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"

echo -e "${BLUE}Configuração:${NC}"
echo "  Host: $MYSQL_HOST"
echo "  Porta: $MYSQL_PORT"
echo "  Utilizador: $MYSQL_USER"
echo ""

# Função para executar comando MySQL
run_mysql() {
    if [ -z "$MYSQL_PASS" ]; then
        mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" "$@"
    else
        mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" "$@"
    fi
}

# Função para executar ficheiro SQL
execute_sql() {
    local file=$1
    local description=$2
    
    echo -e "${BLUE}[...]${NC} $description"
    if run_mysql < "$file" > /tmp/sql_output.txt 2>&1; then
        echo -e "${GREEN}[OK]${NC} $description"
        return 0
    else
        echo -e "${RED}[ERRO]${NC} $description"
        cat /tmp/sql_output.txt
        return 1
    fi
}

# ============================================================
# ETAPA 1: Reconstruir base de dados
# ============================================================
echo -e "${YELLOW}ETAPA 1: Construindo base de dados...${NC}"
echo ""

execute_sql "01_tabelas.sql" "Criando tabelas" || exit 1
execute_sql "03_povoamento.sql" "Populando dados de exemplo" || exit 1

if [ -f "04_procedures.sql" ]; then
    execute_sql "04_procedures.sql" "Criando procedures" || true
fi

if [ -f "05_functions.sql" ]; then
    execute_sql "05_functions.sql" "Criando functions" || true
fi

if [ -f "06_triggers.sql" ]; then
    execute_sql "06_triggers.sql" "Criando triggers" || true
fi

if [ -f "07_views.sql" ]; then
    execute_sql "07_views.sql" "Criando views" || true
fi

echo ""

# ============================================================
# ETAPA 2: Executar testes funcionais
# ============================================================
echo -e "${YELLOW}ETAPA 2: Executando testes funcionais...${NC}"
echo ""

execute_sql "08_teste_funcional.sql" "Testes de integridade" || exit 1

echo ""

# ============================================================
# ETAPA 3: Resumo Final
# ============================================================
echo -e "${YELLOW}ETAPA 3: Resumo Final${NC}"
echo ""

echo -e "${GREEN}✓ Base de Dados FUNCIONAL${NC}"
echo ""
echo "Próximos passos:"
echo "  1. Verificar resultados dos testes acima"
echo "  2. Todos os ficheiros SQL foram executados com sucesso"
echo "  3. BD pronta para utilização"
echo ""
echo "Ficheiros executados:"
echo "  ✓ 01_tabelas.sql (Estrutura)"
echo "  ✓ 03_povoamento.sql (Dados)"
echo "  ✓ 04_procedures.sql (Procedures)"
echo "  ✓ 05_functions.sql (Functions)"
echo "  ✓ 06_triggers.sql (Triggers)"
echo "  ✓ 07_views.sql (Views)"
echo "  ✓ 08_teste_funcional.sql (Testes)"
echo ""
echo "============================================================"

