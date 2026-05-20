#!/bin/bash

echo "A criar o ficheiro completo da base de dados..."
cat 1_modelo_fisico.sql 2_povoamento.sql 3_functions.sql 4_triggers.sql 5_procedures.sql 6_views.sql > 0_full_database.sql
echo "Ficheiro 0_full_database.sql criado com sucesso!"
echo "Podes abrir o 0_full_database.sql no MySQL Workbench e correr tudo de uma vez."
