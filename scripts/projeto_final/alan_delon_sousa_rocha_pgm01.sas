/*
 * Programa: alan_delon_sousa_rocha_pgm01.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Importação de Dados no SAS Studio com a Proc Import
 * Data: 03/08/2025
 */

/* Criação da Library Dados_04 */
libname Dados_04 "/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04";

/* Importação do arquivo Excel - Enem_2024_Amostra_Perfeita.xlsx */
proc import 
    datafile="/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/Enem_2024_Amostra_Perfeita.xlsx"
    out=Dados_04.Enem_2024_Amostra_Perfeita
    dbms=xlsx
    replace;
    getnames=yes;
run;

/* Importação do arquivo CSV - SUS_PROD_AMB_2024_2025.csv */
filename sus_file "/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/SUS_PROD_AMB_2024_2025.csv" 
    encoding='windows-1252';

proc import 
    file=sus_file
    out=Dados_04.SUS_PROD_AMB_2024_2025
    dbms=csv
    replace;
    delimiter=';';
    guessingrows=MAX;
    getnames=yes;
run;

/* Aplicação de Labels na tabela SUS_PROD_AMB_2024_2025 */
/* Baseado no arquivo "09-Atribuição de Labels nas variáveis.sas" */
data Dados_04.SUS_PROD_AMB_2024_2025;
    set Dados_04.SUS_PROD_AMB_2024_2025;
    
    /* Aplicação de labels para as principais variáveis */
    label 
        CO_UNIDADE = "Código da Unidade"
        NO_FANTASIA = "Nome Fantasia"
        NO_RAZAO_SOCIAL = "Razão Social"
        CO_CNES = "Código CNES"
        CO_MUNICIPIO_GESTOR = "Código Município Gestor"
        NO_MUNICIPIO = "Nome do Município"
        CO_UNIDADE_FEDERACAO = "Código UF"
        SG_UNIDADE_FEDERACAO = "Sigla UF"
        NO_UNIDADE_FEDERACAO = "Nome UF"
        CO_REGIAO_SAUDE = "Código Região de Saúde"
        NO_REGIAO_SAUDE = "Nome Região de Saúde"
        CO_MICRO_REGIAO = "Código Micro Região"
        NO_MICRO_REGIAO = "Nome Micro Região"
        CO_DISTRITO_SANITARIO = "Código Distrito Sanitário"
        NO_DISTRITO_SANITARIO = "Nome Distrito Sanitário"
        CO_DISTANCIA_SEDE = "Distância da Sede"
        CO_TURNO_ATENDIMENTO = "Código Turno Atendimento"
        NO_TURNO_ATENDIMENTO = "Nome Turno Atendimento"
        CO_ESTABELECIMENTO_SAUDE = "Código Estabelecimento de Saúde"
        NO_ESTABELECIMENTO_SAUDE = "Nome Estabelecimento de Saúde"
        CO_ATIVIDADE_ENSINO = "Código Atividade Ensino"
        NO_ATIVIDADE_ENSINO = "Nome Atividade Ensino"
        CO_NATUREZA_ORGANIZACAO = "Código Natureza Organização"
        NO_NATUREZA_ORGANIZACAO = "Nome Natureza Organização"
        CO_NIVEL_HIERARQUIA = "Código Nível Hierarquia"
        NO_NIVEL_HIERARQUIA = "Nome Nível Hierarquia"
        CO_ESFERA_ADMINISTRATIVA = "Código Esfera Administrativa"
        NO_ESFERA_ADMINISTRATIVA = "Nome Esfera Administrativa";
run;

/* Verificação dos dados importados */
proc contents data=Dados_04.Enem_2024_Amostra_Perfeita;
    title "Conteúdo do Dataset ENEM 2024 - Amostra Perfeita";
run;

proc contents data=Dados_04.SUS_PROD_AMB_2024_2025;
    title "Conteúdo do Dataset SUS Produção Ambulatorial 2024-2025";
run;

/* Visualização das primeiras observações */
proc print data=Dados_04.Enem_2024_Amostra_Perfeita (obs=10);
    title "Primeiras 10 observações - ENEM 2024";
run;

proc print data=Dados_04.SUS_PROD_AMB_2024_2025 (obs=10);
    title "Primeiras 10 observações - SUS Produção Ambulatorial";
run;