/*
 * Programa: alan_delon_sousa_rocha_pgm07.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Carga de dados e acesso ao projeto Big Data-IESB (SAS Workbench)
 * Data: 03/08/2025
 */

/* 6.1.1 e 6.1.2 Criação das pastas Dados e Programas no MyFolder */
/* Nota: A criação de pastas é feita através da interface do SAS Workbench */
/* As pastas devem ser criadas manualmente na interface */

/* 6.1.3 Upload do arquivo para a pasta Dados */
/* Nota: O upload é feito através da interface do SAS Workbench */

/* 6.1.4 Criar a Library Dados_01 referenciando a pasta Dados */
libname Dados_01 "/export/viya/homes/2320048@aluno.fbuni.edu.br/MyFolder/Dados";

/* 6.1.5 Importar o arquivo "Enem_2024_Amostra_Perfeita.xlsx" usando a library Dados_01 */
proc import 
    datafile="/export/viya/homes/2320048@aluno.fbuni.edu.br/MyFolder/Dados/Enem_2024_Amostra_Perfeita.xlsx"
    out=Dados_01.Enem_2024_Amostra_Perfeita
    dbms=xlsx
    replace;
    getnames=yes;
run;

/* 6.1.6 Executar a Proc Contents para o arquivo Importado */
proc contents data=Dados_01.Enem_2024_Amostra_Perfeita;
    title "Estrutura do Dataset Importado - ENEM 2024 Amostra Perfeita";
    title2 "Library: Dados_01 (SAS Workbench)";
run;

/* Visualização de amostra dos dados importados */
proc print data=Dados_01.Enem_2024_Amostra_Perfeita (obs=10);
    title "Amostra dos Dados Importados - ENEM 2024";
    title2 "Primeiras 10 observações";
run;

/* Estatísticas básicas do dataset importado */
proc sql;
    title "Informações Gerais do Dataset Importado";
    select count(*) as Total_Registros format=comma10.,
           count(distinct sg_uf_prova) as Total_UFs,
           count(distinct tp_sexo) as Total_Sexos,
           count(distinct tp_cor_raca) as Total_Cor_Raca
    from Dados_01.Enem_2024_Amostra_Perfeita;
quit;

/* 6.1.7 Criar a Library DataIesb usando os parâmetros para conexão */
libname DataIesb postgres
    server='bigdata.dataiesb.com'
    port=5432
    user=data_iesb
    password=iesb
    database=iesb
    schema=public;
run;

/* Verificar a conexão com o banco de dados */
proc datasets library=DataIesb;
    title "Tabelas Disponíveis na Library DataIesb";
run;

/* 6.1.8 Executar a Proc Contents para as tabelas especificadas do Banco de Dados */

/* 1. CENSO_2022_MUNICIPIO_SEXO_IDADE */
proc contents data=DataIesb.CENSO_2022_MUNICIPIO_SEXO_IDADE;
    title "Estrutura da Tabela: CENSO_2022_MUNICIPIO_SEXO_IDADE";
    title2 "Banco de Dados: Big Data IESB";
run;

/* Amostra dos dados */
proc print data=DataIesb.CENSO_2022_MUNICIPIO_SEXO_IDADE (obs=10);
    title "Amostra da Tabela: CENSO_2022_MUNICIPIO_SEXO_IDADE";
    title2 "Primeiras 10 observações";
run;

/* 2. ED_ENEM_2024_RESULTADOS */
proc contents data=DataIesb.ED_ENEM_2024_RESULTADOS;
    title "Estrutura da Tabela: ED_ENEM_2024_RESULTADOS";
    title2 "Banco de Dados: Big Data IESB";
run;

/* Amostra dos dados */
proc print data=DataIesb.ED_ENEM_2024_RESULTADOS (obs=10);
    title "Amostra da Tabela: ED_ENEM_2024_RESULTADOS";
    title2 "Primeiras 10 observações";
run;

/* 3. ED_ENEM_2024_RESULTADOS_AMOS_PER */
proc contents data=DataIesb.ED_ENEM_2024_RESULTADOS_AMOS_PER;
    title "Estrutura da Tabela: ED_ENEM_2024_RESULTADOS_AMOS_PER";
    title2 "Banco de Dados: Big Data IESB";
run;

/* Amostra dos dados */
proc print data=DataIesb.ED_ENEM_2024_RESULTADOS_AMOS_PER (obs=10);
    title "Amostra da Tabela: ED_ENEM_2024_RESULTADOS_AMOS_PER";
    title2 "Primeiras 10 observações";
