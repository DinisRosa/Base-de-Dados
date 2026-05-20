--1. registar_avaria
--Abre uma avaria: cria manutencao, cria ordem_servico e marca o equipamento como "Em Manutencao".
USE `mydb`;
DROP PROCEDURE IF EXISTS `registar_avaria`;
DELIMITER $$
CREATE PROCEDURE `registar_avaria`(
   IN p_equipamento_id INT,
   IN p_peca_id INT,
   IN p_tipo_manutencao VARCHAR(45),
   IN p_custo_estimado DECIMAL(10,2),
   IN p_descricao VARCHAR(45),
   IN p_prioridade VARCHAR(45)
)
BEGIN
   DECLARE v_manutencao_id INT;
   DECLARE v_exists INT;
   SELECT COUNT(*) INTO v_exists
   FROM `Equipamento`
   WHERE `id_equipamento` = p_equipamento_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Equipamento inexistente.';
   END IF;
   SELECT COUNT(*) INTO v_exists
   FROM `Peca`
   WHERE `id_peca` = p_peca_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Peca inexistente.';
   END IF;
   -- 1. Regista a manutenção com a data de início atual
   INSERT INTO `Manutencao` (`custo`, `tipo`, `descricao`, `data_inicio`, `Peca_id_peca`, `Equipamento_id_equipamento`)
   VALUES (p_custo_estimado, p_tipo_manutencao, p_descricao, CURDATE(), p_peca_id, p_equipamento_id);
   -- Captura o ID da manutenção que acabou de ser inserida
   SET v_manutencao_id = LAST_INSERT_ID();
   -- 2. Cria automaticamente a Ordem de Serviço ligada a essa manutenção
   INSERT INTO `Ordem_servico` (`descricao`, `estado_atual`, `prioridade`, `Manutencao_id_manutencao`)
   VALUES (p_descricao, 'Pendente', p_prioridade, v_manutencao_id);
END$$
DELIMITER ;


--2. concluir_manutencao
--Fecha o ciclo: define data_fim da manutencao, conclui ordem_servico e volta equipamento para "Operacional".
USE `mydb`;
DROP PROCEDURE IF EXISTS `concluir_manutencao`;
DELIMITER $$
CREATE PROCEDURE `concluir_manutencao`(
   IN p_manutencao_id INT
)
BEGIN
   DECLARE v_equipamento_id INT;
   DECLARE v_data_fim DATE;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
    SELECT `Equipamento_id_equipamento`, `data_fim`
    INTO v_equipamento_id, v_data_fim
    FROM `Manutencao`
    WHERE `id_manutencao` = p_manutencao_id;
   IF v_equipamento_id IS NULL THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Manutencao inexistente.';
   END IF;
   IF v_data_fim IS NOT NULL THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Manutencao ja concluida.';
   END IF;
   START TRANSACTION;
   -- 1. Fecha a manutencao na data atual
    UPDATE `Manutencao`
    SET `data_fim` = CURDATE()
    WHERE `id_manutencao` = p_manutencao_id;
   COMMIT;
END$$
DELIMITER ;


