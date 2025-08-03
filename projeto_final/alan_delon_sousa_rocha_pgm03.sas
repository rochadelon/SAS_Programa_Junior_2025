/*
 * Programa: alan_delon_sousa_rocha_pgm03.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Exploração do arquivo "censo_2022_municipio_sexo_idade"
 * Data: 03/08/2025
 */

/* Garantindo acesso à library DataIESB */
libname DataIESB postgres  
    server='bigdata.dataiesb.com'
    port=5432  
    user=data_iesb  
    password=iesb  
    database=iesb  
    schema=public 
    access=readonly; 
run;

/* 5.1.1 Calcular a população do Brasil */
proc sql;
    title "População Total do Brasil - Censo 2022";
    select sum(populacao) as População_Total format=comma15.
    from DataIESB.censo_2022_municipio_sexo_idade;
quit;

/* 5.1.2 Calcular a população do Brasil por Região */
proc sql;
    title "População do Brasil por Região - Censo 2022";
    select r.nome_regiao as Região,
           sum(c.populacao) as População format=comma15.
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    inner join DataIESB.regiao r on uf.codigo_regiao = r.codigo_regiao
    group by r.nome_regiao
    order by População desc;
quit;

/* 5.1.3 Calcular a população do Brasil por Unidade da Federação */
proc sql;
    title "População do Brasil por Unidade da Federação - Censo 2022";
    select uf.nome_unidade_federacao as UF,
           uf.sigla_unidade_federacao as Sigla,
           sum(c.populacao) as População format=comma15.
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    group by uf.nome_unidade_federacao, uf.sigla_unidade_federacao
    order by População desc;
quit;

/* 5.1.4 Calcular a população do Brasil por Sexo */
proc sql;
    title "População do Brasil por Sexo - Censo 2022";
    select sexo,
           sum(populacao) as População format=comma15.,
           calculated População / (select sum(populacao) from DataIESB.censo_2022_municipio_sexo_idade) * 100 as Percentual format=5.2
    from DataIESB.censo_2022_municipio_sexo_idade
    group by sexo
    order by População desc;
quit;

/* 5.1.5 Calcular a população do Brasil por Idade */
proc sql;
    title "População do Brasil por Faixa Etária - Censo 2022";
    select case 
        when idade between 0 and 14 then '0-14 anos'
        when idade between 15 and 29 then '15-29 anos'
        when idade between 30 and 44 then '30-44 anos'
        when idade between 45 and 59 then '45-59 anos'
        when idade between 60 and 74 then '60-74 anos'
        when idade >= 75 then '75+ anos'
        else 'Outros'
    end as Faixa_Etária,
    sum(populacao) as População format=comma15.
    from DataIESB.censo_2022_municipio_sexo_idade
    group by calculated Faixa_Etária
    order by População desc;
quit;

/* 1.1.1 Calcular a população do Brasil por Unidade da Federação*Sexo */
proc sql;
    title "População do Brasil por UF e Sexo - Censo 2022";
    select uf.sigla_unidade_federacao as UF,
           c.sexo,
           sum(c.populacao) as População format=comma15.
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    group by uf.sigla_unidade_federacao, c.sexo
    order by UF, c.sexo;
quit;

/* 1.1.2 Calcular a população do Brasil por Unidade da Federação*Sexo*Idade */
proc sql;
    title "População do Brasil por UF, Sexo e Faixa Etária - Censo 2022 (Primeiros 50 registros)";
    select uf.sigla_unidade_federacao as UF,
           c.sexo,
           case 
               when c.idade between 0 and 14 then '0-14 anos'
               when c.idade between 15 and 29 then '15-29 anos'
               when c.idade between 30 and 44 then '30-44 anos'
               when c.idade between 45 and 59 then '45-59 anos'
               when c.idade between 60 and 74 then '60-74 anos'
               when c.idade >= 75 then '75+ anos'
               else 'Outros'
           end as Faixa_Etária,
           sum(c.populacao) as População format=comma15.
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    group by uf.sigla_unidade_federacao, c.sexo, calculated Faixa_Etária
    order by UF, c.sexo, População desc;