run;

/* 4. ED_ENEM_2024_PARTICIPANTES */
proc contents data=DataIesb.ED_ENEM_2024_PARTICIPANTES;
    title "Estrutura da Tabela: ED_ENEM_2024_PARTICIPANTES";
    title2 "Banco de Dados: Big Data IESB";
run;

/* Amostra dos dados */
proc print data=DataIesb.ED_ENEM_2024_PARTICIPANTES (obs=10);
    title "Amostra da Tabela: ED_ENEM_2024_PARTICIPANTES";
    title2 "Primeiras 10 observações";
run;

/* Análise complementar: Contagem de registros em cada tabela */
proc sql;
    title "Número de Registros nas Principais Tabelas";
    title2 "Banco de Dados: Big Data IESB";
    
    select 'CENSO_2022_MUNICIPIO_SEXO_IDADE' as Tabela, 
           count(*) as Registros format=comma15.
    from DataIesb.CENSO_2022_MUNICIPIO_SEXO_IDADE
    
    union
    
    select 'ED_ENEM_2024_RESULTADOS' as Tabela, 
           count(*) as Registros format=comma15.
    from DataIesb.ED_ENEM_2024_RESULTADOS
    
    union
    
    select 'ED_ENEM_2024_RESULTADOS_AMOS_PER' as Tabela, 
           count(*) as Registros format=comma15.
    from DataIesb.ED_ENEM_2024_RESULTADOS_AMOS_PER
    
    union
    
    select 'ED_ENEM_2024_PARTICIPANTES' as Tabela, 
           count(*) as Registros format=comma15.
    from DataIesb.ED_ENEM_2024_PARTICIPANTES
    
    order by Registros desc;
quit;

/* Verificar a integridade dos dados principais */
proc sql;
    title "Verificação de Integridade dos Dados - ENEM 2024";
    
    /* Participantes vs Resultados */
    select 'Participantes' as Tabela, count(distinct nu_inscricao) as Inscricoes_Unicas format=comma15.
    from DataIesb.ED_ENEM_2024_PARTICIPANTES
    
    union
    
    select 'Resultados' as Tabela, count(distinct nu_inscricao) as Inscricoes_Unicas format=comma15.
    from DataIesb.ED_ENEM_2024_RESULTADOS
    
    union
    
    select 'Resultados_Amostra' as Tabela, count(distinct nu_inscricao) as Inscricoes_Unicas format=comma15.
    from DataIesb.ED_ENEM_2024_RESULTADOS_AMOS_PER;
quit;

/* Análise das variáveis chave nas tabelas de resultados */
proc means data=DataIesb.ED_ENEM_2024_RESULTADOS n nmiss;
    title "Análise de Missings - Tabela ED_ENEM_2024_RESULTADOS";
    var nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt tp_status_redacao nu_nota_redacao;
run;

proc means data=DataIesb.ED_ENEM_2024_RESULTADOS_AMOS_PER n nmiss;
    title "Análise de Missings - Tabela ED_ENEM_2024_RESULTADOS_AMOS_PER";
    var nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt tp_status_redacao nu_nota_redacao;
run;

/* Verificar distribuição por UF nas tabelas de participantes */
proc freq data=DataIesb.ED_ENEM_2024_PARTICIPANTES;
    title "Distribuição de Participantes por UF";
    tables co_uf_prova / nocum;
run;

/* Resumo final das libraries e dados carregados */
proc sql;
    title "Resumo Final - Libraries e Datasets Disponíveis";
    select 'Dados_01' as Library, 
           'Enem_2024_Amostra_Perfeita' as Dataset,
           count(*) as Registros format=comma10.
    from Dados_01.Enem_2024_Amostra_Perfeita
    
    union
    
    select 'DataIesb' as Library, 
           'ED_ENEM_2024_PARTICIPANTES' as Dataset,
           count(*) as Registros format=comma10.
    from DataIesb.ED_ENEM_2024_PARTICIPANTES
    
    union
    
    select 'DataIesb' as Library, 
           'ED_ENEM_2024_RESULTADOS' as Dataset,
           count(*) as Registros format=comma10.
    from DataIesb.ED_ENEM_2024_RESULTADOS
    
    union
    
    select 'DataIesb' as Library, 
           'CENSO_2022_MUNICIPIO_SEXO_IDADE' as Dataset,
           count(*) as Registros format=comma10.
    from DataIesb.CENSO_2022_MUNICIPIO_SEXO_IDADE;
quit;