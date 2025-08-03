/*
 * Programa: alan_delon_sousa_rocha_pgm05.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Exploração do arquivo "ed_enem_2024_participantes"
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

/* 5.3.1 Distribuição de Frequência das Variáveis com gráficos de barras */

/* 1. Nome da UF onde o candidato fez a prova */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência - UF onde o candidato fez a prova";
    tables no_uf_prova / nocum plots=freqplot(scale=freq orient=horizontal);
run;

proc sgplot data=DataIESB.ed_enem_2024_participantes;
    title "Gráfico de Barras - UF onde o candidato fez a prova";
    vbar no_uf_prova / datalabel;
    xaxis label="UF da Prova" fitpolicy=rotate;
    yaxis label="Frequência" grid;
run;

/* Gráfico de barras acumulado para UF */
proc sql;
    create table freq_uf as
    select no_uf_prova, count(*) as frequencia
    from DataIESB.ed_enem_2024_participantes
    group by no_uf_prova
    order by frequencia desc;
quit;

data freq_uf_cum;
    set freq_uf;
    retain freq_acumulada 0;
    freq_acumulada + frequencia;
    
    /* Calcular percentual acumulado */
    if _n_ = 1 then do;
        call symputx('total_obs', freq_acumulada);
    end;
    retain total_registros;
    if _n_ = 1 then total_registros = freq_acumulada;
run;

proc sql;
    select sum(frequencia) into :total_obs
    from freq_uf;
quit;

data freq_uf_cum;
    set freq_uf_cum;
    perc_acumulado = (freq_acumulada / &total_obs) * 100;
run;

proc sgplot data=freq_uf_cum;
    title "Gráfico de Barras Acumulado - UF onde o candidato fez a prova";
    vbar no_uf_prova / response=freq_acumulada;
    xaxis label="UF da Prova" fitpolicy=rotate;
    yaxis label="Frequência Acumulada" grid;
run;

/* 2. Faixa Etária */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência - Faixa Etária";
    tables tp_faixa_etaria / nocum plots=freqplot(scale=freq);
run;

proc sgplot data=DataIESB.ed_enem_2024_participantes;
    title "Gráfico de Barras - Faixa Etária";
    vbar tp_faixa_etaria / datalabel;
    xaxis label="Faixa Etária";
    yaxis label="Frequência" grid;
run;

/* Gráfico de barras acumulado para Faixa Etária */
proc sql;
    create table freq_idade as
    select tp_faixa_etaria, count(*) as frequencia
    from DataIESB.ed_enem_2024_participantes
    group by tp_faixa_etaria
    order by tp_faixa_etaria;
quit;

data freq_idade_cum;
    set freq_idade;
    retain freq_acumulada 0;
    freq_acumulada + frequencia;
run;

proc sgplot data=freq_idade_cum;
    title "Gráfico de Barras Acumulado - Faixa Etária";
    vbar tp_faixa_etaria / response=freq_acumulada;
    xaxis label="Faixa Etária";
    yaxis label="Frequência Acumulada" grid;
run;

/* 3. Sexo */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência - Sexo";
    tables tp_sexo / nocum plots=freqplot(scale=freq);
run;

proc sgplot data=DataIESB.ed_enem_2024_participantes;
    title "Gráfico de Barras - Sexo";
    vbar tp_sexo / datalabel;
    xaxis label="Sexo";
    yaxis label="Frequência" grid;
run;

/* Gráfico de barras acumulado para Sexo */
proc sql;
    create table freq_sexo as
    select tp_sexo, count(*) as frequencia
    from DataIESB.ed_enem_2024_participantes
    group by tp_sexo
    order by frequencia desc;
quit;

data freq_sexo_cum;
    set freq_sexo;
    retain freq_acumulada 0;
    freq_acumulada + frequencia;
run;

proc sgplot data=freq_sexo_cum;
    title "Gráfico de Barras Acumulado - Sexo";
    vbar tp_sexo / response=freq_acumulada;
    xaxis label="Sexo";
    yaxis label="Frequência Acumulada" grid;
