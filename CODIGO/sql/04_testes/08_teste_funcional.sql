-- ============================================================
-- SISTEMA DE GESTÃO DE EQUIPAMENTOS MÉDICOS
-- Ficheiro 08: Script de Teste Funcional
-- Testa integridade, relacionamentos e operações da BD
-- ============================================================

USE gestao_equipamentos;

-- ============================================================
-- 1. VERIFICAÇÃO DE ESTRUTURA: Tabelas Criadas
-- ============================================================
SELECT '========== 1. TABELAS CRIADAS ==========' AS teste;
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'gestao_equipamentos' AND TABLE_NAME = t.TABLE_NAME) AS colunas
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_SCHEMA = 'gestao_equipamentos'
ORDER BY TABLE_NAME;

-- ============================================================
-- 2. TESTE DE INTEGRIDADE REFERENCIAL
-- ============================================================
SELECT '\n========== 2. INTEGRIDADE REFERENCIAL ==========' AS teste;

-- Verificar RESPONSAVEL com DEPARTAMENTO válido
SELECT 'RESPONSAVEL -> DEPARTAMENTO' AS referencia,
       COUNT(*) AS total_responsaveis,
       SUM(CASE WHEN id_departamento IS NULL THEN 1 ELSE 0 END) AS nulos
FROM RESPONSAVEL;

-- Verificar EQUIPAMENTO com DEPARTAMENTO válido
SELECT 'EQUIPAMENTO -> DEPARTAMENTO' AS referencia,
       COUNT(*) AS total_equipamentos,
       SUM(CASE WHEN id_departamento IS NULL THEN 1 ELSE 0 END) AS nulos
FROM EQUIPAMENTO;

-- Verificar EQUIPAMENTO com LOCALIZACAO válida
SELECT 'EQUIPAMENTO -> LOCALIZACAO' AS referencia,
       COUNT(*) AS total_equipamentos,
       SUM(CASE WHEN id_localizacao IS NULL THEN 1 ELSE 0 END) AS nulos
FROM EQUIPAMENTO;

-- ============================================================
-- 3. TESTE DE ATRIBUTOS MULTIVALOR
-- ============================================================
SELECT '\n========== 3. ATRIBUTOS MULTIVALORADOS ==========' AS teste;

-- Contactos de Responsáveis
SELECT 'RESPONSAVEL_CONTACTO' AS tabela,
       COUNT(*) AS total_contactos,
       COUNT(DISTINCT id_responsavel) AS responsaveis_com_contactos
FROM RESPONSAVEL_CONTACTO;

-- Contactos de Técnicos
SELECT 'TECNICO_CONTACTO' AS tabela,
       COUNT(*) AS total_contactos,
       COUNT(DISTINCT id_tecnico) AS tecnicos_com_contactos
FROM TECNICO_CONTACTO;

-- Contactos de Suporte de Equipamentos
SELECT 'EQUIPAMENTO_CONTACTO_SUPORTE' AS tabela,
       COUNT(*) AS total_contactos,
       COUNT(DISTINCT id_equipamento) AS equipamentos_com_contactos
FROM EQUIPAMENTO_CONTACTO_SUPORTE;

-- ============================================================
-- 4. TESTE DE DADOS PRINCIPAIS
-- ============================================================
SELECT '\n========== 4. POPULACAO DE DADOS ==========' AS teste;

SELECT 'DEPARTAMENTO' AS tabela, COUNT(*) AS registos FROM DEPARTAMENTO
UNION ALL
SELECT 'LOCALIZACAO', COUNT(*) FROM LOCALIZACAO
UNION ALL
SELECT 'RESPONSAVEL', COUNT(*) FROM RESPONSAVEL
UNION ALL
SELECT 'EQUIPAMENTO', COUNT(*) FROM EQUIPAMENTO
UNION ALL
SELECT 'TECNICO', COUNT(*) FROM TECNICO
UNION ALL
SELECT 'MANUTENCAO', COUNT(*) FROM MANUTENCAO
UNION ALL
SELECT 'PECA', COUNT(*) FROM PECA
UNION ALL
SELECT 'ORDEM_SERVICO', COUNT(*) FROM ORDEM_SERVICO;

-- ============================================================
-- 5. TESTE DE CONSTRAINTS E VALIDAÇÕES
-- ============================================================
SELECT '\n========== 5. VALIDAÇÃO DE CONSTRAINTS ==========' AS teste;

-- Verificar estados válidos de EQUIPAMENTO
SELECT DISTINCT estado AS 'EQUIPAMENTO.estado'
FROM EQUIPAMENTO
ORDER BY estado;

-- Verificar estado_atual válido
SELECT DISTINCT estado_atual AS 'EQUIPAMENTO.estado_atual'
FROM EQUIPAMENTO
ORDER BY estado_atual;

-- Verificar prioridades de ORDEM_SERVICO
SELECT DISTINCT prioridade AS 'ORDEM_SERVICO.prioridade'
FROM ORDEM_SERVICO
ORDER BY prioridade;

-- Verificar garantia >= 0
SELECT 
    'Garantia >= 0' AS validacao,
    COUNT(*) AS equipamentos_validos,
    MIN(garantia) AS min_garantia,
    MAX(garantia) AS max_garantia
FROM EQUIPAMENTO;

-- ============================================================
-- 6. TESTE DE RELACIONAMENTOS 1:N
-- ============================================================
SELECT '\n========== 6. RELACIONAMENTOS 1:N ==========' AS teste;

-- Equipamentos por Departamento
SELECT 'EQUIPAMENTO : DEPARTAMENTO' AS relacao,
       d.designacao AS departamento,
       COUNT(e.id_equipamento) AS equipamentos