quit;

/* 1.1.3 Construir um gráfico, apresentando o total da população do Brasil por Unidade da Federação */
proc sql;
    create table pop_uf as
    select uf.sigla_unidade_federacao as UF,
           sum(c.populacao) as População
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    group by uf.sigla_unidade_federacao
    order by População desc;
quit;

proc sgplot data=pop_uf;
    title "População por Unidade da Federação - Censo 2022";
    vbar UF / response=População datalabel;
    xaxis label="Unidade da Federação";
    yaxis label="População" grid;
    format População comma15.;
run;

/* 1.1.4 Construir um Mapa do Brasil por Município */
/* Preparação dos dados para o mapa */
proc sql;
    create table dados_mapa as
    select m.nome_municipio,
           uf.sigla_unidade_federacao as UF,
           sum(c.populacao) as População
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    group by m.nome_municipio, uf.sigla_unidade_federacao
    having População > 0
    order by População desc;
quit;

/* Gráfico de dispersão representando a distribuição populacional */
proc sgplot data=dados_mapa (obs=1000);
    title "Distribuição da População Municipal - Brasil (Top 1000 Municípios)";
    bubble x=UF y=População size=População / transparency=0.5;
    xaxis label="Unidade da Federação";
    yaxis label="População" type=log;
    format População comma15.;
run;

/* 1.1.5 Sugerir e construir mais 3 relatórios com esta base de dados */

/* Relatório Adicional 1: Análise da Estrutura Etária por Região */
proc sql;
    title "Estrutura Etária por Região - Censo 2022";
    select r.nome_regiao as Região,
           case 
               when c.idade between 0 and 14 then '0-14 anos'
               when c.idade between 15 and 64 then '15-64 anos'
               when c.idade >= 65 then '65+ anos'
               else 'Outros'
           end as Grupo_Etário,
           sum(c.populacao) as População format=comma15.,
           calculated População / (select sum(populacao) 
                                 from DataIESB.censo_2022_municipio_sexo_idade c2
                                 inner join DataIESB.municipio m2 on c2.codigo_municipio = m2.codigo_municipio
                                 inner join DataIESB.unidade_federacao uf2 on m2.codigo_unidade_federacao = uf2.codigo_unidade_federacao
                                 inner join DataIESB.regiao r2 on uf2.codigo_regiao = r2.codigo_regiao
                                 where r2.nome_regiao = r.nome_regiao) * 100 as Percentual format=5.2
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    inner join DataIESB.regiao r on uf.codigo_regiao = r.codigo_regiao
    group by r.nome_regiao, calculated Grupo_Etário
    order by Região, Grupo_Etário;
quit;

/* Relatório Adicional 2: Top 20 Municípios Mais Populosos */
proc sql;
    title "Top 20 Municípios Mais Populosos do Brasil - Censo 2022";
    select m.nome_municipio as Município,
           uf.sigla_unidade_federacao as UF,
           sum(c.populacao) as População format=comma15.
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    group by m.nome_municipio, uf.sigla_unidade_federacao
    order by População desc
    limit 20;
quit;

/* Relatório Adicional 3: Razão de Dependência por UF */
proc sql;
    title "Razão de Dependência por Unidade da Federação - Censo 2022";
    select uf.sigla_unidade_federacao as UF,
           sum(case when c.idade between 0 and 14 or c.idade >= 65 then c.populacao else 0 end) as Pop_Dependente format=comma15.,
           sum(case when c.idade between 15 and 64 then c.populacao else 0 end) as Pop_Ativa format=comma15.,
           calculated Pop_Dependente / calculated Pop_Ativa * 100 as Razão_Dependência format=5.2
    from DataIESB.censo_2022_municipio_sexo_idade c
    inner join DataIESB.municipio m on c.codigo_municipio = m.codigo_municipio
    inner join DataIESB.unidade_federacao uf on m.codigo_unidade_federacao = uf.codigo_unidade_federacao
    group by uf.sigla_unidade_federacao
    order by Razão_Dependência desc;
quit;