run;

/* 4. Cor e Raça */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência - Cor e Raça";
    tables tp_cor_raca / nocum plots=freqplot(scale=freq orient=horizontal);
run;

proc sgplot data=DataIESB.ed_enem_2024_participantes;
    title "Gráfico de Barras - Cor e Raça";
    vbar tp_cor_raca / datalabel;
    xaxis label="Cor e Raça" fitpolicy=rotate;
    yaxis label="Frequência" grid;
run;

/* Gráfico de barras acumulado para Cor e Raça */
proc sql;
    create table freq_cor as
    select tp_cor_raca, count(*) as frequencia
    from DataIESB.ed_enem_2024_participantes
    group by tp_cor_raca
    order by frequencia desc;
quit;

data freq_cor_cum;
    set freq_cor;
    retain freq_acumulada 0;
    freq_acumulada + frequencia;
run;

proc sgplot data=freq_cor_cum;
    title "Gráfico de Barras Acumulado - Cor e Raça";
    vbar tp_cor_raca / response=freq_acumulada;
    xaxis label="Cor e Raça" fitpolicy=rotate;
    yaxis label="Frequência Acumulada" grid;
run;

/* 5.3.2 Distribuição de Frequência Cruzada das Variáveis (SEM gráficos) */

/* 1. Nome da UF onde o candidato fez a prova por Sexo */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência Cruzada - UF da Prova por Sexo";
    tables no_uf_prova * tp_sexo / nocum norow nocol;
run;

/* Tabela de percentuais por linha */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência Cruzada - UF da Prova por Sexo (Percentuais por Linha)";
    tables no_uf_prova * tp_sexo / nocum nofreq;
run;

/* 2. Sexo por Cor e Raça */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência Cruzada - Sexo por Cor e Raça";
    tables tp_sexo * tp_cor_raca / nocum norow nocol;
run;

/* Tabela de percentuais por linha */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência Cruzada - Sexo por Cor e Raça (Percentuais por Linha)";
    tables tp_sexo * tp_cor_raca / nocum nofreq;
run;

/* 3. Cor e Raça por Faixa Etária */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência Cruzada - Cor e Raça por Faixa Etária";
    tables tp_cor_raca * tp_faixa_etaria / nocum norow nocol;
run;

/* Tabela de percentuais por linha */
proc freq data=DataIESB.ed_enem_2024_participantes;
    title "Distribuição de Frequência Cruzada - Cor e Raça por Faixa Etária (Percentuais por Linha)";
    tables tp_cor_raca * tp_faixa_etaria / nocum nofreq;
run;

/* Análises adicionais para complementar o estudo */

/* Resumo geral dos participantes */
proc sql;
    title "Resumo Geral dos Participantes ENEM 2024";
    select count(*) as Total_Participantes format=comma15.,
           count(distinct no_uf_prova) as Total_UFs,
           count(distinct tp_faixa_etaria) as Total_Faixas_Etarias,
           count(distinct tp_sexo) as Total_Sexos,
           count(distinct tp_cor_raca) as Total_Cor_Raca
    from DataIESB.ed_enem_2024_participantes;
quit;

/* Top 10 UFs com mais participantes */
proc sql;
    title "Top 10 UFs com Maior Número de Participantes";
    select no_uf_prova as UF,
           count(*) as Participantes format=comma15.,
           calculated Participantes / (select count(*) from DataIESB.ed_enem_2024_participantes) * 100 as Percentual format=5.2
    from DataIESB.ed_enem_2024_participantes
    group by no_uf_prova
    order by Participantes desc
    limit 10;
quit;

/* Limpeza de datasets temporários */
proc datasets library=work nolist;
    delete freq_uf freq_uf_cum freq_idade freq_idade_cum freq_sexo freq_sexo_cum freq_cor freq_cor_cum;
run;