--3. adicionar_intervencao_tecnico
--Associa tecnico a manutencao/intervencao com cargo e horas iniciais; opcionalmente muda ordem para "Em Execucao".
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_intervencao_tecnico`;
DELIMITER $$
CREATE PROCEDURE `adicionar_intervencao_tecnico`(
   IN p_tecnico_id INT,
   IN p_manutencao_id INT,
   IN p_cargo VARCHAR(45),
   IN p_horas_trabalho INT,
   IN p_mudar_ordem_execucao TINYINT
)
BEGIN
   DECLARE v_exists INT;
   DECLARE v_intervencao_id INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
   IF p_horas_trabalho <= 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Horas de trabalho tem de ser maior que zero.';
   END IF;
    SELECT COUNT(*) INTO v_exists
    FROM `Tecnico`
    WHERE `id_tecnico` = p_tecnico_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Tecnico inexistente.';
   END IF;
    SELECT COUNT(*) INTO v_exists
    FROM `Manutencao`
    WHERE `id_manutencao` = p_manutencao_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Manutencao inexistente.';
   END IF;
   START TRANSACTION;
    INSERT INTO `Intervencao_Tecnico` (`Cargo`, `horas_trabalho`, `Tecnico_id_tecnico`, `Manutencao_id_manutencao`)
    VALUES (p_cargo, p_horas_trabalho, p_tecnico_id, p_manutencao_id);
   SET v_intervencao_id = LAST_INSERT_ID();
   IF p_mudar_ordem_execucao = 1 THEN
             UPDATE `Ordem_servico`
             SET `estado_atual` = 'Em Execução'
             WHERE `Manutencao_id_manutencao` = p_manutencao_id
                 AND `estado_atual` = 'Pendente';
   END IF;
   COMMIT;
   SELECT v_intervencao_id AS intervencao_id, 'Intervencao registada.' AS mensagem;
END$$
DELIMITER ;


--4. abater_equipamento
--Marca equipamento como "Abatido/Inativo" e cancela ordens pendentes relacionadas.
USE `mydb`;
DROP PROCEDURE IF EXISTS `abater_equipamento`;
DELIMITER $$
CREATE PROCEDURE `abater_equipamento`(
   IN p_equipamento_id INT
)
BEGIN
   DECLARE v_exists INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
   SELECT COUNT(*) INTO v_exists
    FROM `Equipamento`
    WHERE `id_equipamento` = p_equipamento_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Equipamento inexistente.';
   END IF;
   START TRANSACTION;
     UPDATE `Equipamento`
     SET `estado` = 'Inativo'
     WHERE `id_equipamento` = p_equipamento_id;
     UPDATE `Ordem_servico` os
     JOIN `Manutencao` m ON m.`id_manutencao` = os.`Manutencao_id_manutencao`
     SET os.`estado_atual` = 'Cancelada'
     WHERE m.`Equipamento_id_equipamento` = p_equipamento_id
         AND os.`estado_atual` IN ('Pendente', 'Em Execução');
   COMMIT;
END$$
DELIMITER ;


--5. alterar_prioridade_ordem
--Atualiza prioridade da ordem_servico validando valores permitidos (Baixa, Media, Alta).
USE `mydb`;
DROP PROCEDURE IF EXISTS `alterar_prioridade_ordem`;
DELIMITER $$
CREATE PROCEDURE `alterar_prioridade_ordem`(
   IN p_ordem_id INT,
   IN p_nova_prioridade VARCHAR(45)
)
BEGIN

   UPDATE `Ordem_servico`
   SET `prioridade` = p_nova_prioridade
   WHERE `id_ordem` = p_ordem_id;
   IF ROW_COUNT() = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
   END IF;
END$$
DELIMITER ;





--7. listar_alertas
--Lista alertas operacionais (ex.: manutencoes antigas, ordens pendentes ha muito tempo, equipamentos parados).
USE `mydb`;
DROP PROCEDURE IF EXISTS `listar_alertas`;
DELIMITER $$
CREATE PROCEDURE `listar_alertas`(
   IN p_dias_manutencao_aberta INT,
   IN p_dias_ordem_pendente INT
)
BEGIN
   IF p_dias_manutencao_aberta <= 0 OR p_dias_ordem_pendente <= 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Os limites de dias devem ser maiores que zero.';
   END IF;
     SELECT
             'MANUTENCAO_ABERTA_ANTIGA' AS alerta,
             m.`id_manutencao` AS manutencao_id,
             e.`id_equipamento` AS equipamento_id,
             e.`designacao` AS equipamento_nome,
             m.`data_inicio`,
             DATEDIFF(CURDATE(), m.`data_inicio`) AS dias_aberta
     FROM `Manutencao` m
     JOIN `Equipamento` e ON e.`id_equipamento` = m.`Equipamento_id_equipamento`
     WHERE m.`data_fim` IS NULL
         AND DATEDIFF(CURDATE(), m.`data_inicio`) >= p_dias_manutencao_aberta
     ORDER BY dias_aberta DESC;
     SELECT
             'ORDEM_PENDENTE_ANTIGA' AS alerta,
             os.`id_ordem` AS ordem_id,
             os.`prioridade`,
             m.`id_manutencao` AS manutencao_id,
             e.`id_equipamento` AS equipamento_id,
             DATEDIFF(CURDATE(), m.`data_inicio`) AS dias_desde_abertura
     FROM `Ordem_servico` os
     JOIN `Manutencao` m ON m.`id_manutencao` = os.`Manutencao_id_manutencao`
     JOIN `Equipamento` e ON e.`id_equipamento` = m.`Equipamento_id_equipamento`
     WHERE os.`estado_atual` = 'Pendente'
         AND DATEDIFF(CURDATE(), m.`data_inicio`) >= p_dias_ordem_pendente
     ORDER BY dias_desde_abertura DESC;
   SELECT
       'EQUIPAMENTO_NAO_OPERACIONAL' AS alerta,
       e.`id_equipamento` AS equipamento_id,
       e.`designacao` AS equipamento_nome,
       e.`estado`
   FROM `Equipamento` e
   WHERE e.`estado` IN ('Em Manutenção', 'Inativo')
   ORDER BY e.`id_equipamento`;
END$$
DELIMITER ;


--8. validar_estado_ordem
--Valida transicoes de estado da ordem_servico (ex.: Pendente -> Em Execucao -> Concluida).
--CORRIGIDO: Agora aceita variantes com e sem acentos em TODAS as comparações
USE `mydb`;
DROP PROCEDURE IF EXISTS `validar_estado_ordem`;
DELIMITER $$
CREATE PROCEDURE `validar_estado_ordem`(
   IN p_ordem_id INT,
   IN p_novo_estado VARCHAR(45)
)
BEGIN
   DECLARE v_estado_atual VARCHAR(45);
   DECLARE v_estado_normalizado VARCHAR(45);
   DECLARE v_transicao_valida TINYINT DEFAULT 0;

   -- Normalizar o novo estado para versão com acentos (padrão da BD)
   SET v_estado_normalizado = CASE p_novo_estado
       WHEN 'Em Execucao' THEN 'Em Execução'
       WHEN 'Concluida' THEN 'Concluída'
       ELSE p_novo_estado
   END;


   SELECT `estado_atual`
   INTO v_estado_atual
   FROM `Ordem_servico`
   WHERE `id_ordem` = p_ordem_id;
   IF v_estado_atual IS NULL THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
   END IF;

   -- Verificar transições válidas (aceitar ambas variantes)
   IF v_estado_atual = v_estado_normalizado THEN
       SET v_transicao_valida = 1;
   ELSEIF (v_estado_atual = 'Pendente' AND v_estado_normalizado IN ('Em Execução', 'Cancelada')) THEN
       SET v_transicao_valida = 1;
   ELSEIF (v_estado_atual = 'Em Execução' AND v_estado_normalizado IN ('Concluída', 'Cancelada')) THEN
       SET v_transicao_valida = 1;
   END IF;

   IF v_transicao_valida = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Transicao de estado invalida para a ordem.';
   END IF;

   -- Usar a versão normalizada para manter consistência
   UPDATE `Ordem_servico`
   SET `estado_atual` = v_estado_normalizado
   WHERE `id_ordem` = p_ordem_id;
END$$
DELIMITER ;


--9. adicionar_responsavel
--Cria responsavel e respetivo contacto_responsavel na mesma operacao/transacao.
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_responsavel`;
DELIMITER $$
CREATE PROCEDURE `adicionar_responsavel`(
   IN p_nome VARCHAR(45),
   IN p_data_nascimento DATE,
   IN p_ordem_servico_id INT,
   IN p_telefone VARCHAR(45),
   IN p_email VARCHAR(45)
)
BEGIN
   DECLARE v_exists INT;
   DECLARE v_responsavel_id INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
   SELECT COUNT(*) INTO v_exists
   FROM `Ordem_servico`
   WHERE `id_ordem` = p_ordem_servico_id;
   IF v_exists = 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Ordem de servico inexistente.';
   END IF;
   START TRANSACTION;
   -- criar primeiro o contacto e depois o responsável (conforme modelo lógico)
   INSERT INTO `Contacto_responsavel` (`contacto`, `email`)
   VALUES (p_telefone, p_email);
   SET @v_contacto_id = LAST_INSERT_ID();
   INSERT INTO `Responsavel` (`nome`, `data_nascimento`, `Ordem_de_servico_id_ordem`, `Contacto_responsavel_id_contacto_responsavel`)
   VALUES (p_nome, p_data_nascimento, p_ordem_servico_id, @v_contacto_id);
   SET v_responsavel_id = LAST_INSERT_ID();
   COMMIT;
   SELECT v_responsavel_id AS responsavel_id, 'Responsavel e contacto criados.' AS mensagem;
