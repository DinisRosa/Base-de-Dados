# Explicação Detalhada do Script `0_full_database.sql`

Este documento explica passo a passo cada seção do ficheiro `0_full_database.sql`, que constitui a versão consolidada da base de dados do projeto de "Sistema de Gestão de Equipamentos Médicos".

---

## 1. Configurações Iniciais e Criação da Base de Dados
O script começa com configurações padrão do MySQL Workbench:
- **Desativação temporária de verificações**: `UNIQUE_CHECKS=0` e `FOREIGN_KEY_CHECKS=0` são usados para evitar erros durante a criação das tabelas caso existam dependências cruzadas.
- **Configuração do SQL Mode**: Assegura que o MySQL opera num modo restrito e seguro (ex: impede divisões por zero e datas inválidas).
- **Criação do Schema**: Cria a base de dados `mydb` (caso não exista) com o *character set* `utf8` e define-a como a base de dados ativa (`USE mydb`).

---

## 2. Estrutura de Dados (Criação de Tabelas)
A primeira grande parte do script define as tabelas (Entidades) e as suas relações (Chaves Estrangeiras - FKs):

- **Tabelas Independentes (Sem dependências de outras):**
  - `Peca`: Catálogo de peças com id, preço, designação e data de garantia.
  - `Contacto_responsavel`, `contacto_tecnico`, `Equipamento_contacto`: Tabelas auxiliares que armazenam os contactos telefónicos e de e-mail associados respetivamente aos responsáveis, técnicos e fabricantes/fornecedores de equipamentos.

- **Tabelas com Dependências (Com Chaves Estrangeiras):**
  - `Ordem_servico`: Gere as ordens de serviço (estado, prioridade, descrição). Depende da tabela `Manutencao`.
  - `Responsavel`: Representa os responsáveis pelos departamentos. Está associado a uma `Ordem_servico` e a um `Contacto_responsavel`.
  - `Departamento`: Áreas do hospital (ex: Cardiologia). Cada departamento tem um `Responsavel`.
  - `Localizacao`: Define o local físico (edifício, piso, sala) associado a um `Departamento`.
  - `Tecnico`: Dados dos técnicos de manutenção, associados ao seu respetivo contacto.
  - `Equipamento`: A entidade central. Regista o estado, fabricante, e data de aquisição. Está associado a um contacto, um departamento e a uma localização.
  - `Manutencao`: Registo das manutenções (início, fim, custo, tipo). Associa um `Equipamento` a uma `Peca` (opcional).
  - `Intervencao_Tecnico`: Tabela de associação (N:M) que regista que `Tecnico` trabalhou em que `Manutencao`, qual foi o seu cargo e quantas horas investiu.

---

## 3. Povoamento de Dados (DML)
Esta secção insere dados de teste (exemplos) na base de dados para permitir o funcionamento imediato das vistas e testar a lógica do sistema. 
A inserção respeita a ordem imposta pelas chaves estrangeiras:
1. Inserem-se as tabelas sem FKs: `Peca` e as três tabelas de contactos.
2. Inserem-se os dados cíclicos contornando temporariamente as verificações: `Manutencao` -> `Ordem_servico` -> `Responsavel`.
3. Inserem-se `Departamento` -> `Localizacao`.
4. Insere-se `Tecnico`.
5. Insere-se `Equipamento` (agora que o Departamento, a Localização e o Contacto já existem).
6. Regista-se a `Intervencao_Tecnico`.

---

## 4. Funções (Functions)
As funções são criadas para calcular atributos derivados, evitando redundância na base de dados:
1. **`calcular_idade_equipamento`**: Retorna a idade do equipamento em anos com base na data de aquisição.
2. **`calcular_duracao_manutencao`**: Calcula o total de dias que durou uma manutenção (diferença entre data de fim e data de início).
3. **`calcular_experiencia_tecnico`**: Retorna os anos de experiência de um técnico.
4. **`equipamento_tem_manutencao_ativa`**: Verifica se existe alguma manutenção não concluída para o equipamento fornecido.
5. **`obter_localizacao_equipamento`**: Concatena o Edifício, Piso e Sala num único texto descritivo.
6. **`custo_total_manutencoes`**: Soma os custos de todas as manutenções registadas para um dado equipamento.

