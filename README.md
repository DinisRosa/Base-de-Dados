# Projeto da UC "Bases de Dados Clínicas e de Gestão Hospitalar" — Universidade do Minho
**Trabalho académico da Unidade Curricular (UC) desenvolvido no âmbito da Universidade do Minho.**

**Autores**

| Número | Nome |
| --- | --- |
| A107272 | Beatriz Maria Ferreira de Freitas Ribeiro |
| A107195 | Clara Sofia Salazar Carvalho |
| A107159 | Dinis Soveral Botelho Rosa |
| A107246 | Renata Madalena Ferreira Bravo |

## Resumo
Projeto de base de dados para um **Sistema de Gestão e Manutenção de Equipamentos Médicos Hospitalares**, cobrindo o modelo físico, povoamento de dados, funções, triggers, procedures, views e queries de análise/relatório.

## Conteúdo do repositório
| Ficheiro | Descrição |
| --- | --- |
| `Relatório.pdf` | Relatório completo do projeto (contexto, requisitos e decisão de modelação). |
| `PROJETO/1_modelo_fisico.sql` | Criação do schema e tabelas (modelo físico). |
| `PROJETO/2_povoamento_COSMO.sql` | Povoamento com dados de exemplo. |
| `PROJETO/3_functions_FLIK.sql` | Funções para atributos derivados (idade, duração, experiência, localização, custos). |
| `PROJETO/4_triggers_COSMO.sql` | Triggers de validação e integridade (datas, estados e coerência). |
| `PROJETO/5_procedures_NAVAL.sql` | Procedures para operações principais (registo de avaria, conclusão de manutenção, etc.). |
| `PROJETO/6_views_MONTANA.sql` | Views para análise de custos, garantias, intervenções e downtime. |
| `PROJETO/7_queries_MONTANA.sql` | Queries de exploração e relatórios baseados nas views e funções. |

## Execução (MySQL)
1. Executar `PROJETO/1_modelo_fisico.sql`.
2. Executar `PROJETO/2_povoamento_COSMO.sql`.
3. Executar `PROJETO/3_functions_FLIK.sql`.
4. Executar `PROJETO/4_triggers_COSMO.sql`.
5. Executar `PROJETO/5_procedures_NAVAL.sql`.
6. Executar `PROJETO/6_views_MONTANA.sql`.
7. Executar `PROJETO/7_queries_MONTANA.sql`.