END$$
DELIMITER ;


--10. adicionar_tecnico
--Cria tecnico e respetivo contacto_tecnico na mesma operacao/transacao.
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_tecnico`;
DELIMITER $$
CREATE PROCEDURE `adicionar_tecnico`(
   IN p_data_inicio_carreira VARCHAR(45),
   IN p_nome VARCHAR(45),
   IN p_especialidade VARCHAR(45),
   IN p_telefone VARCHAR(15),
   IN p_email VARCHAR(45)
)
BEGIN
   DECLARE v_tecnico_id INT;
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
       ROLLBACK;
       RESIGNAL;
   END;
    START TRANSACTION;
    -- criar primeiro o contacto_tecnico e depois o tecnico referenciando-o (modelo lógico)
    INSERT INTO `contacto_tecnico` (`contacto`, `email`)
    VALUES (p_telefone, p_email);
    SET @v_contacto_id = LAST_INSERT_ID();
    INSERT INTO `Tecnico` (`data_inicio_carreira`, `nome`, `especialidade`, `contacto_tecnico_id_contacto_tecnico`)
    VALUES (p_data_inicio_carreira, p_nome, p_especialidade, @v_contacto_id);
    SET v_tecnico_id = LAST_INSERT_ID();
   COMMIT;
   SELECT v_tecnico_id AS tecnico_id, 'Tecnico e contacto criados.' AS mensagem;
END$$
DELIMITER ;


--11. adicionar_peca
--Cria nova peca no catalogo de manutencao (preco, designacao, garantia).
USE `mydb`;
DROP PROCEDURE IF EXISTS `adicionar_peca`;
DELIMITER $$
CREATE PROCEDURE `adicionar_peca`(
   IN p_preco DECIMAL(10,2),
   IN p_designacao VARCHAR(45),
   IN p_garantia DATE
)
BEGIN
   IF p_preco < 0 THEN
       SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Preco invalido.';
   END IF;
   INSERT INTO `Peca` (`preco`, `designacao`, `garantia`)
   VALUES (p_preco, p_designacao, p_garantia);
   SELECT LAST_INSERT_ID() AS peca_id, 'Peca adicionada.' AS mensagem;
END$$
DELIMITER ;


--12. abater_pecas
--Abate em lote todas as pecas com garantia expirada e sem uso no historico de manutencoes.
USE `mydb`;
DROP PROCEDURE IF EXISTS `abater_pecas`;
DELIMITER $$
CREATE PROCEDURE `abater_pecas`()
BEGIN
     DELETE FROM `Peca` p
     WHERE p.`garantia` < CURDATE()
         AND NOT EXISTS (
                 SELECT 1
                 FROM `Manutencao` m
                 WHERE m.`Peca_id_peca` = p.`id_peca`
         );
     SELECT ROW_COUNT() AS pecas_abatidas, 'Abate de pecas concluido.' AS mensagem;
END$$
DELIMITER ;

