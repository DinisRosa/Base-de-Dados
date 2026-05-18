#!/bin/bash

# Script de setup completo: drop, modelo, povoamento, procedures e queries de teste
# Uso: ./setup.sh [usuario] [password]
# Exemplo: ./setup.sh dinisrosa minha_senha

set -e

# Configuracao
PROJDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_USER="${1:-dinisrosa}"
DB_PASS="${2:-.}"
MYSQL_CMD="mysql -u $DB_USER -p$DB_PASS"

echo "============================================"
echo "Setup Completo - Sistema de Gestao Equipamentos Medicos"
echo "============================================"
echo "Diretorio: $PROJDIR"
echo "Usuario: $DB_USER"
echo ""

# 1) DROP (remove bases de dados existentes)
echo "[1/5] Executando drop.sql..."
$MYSQL_CMD < "$PROJDIR/drop.sql" 2>/dev/null || echo "  (bases de dados nao existiam, continuando...)"
echo "  ✓ Drop concluido"
echo ""

# 2) MODELO FISICO (cria schema mydb_uniforme)
echo "[2/5] Executando modelo_fisico_uniforme.sql..."
$MYSQL_CMD < "$PROJDIR/modelo_fisico_uniforme.sql" || {
    echo "✗ Erro ao criar modelo fisico!"
    exit 1
}
echo "  ✓ Schema mydb_uniforme criado"
echo ""

# 3) POVOAMENTO (inserts de exemplo)
echo "[3/5] Executando povoamento_uniforme.sql..."
$MYSQL_CMD < "$PROJDIR/povoamento_uniforme.sql" || {
    echo "✗ Erro ao popular base de dados!"
    exit 1
}
echo "  ✓ Dados de exemplo inseridos"
echo ""

# 4) PROCEDURES (cria todas as stored procedures)
echo "[4/5] Executando procedures..."

procedures=(
    "registar_avaria.sql"
    "concluir_manutencao.sql"
    "adicionar_intervencao_tecnico.sql"
    "abater_equipamento.sql"
    "alterar_prioridade_ordem.sql"
    "abrir_manutencao.sql"
    "listar_alertas.sql"
    "validar_estado_ordem.sql"
    "adicionar_responsavel.sql"
    "adicionar_tecnico.sql"
    "adicionar_peca.sql"
    "abater_pecas.sql"
)

for proc in "${procedures[@]}"; do
    echo "  - $proc"
    $MYSQL_CMD < "$PROJDIR/procedures/$proc" || {
        echo "✗ Erro ao criar procedure $proc"
        exit 1
    }
done
echo "  ✓ Todas as procedures criadas"
echo ""

# 5) QUERIES SANIDADE (testes funcionais)
echo "[5/5] Executando queries_sanidade_2.sql (testes das procedures)..."
$MYSQL_CMD < "$PROJDIR/queries_sanidade_2.sql" || {
    echo "✗ Erro ao executar testes!"
    exit 1
}
echo "  ✓ Testes executados com sucesso"
echo ""

echo "============================================"
echo "✓ Setup completo concluido!"
echo "============================================"
echo ""
echo "Base de dados mydb_uniforme esta pronta para uso."
echo "Conecte-se com: mysql -u $DB_USER -p"
echo ""