---

## 5. Gatilhos (Triggers)
Os triggers são executados automaticamente para garantir regras de negócio e a consistência dos dados:
- **Validação de Manutenções**: Impede que se adicione uma nova manutenção a um equipamento que já tem uma a decorrer (Trigger 1). Verifica também se as datas (início e fim) fazem sentido cronologicamente (Trigger 1 e 2).
- **Controlo de Estados do Equipamento**: Quando uma manutenção começa, o estado do equipamento passa a "Em Manutencao" (Trigger 3). Quando termina, passa a "Operacional" e fecha a Ordem de Serviço (Trigger 4).
- **Validação de Domínios**: Garante que os estados e prioridades da `Ordem_servico` (Trigger 5A e 5B) e do `Equipamento` (Trigger 6A e 6B) apenas aceitem valores permitidos (ex: "Pendente", "Alta", "Operacional").
- **Proteção contra Remoção**: Impede que um `Equipamento` seja eliminado se tiver manutenções ou ordens de serviço ativas (Trigger 7).
- **Validação de Custos Financeiros**: Garante que o custo cobrado pela manutenção nunca é inferior ao preço da peça aplicada (Trigger 8).

---

## 6. Procedimentos Armazenados (Stored Procedures)
Os procedures agrupam operações complexas de manipulação de dados de forma transacional (tudo ou nada):
1. **`registar_avaria`**: Abre uma manutenção, cria a ordem de serviço correspondente e marca o equipamento em manutenção.
2. **`concluir_manutencao`**: Põe a data de fim na manutenção, fecha a ordem de serviço e volta a pôr o equipamento como "Operacional".
3. **`adicionar_intervencao_tecnico`**: Associa um técnico à manutenção e pode mudar a ordem de serviço para "Em Execução".
4. **`abater_equipamento`**: Marca o equipamento como "Inativo" e cancela ordens associadas.
5. **`alterar_prioridade_ordem`**: Atualiza a prioridade de uma OS com validação.
6. **`abrir_manutencao`**: Outra forma de abrir uma OS e manutenção em simultâneo.
7. **`listar_alertas`**: Retorna múltiplos "reports" num só comando: manutenções antigas, ordens pendentes e equipamentos parados.
8. **`validar_estado_ordem`**: Trata das transições de estado para uma Ordem de Serviço.
9. **`adicionar_responsavel` / `adicionar_tecnico`**: Insere os contactos telefónicos/email e o respetivo registo de responsável ou técnico.
10. **`adicionar_peca`**: Insere uma nova peça e valida se o preço não é negativo.
11. **`abater_pecas`**: Apaga todas as peças do catálogo cuja garantia já expirou e que nunca foram utilizadas em nenhuma manutenção.

---

## 7. Vistas (Views)
As Vistas são consultas pré-gravadas ("tabelas virtuais") para análise de dados e painéis (Dashboards):
1. **`vw_custo_total_equipamento`**: Calcula o custo real juntando o custo da mão-de-obra e das peças associadas por cada equipamento.
2. **`vw_garantia_pecas`**: Avalia quais as peças aplicadas que ainda estão sob garantia e quantos dias restam.
3. **`vw_rastreabilidade_intervencoes`**: Traz o histórico completo: Qual técnico fez o quê, quando, onde, com que cargo e quanto tempo demorou.
4. **`vw_downtime_equipamentos`**: Mostra o tempo total em que um equipamento esteve inoperacional (Tempo de Paragem).
5. **`vw_localizacao_equipamentos`**: Um mapeamento global a indicar onde está exatamente cada equipamento.
6. **`vw_ordens_abertas`**: Lista de todas as ordens que precisam de ser tratadas, por nível de prioridade.
7. **`vw_tecnico_resumo`**: Estatísticas por técnico: total de intervenções e média de horas trabalhadas.
8. **`vw_custos_por_departamento`**: Sumário executivo e financeiro sobre os custos gastos em manutenção por cada departamento do hospital.
