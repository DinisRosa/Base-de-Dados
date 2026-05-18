-- Queries de sanidade para mydb_uniforme
USE `mydb_uniforme`;

-- 1) Contagens por tabela
SELECT 'peca' AS tabela, COUNT(*) AS total FROM `peca`
UNION ALL SELECT 'tecnico', COUNT(*) FROM `tecnico`
UNION ALL SELECT 'contacto_tecnico', COUNT(*) FROM `contacto_tecnico`
UNION ALL SELECT 'responsavel', COUNT(*) FROM `responsavel`
UNION ALL SELECT 'contacto_responsavel', COUNT(*) FROM `contacto_responsavel`
UNION ALL SELECT 'departamento', COUNT(*) FROM `departamento`
UNION ALL SELECT 'localizacao', COUNT(*) FROM `localizacao`
UNION ALL SELECT 'equipamento', COUNT(*) FROM `equipamento`
UNION ALL SELECT 'contacto_equipamento', COUNT(*) FROM `contacto_equipamento`
UNION ALL SELECT 'manutencao', COUNT(*) FROM `manutencao`
UNION ALL SELECT 'ordem_servico', COUNT(*) FROM `ordem_servico`
UNION ALL SELECT 'intervencao_tecnico', COUNT(*) FROM `intervencao_tecnico`;

-- 2) Orfaos: estas queries devem devolver 0
SELECT COUNT(*) AS orfaos_contacto_tecnico
FROM `contacto_tecnico` ct
LEFT JOIN `tecnico` t ON t.id = ct.tecnico_id
WHERE t.id IS NULL;

SELECT COUNT(*) AS orfaos_contacto_responsavel
FROM `contacto_responsavel` cr
LEFT JOIN `responsavel` r ON r.id = cr.responsavel_id
WHERE r.id IS NULL;

SELECT COUNT(*) AS orfaos_departamento
FROM `departamento` d
LEFT JOIN `responsavel` r ON r.id = d.responsavel_id
WHERE r.id IS NULL;

SELECT COUNT(*) AS orfaos_localizacao
FROM `localizacao` l
LEFT JOIN `departamento` d ON d.id = l.departamento_id
WHERE d.id IS NULL;

SELECT COUNT(*) AS orfaos_equipamento_departamento
FROM `equipamento` e
LEFT JOIN `departamento` d ON d.id = e.departamento_id
WHERE d.id IS NULL;

SELECT COUNT(*) AS orfaos_equipamento_localizacao
FROM `equipamento` e
LEFT JOIN `localizacao` l ON l.id = e.localizacao_id
WHERE l.id IS NULL;

SELECT COUNT(*) AS orfaos_contacto_equipamento
FROM `contacto_equipamento` ce
LEFT JOIN `equipamento` e ON e.id = ce.equipamento_id
WHERE e.id IS NULL;

SELECT COUNT(*) AS orfaos_manutencao_peca
FROM `manutencao` m
LEFT JOIN `peca` p ON p.id = m.peca_id
WHERE p.id IS NULL;

SELECT COUNT(*) AS orfaos_manutencao_equipamento
FROM `manutencao` m
LEFT JOIN `equipamento` e ON e.id = m.equipamento_id
WHERE e.id IS NULL;

SELECT COUNT(*) AS orfaos_ordem_servico
FROM `ordem_servico` os
LEFT JOIN `manutencao` m ON m.id = os.manutencao_id
WHERE m.id IS NULL;

SELECT COUNT(*) AS orfaos_intervencao_tecnico
FROM `intervencao_tecnico` it
LEFT JOIN `tecnico` t ON t.id = it.tecnico_id
WHERE t.id IS NULL;

SELECT COUNT(*) AS orfaos_intervencao_manutencao
FROM `intervencao_tecnico` it
LEFT JOIN `manutencao` m ON m.id = it.manutencao_id
WHERE m.id IS NULL;

-- 3) JOINs de inspeccao rapida (amostra)
SELECT
  e.id AS equipamento_id,
  e.nome AS equipamento_nome,
  d.nome AS departamento,
  l.descricao AS localizacao
FROM `equipamento` e
JOIN `departamento` d ON d.id = e.departamento_id
JOIN `localizacao` l ON l.id = e.localizacao_id
ORDER BY e.id;

SELECT
  m.id AS manutencao_id,
  m.tipo,
  m.custo,
  e.nome AS equipamento,
  p.designacao AS peca
FROM `manutencao` m
JOIN `equipamento` e ON e.id = m.equipamento_id
JOIN `peca` p ON p.id = m.peca_id
ORDER BY m.id;