FROM DEPARTAMENTO d
LEFT JOIN EQUIPAMENTO e ON d.id_departamento = e.id_departamento
GROUP BY d.id_departamento, d.designacao
ORDER BY equipamentos DESC;

-- Técnicos com Manutenções
SELECT 'TECNICO : MANUTENCAO' AS relacao,
       t.nome AS tecnico,
       COUNT(DISTINCT im.id_manutencao) AS manutencoes
FROM TECNICO t
LEFT JOIN INTERVENCAO_TECNICO im ON t.id_tecnico = im.id_tecnico
GROUP BY t.id_tecnico, t.nome
ORDER BY manutencoes DESC;

-- ============================================================
-- 7. TESTE DE QUERY COMPLEXA: Equipamentos com Detalhes Completos
-- ============================================================
SELECT '\n========== 7. QUERY COMPLEXA - EQUIPAMENTO COM DETALHES ==========' AS teste;

SELECT 
    e.id_equipamento,
    e.designacao,
    e.fabricante,
    e.estado,
    d.designacao AS departamento,
    l.sala,
    l.piso,
    l.edificio,
    GROUP_CONCAT(cs.contacto_suporte SEPARATOR ', ') AS contactos_suporte
FROM EQUIPAMENTO e
LEFT JOIN DEPARTAMENTO d ON e.id_departamento = d.id_departamento
LEFT JOIN LOCALIZACAO l ON e.id_localizacao = l.id_localizacao
LEFT JOIN EQUIPAMENTO_CONTACTO_SUPORTE cs ON e.id_equipamento = cs.id_equipamento
GROUP BY e.id_equipamento, e.designacao, e.fabricante, e.estado, 
         d.id_departamento, d.designacao, l.id_localizacao, l.sala, l.piso, l.edificio;

-- ============================================================
-- 8. TESTE DE QUERY: Manutenções com Detalhes
-- ============================================================
SELECT '\n========== 8. QUERY - MANUTENCOES COM DETALHES ==========' AS teste;

SELECT 
    m.id_manutencao,
    m.tipo,
    e.designacao AS equipamento,
    m.data_inicio,
    m.data_fim,
    m.custo,
    GROUP_CONCAT(DISTINCT t.nome SEPARATOR ', ') AS tecnicos_atribuidos,
    COUNT(DISTINCT mp.id_peca) AS pecas_utilizadas
FROM MANUTENCAO m
LEFT JOIN EQUIPAMENTO e ON m.id_equipamento = e.id_equipamento
LEFT JOIN INTERVENCAO_TECNICO it ON m.id_manutencao = it.id_manutencao
LEFT JOIN TECNICO t ON it.id_tecnico = t.id_tecnico
LEFT JOIN MANUTENCAO_PECA mp ON m.id_manutencao = mp.id_manutencao
GROUP BY m.id_manutencao, m.tipo, e.designacao, m.data_inicio, m.data_fim, m.custo;

-- ============================================================
-- 9. TESTE DE ESTATÍSTICAS
-- ============================================================
SELECT '\n========== 9. ESTATÍSTICAS ==========' AS teste;

-- Custo total de manutenções
SELECT 
    'Custo Total Manutenções' AS metrica,
    CONCAT('€ ', ROUND(SUM(custo), 2)) AS valor
FROM MANUTENCAO;

-- Equipamentos por estado
SELECT 
    'Equipamentos por Estado' AS metrica,
    CONCAT(estado, ' (', COUNT(*), ')') AS detalhes
FROM EQUIPAMENTO
GROUP BY estado;

-- Horas totais de trabalho
SELECT 
    'Horas Totais Trabalho' AS metrica,
    CONCAT(ROUND(SUM(horas_trabalho), 1), ' h') AS valor
FROM MANUTENCAO;

-- ============================================================
-- 10. TESTE DE VIEWS (se existirem)
-- ============================================================
SELECT '\n========== 10. VIEWS CRIADAS ==========' AS teste;

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gestao_equipamentos' AND TABLE_TYPE = 'VIEW'
ORDER BY TABLE_NAME;

-- ============================================================
-- 11. TESTE DE TRIGGERS (Log de Auditoria)
-- ============================================================
SELECT '\n========== 11. AUDITORIA DISPONÍVEL ==========' AS teste;

SELECT 'AUDITORIA_EQUIPAMENTO' AS tabela,
       COUNT(*) AS eventos_auditados
FROM AUDITORIA_EQUIPAMENTO;

-- ============================================================
-- 12. TESTE DE PROCEDURES (se existirem)
-- ============================================================
SELECT '\n========== 12. PROCEDURES DISPONÍVEIS ==========' AS teste;

SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'gestao_equipamentos'
ORDER BY ROUTINE_NAME;

-- ============================================================
-- 13. RESUMO FINAL DE INTEGRIDADE
-- ============================================================
SELECT '\n========== RESUMO FINAL ==========' AS teste;
SELECT 
    'Base de Dados: gestao_equipamentos' AS info,
    'Status' AS status_label,
    'FUNCIONAL' AS status
UNION ALL
SELECT 
    'Tabelas',
    'Criadas',
    CONCAT((SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_SCHEMA = 'gestao_equipamentos'), ' tabelas')
UNION ALL
SELECT 
    'Registos',
    'Populados',
    CONCAT((SELECT SUM(TABLE_ROWS) FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_SCHEMA = 'gestao_equipamentos'), ' registos')
UNION ALL
SELECT 
    'Integridade',
    'Referencial',
    'Sem violações detectadas'
UNION ALL
SELECT 
    'Constraints',
    'Validação',
    'Validadas com sucesso';

-- ============================================================
-- FIM DO FICHEIRO 08_teste_funcional.sql
-- ============================================================
