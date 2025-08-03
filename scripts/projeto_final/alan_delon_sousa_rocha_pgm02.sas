/*
 * Programa: alan_delon_sousa_rocha_pgm02.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Acesso ao Banco de Dados PostgreSQL do projeto "Big Data – IESB"
 * Data: 03/08/2025
 */

/* Conexão com o SGBD PostgreSQL na Amazon - Projeto "Big Data - IESB" */
/* Criação da Library "DataIESB" */

libname DataIESB postgres  
    server='bigdata.dataiesb.com'
    port=5432  
    user=data_iesb  
    password=iesb  
    database=iesb  
    schema=public 
    access=readonly; 
run;

/* Verificação da conexão e listagem das tabelas disponíveis */
proc datasets library=DataIESB;
    title "Tabelas disponíveis na Library DataIESB";
run;

/* Descrição das características das SAS Tables conforme solicitado */

/* 1. censo_2022_municipio_sexo_idade */
proc contents data=DataIESB.censo_2022_municipio_sexo_idade;
    title "Estrutura da Tabela: censo_2022_municipio_sexo_idade";
run;

/* 2. ed_enem_2024_participantes */
proc contents data=DataIESB.ed_enem_2024_participantes;
    title "Estrutura da Tabela: ed_enem_2024_participantes";
run;

/* 3. ed_enem_2024_resultados */
proc contents data=DataIESB.ed_enem_2024_resultados;
    title "Estrutura da Tabela: ed_enem_2024_resultados";
run;

/* 4. municipio */
proc contents data=DataIESB.municipio;
    title "Estrutura da Tabela: municipio";
run;

/* 5. unidade_federacao */
proc contents data=DataIESB.unidade_federacao;
    title "Estrutura da Tabela: unidade_federacao";
run;

/* 6. regiao */
proc contents data=DataIESB.regiao;
    title "Estrutura da Tabela: regiao";
run;

/* 7. educacao_basica */
proc contents data=DataIESB.educacao_basica;
    title "Estrutura da Tabela: educacao_basica";
run;

/* Visualização de amostras das principais tabelas */
proc print data=DataIESB.censo_2022_municipio_sexo_idade (obs=5);
    title "Amostra da Tabela: censo_2022_municipio_sexo_idade";
run;

proc print data=DataIESB.ed_enem_2024_participantes (obs=5);
    title "Amostra da Tabela: ed_enem_2024_participantes";
run;

proc print data=DataIESB.ed_enem_2024_resultados (obs=5);
    title "Amostra da Tabela: ed_enem_2024_resultados";
run;

proc print data=DataIESB.municipio (obs=5);
    title "Amostra da Tabela: municipio";
run;

proc print data=DataIESB.unidade_federacao (obs=5);
    title "Amostra da Tabela: unidade_federacao";
run;

proc print data=DataIESB.regiao (obs=5);
    title "Amostra da Tabela: regiao";
run;

proc print data=DataIESB.educacao_basica (obs=5);
    title "Amostra da Tabela: educacao_basica";
run;

/* Verificação do número de observações em cada tabela */
proc sql;
    title "Número de registros em cada tabela";
    select 'censo_2022_municipio_sexo_idade' as Tabela, count(*) as Registros
    from DataIESB.censo_2022_municipio_sexo_idade
    union
    select 'ed_enem_2024_participantes' as Tabela, count(*) as Registros
    from DataIESB.ed_enem_2024_participantes
    union
    select 'ed_enem_2024_resultados' as Tabela, count(*) as Registros
    from DataIESB.ed_enem_2024_resultados
    union
    select 'municipio' as Tabela, count(*) as Registros
    from DataIESB.municipio
    union
    select 'unidade_federacao' as Tabela, count(*) as Registros
    from DataIESB.unidade_federacao
    union
    select 'regiao' as Tabela, count(*) as Registros
    from DataIESB.regiao
    union
    select 'educacao_basica' as Tabela, count(*) as Registros
    from DataIESB.educacao_basica;
quit;