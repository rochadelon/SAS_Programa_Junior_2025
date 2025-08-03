/*
 * Programa: alan_delon_sousa_rocha_pgm09.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Análise do ENEM 2024 - Visão por Estado (Ceará)
 * Data: 03/08/2025
 */

/* Garantindo acesso à library DataIesb */
libname DataIesb postgres
    server='bigdata.dataiesb.com'
    port=5432
    user=data_iesb
    password=iesb
    database=iesb
    schema=public;
run;

/* 6.3.1 Criar um novo DATASET SAS selecionando apenas o Ceará (CE) */
proc sql;
    create table enem_ceara_2024 as
    select p.nu_inscricao,
           p.co_uf_prova,
           p.no_uf_prova,
           p.tp_sexo,
           p.tp_cor_raca,
           p.tp_faixa_etaria,
           p.tp_ensino,
           p.tp_estado_civil,
           p.tp_escola,
           p.co_municipio_prova,
           p.no_municipio_prova,
           r.nu_nota_cn,
           r.nu_nota_ch,
           r.nu_nota_lc,
           r.nu_nota_mt,
           r.nu_nota_redacao,
           r.tp_status_redacao,
           /* Calcular média das 5 notas */
           case when r.nu_nota_cn is not null and 
                     r.nu_nota_ch is not null and 
                     r.nu_nota_lc is not null and 
                     r.nu_nota_mt is not null and 
                     r.nu_nota_redacao is not null
                then (r.nu_nota_cn + r.nu_nota_ch + r.nu_nota_lc + r.nu_nota_mt + r.nu_nota_redacao) / 5
                else . end as media_5_notas,
           /* Calcular média das exatas */
           case when r.nu_nota_cn is not null and r.nu_nota_mt is not null
                then (r.nu_nota_cn + r.nu_nota_mt) / 2
                else . end as media_exatas,
           /* Calcular média das humanas */
           case when r.nu_nota_ch is not null and r.nu_nota_lc is not null
                then (r.nu_nota_ch + r.nu_nota_lc) / 2
                else . end as media_humanas
    from DataIesb.ED_ENEM_2024_PARTICIPANTES p
    inner join DataIesb.ED_ENEM_2024_RESULTADOS r
    on p.nu_inscricao = r.nu_inscricao
    where p.no_uf_prova = 'Ceará'
    and (r.nu_nota_cn is not null or 
         r.nu_nota_ch is not null or 
         r.nu_nota_lc is not null or 
         r.nu_nota_mt is not null or 
         r.nu_nota_redacao is not null);
quit;

/* Verificar o dataset criado */
proc sql;
    title "Dataset ENEM 2024 - Ceará - Informações Gerais";
    select count(*) as Total_Participantes format=comma10.,
           count(distinct co_municipio_prova) as Total_Municipios,
           count(distinct tp_sexo) as Sexos,
           count(distinct tp_cor_raca) as Cor_Raca,
           count(distinct tp_faixa_etaria) as Faixas_Etarias,
           count(distinct tp_ensino) as Tipos_Ensino
    from enem_ceara_2024;
quit;

/* 6.3.2 Análise Estatística dos dados do Ceará */

/* ESTATÍSTICAS GERAIS DO CEARÁ */
proc sql;
    title "ENEM 2024 - Estatísticas Gerais - Ceará";
    select count(*) as Total_Participantes format=comma10.,
           mean(nu_nota_cn) as Media_CN format=8.2,
           mean(nu_nota_ch) as Media_CH format=8.2,
           mean(nu_nota_lc) as Media_LC format=8.2,
           mean(nu_nota_mt) as Media_MT format=8.2,
           mean(nu_nota_redacao) as Media_Redacao format=8.2,
           mean(media_5_notas) as Media_Geral format=8.2,
           mean(media_exatas) as Media_Exatas format=8.2,
           mean(media_humanas) as Media_Humanas format=8.2
    from enem_ceara_2024;
quit;

/* Medidas de resumo detalhadas - Ceará */
proc means data=enem_ceara_2024 n mean median std min max q1 q3 skew kurt;
    title "ENEM 2024 - Medidas de Resumo Detalhadas - Ceará";
    var nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao 
        media_5_notas media_exatas media_humanas;
run;

/* ANÁLISE POR MUNICÍPIO (Top 15) */
proc sql;
    title "ENEM 2024 - Desempenho por Município - Ceará (Top 15)";
    select no_municipio_prova as Municipio,
           count(*) as Participantes format=comma10.,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_ceara_2024
    group by no_municipio_prova
    having count(*) >= 50  /* Municípios com pelo menos 50 participantes */
    order by Media_Geral desc
    limit 15;
quit;

/* Gráfico dos Top 10 municípios */
proc sql;
    create table top_municipios_ce as
    select no_municipio_prova as Municipio,
           mean(media_5_notas) as Media_Geral,
           count(*) as Participantes
    from enem_ceara_2024
    group by no_municipio_prova
    having count(*) >= 100  /* Municípios com pelo menos 100 participantes */
    order by Media_Geral desc
    limit 10;
quit;

proc sgplot data=top_municipios_ce;
    title "ENEM 2024 - Top 10 Municípios do Ceará por Média Geral";
    title2 "(Municípios com 100+ participantes)";
    vbar Municipio / response=Media_Geral datalabel;
    xaxis label="Município" fitpolicy=rotate;
    yaxis label="Média Geral" grid;
    format Media_Geral 8.1;
run;

/* ANÁLISE POR SEXO - Ceará */
proc sql;
    title "ENEM 2024 - Análise por Sexo - Ceará";
    select tp_sexo as Sexo,
           count(*) as Participantes format=comma10.,
           calculated Participantes / (select count(*) from enem_ceara_2024) * 100 as Percentual format=5.2,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1,
           mean(media_exatas) as Media_Exatas format=8.1,
           mean(media_humanas) as Media_Humanas format=8.1
    from enem_ceara_2024
    where tp_sexo is not null
    group by tp_sexo
    order by Media_Geral desc;
quit;

/* Gráfico comparativo por sexo - Ceará */
data medias_sexo_ce_long;
    set enem_ceara_2024;
    where tp_sexo is not null;
    
    Area = 'CN'; Nota = nu_nota_cn; output;
    Area = 'CH'; Nota = nu_nota_ch; output;
    Area = 'LC'; Nota = nu_nota_lc; output;
    Area = 'MT'; Nota = nu_nota_mt; output;
    Area = 'RED'; Nota = nu_nota_redacao; output;
    
    keep tp_sexo Area Nota;
run;

proc means data=medias_sexo_ce_long noprint;
    class tp_sexo Area;
    var Nota;
    output out=medias_sexo_ce_stats mean=Media_Nota;
run;

proc sgplot data=medias_sexo_ce_stats;
    where _TYPE_=3;
    title "ENEM 2024 - Médias por Área e Sexo - Ceará";
    vbar Area / response=Media_Nota group=tp_sexo groupdisplay=cluster;
    xaxis label="Área de Conhecimento";
    yaxis label="Média das Notas" grid;
    format Media_Nota 8.1;
run;

/* ANÁLISE POR COR E RAÇA - Ceará */
proc sql;
    title "ENEM 2024 - Análise por Cor e Raça - Ceará";
    select tp_cor_raca as Cor_Raca,
           count(*) as Participantes format=comma10.,
           calculated Participantes / (select count(*) from enem_ceara_2024 where tp_cor_raca is not null) * 100 as Percentual format=5.2,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_ceara_2024
    where tp_cor_raca is not null
    group by tp_cor_raca
    order by Media_Geral desc;
quit;

/* ANÁLISE POR TIPO DE ENSINO - Ceará */
proc sql;
    title "ENEM 2024 - Análise por Tipo de Ensino - Ceará";
    select tp_ensino as Tipo_Ensino,
           count(*) as Participantes format=comma10.,
           calculated Participantes / (select count(*) from enem_ceara_2024 where tp_ensino is not null) * 100 as Percentual format=5.2,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_ceara_2024
    where tp_ensino is not null
    group by tp_ensino
    order by Media_Geral desc;
quit;

/* ANÁLISE POR FAIXA ETÁRIA - Ceará */
proc sql;
    title "ENEM 2024 - Análise por Faixa Etária - Ceará";
    select tp_faixa_etaria as Faixa_Etaria,
           count(*) as Participantes format=comma10.,
           calculated Participantes / (select count(*) from enem_ceara_2024 where tp_faixa_etaria is not null) * 100 as Percentual format=5.2,
           mean(media_5_notas) as Media_Geral format=8.1,
           mean(media_exatas) as Media_Exatas format=8.1,
           mean(media_humanas) as Media_Humanas format=8.1
    from enem_ceara_2024
    where tp_faixa_etaria is not null
    group by tp_faixa_etaria
    order by tp_faixa_etaria;
quit;

/* DISTRIBUIÇÕES DAS NOTAS - Ceará */
proc sgplot data=enem_ceara_2024;
    title "ENEM 2024 - Distribuição da Média Geral - Ceará";
    histogram media_5_notas / transparency=0.5;
    density media_5_notas / type=normal;
    density media_5_notas / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label="Média das 5 Notas";
    yaxis label="Densidade";
run;

/* Box Plot das notas por área - Ceará */
data notas_ce_long;
    set enem_ceara_2024;
    
    Area = 'Ciências da Natureza'; Nota = nu_nota_cn; if not missing(Nota) then output;
    Area = 'Ciências Humanas'; Nota = nu_nota_ch; if not missing(Nota) then output;
    Area = 'Linguagens e Códigos'; Nota = nu_nota_lc; if not missing(Nota) then output;
    Area = 'Matemática'; Nota = nu_nota_mt; if not missing(Nota) then output;
    Area = 'Redação'; Nota = nu_nota_redacao; if not missing(Nota) then output;
    
    keep Area Nota;
run;

proc sgplot data=notas_ce_long;
    title "ENEM 2024 - Box Plot das Notas por Área - Ceará";
    vbox Nota / category=Area;
    xaxis label="Área de Conhecimento" fitpolicy=rotate;
    yaxis label="Pontuação" grid;
run;

/* CORRELAÇÕES ENTRE AS ÁREAS - Ceará */
proc corr data=enem_ceara_2024 plots=matrix;
    title "ENEM 2024 - Correlações entre Áreas de Conhecimento - Ceará";
    var nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao;
run;

/* ANÁLISE DE DESEMPENHO ESPECÍFICA - Variáveis importantes para explicar os resultados */

/* 1. Análise da relação entre tipo de escola e desempenho */
proc sql;
    title "ENEM 2024 - Desempenho por Tipo de Escola - Ceará";
    select tp_escola as Tipo_Escola,
           count(*) as Participantes format=comma10.,
           mean(media_5_notas) as Media_Geral format=8.2,
           std(media_5_notas) as Desvio_Padrao format=8.2,
           min(media_5_notas) as Minimo format=8.1,
           max(media_5_notas) as Maximo format=8.1
    from enem_ceara_2024
    where tp_escola is not null and media_5_notas is not null
    group by tp_escola
    order by Media_Geral desc;
quit;

/* 2. Análise dos melhores e piores desempenhos */
proc sql;
    title "ENEM 2024 - Percentis de Desempenho - Ceará";
    select 'P10' as Percentil, 
           put(quantile(media_5_notas, 0.10), 8.2) as Valor
    from enem_ceara_2024
    where media_5_notas is not null
    union
    select 'P25' as Percentil, 
           put(quantile(media_5_notas, 0.25), 8.2) as Valor
    from enem_ceara_2024
    where media_5_notas is not null
    union
    select 'P50 (Mediana)' as Percentil, 
           put(quantile(media_5_notas, 0.50), 8.2) as Valor
    from enem_ceara_2024
    where media_5_notas is not null
    union
    select 'P75' as Percentil, 
           put(quantile(media_5_notas, 0.75), 8.2) as Valor
    from enem_ceara_2024
    where media_5_notas is not null
    union
    select 'P90' as Percentil, 
           put(quantile(media_5_notas, 0.90), 8.2) as Valor
    from enem_ceara_2024
    where media_5_notas is not null;
quit;

/* 3. Análise das notas de redação no Ceará */
proc sql;
    title "ENEM 2024 - Análise da Redação - Ceará";
    select count(*) as Total_Redacoes format=comma10.,
           count(case when nu_nota_redacao >= 900 then 1 end) as Notas_900_plus format=comma10.,
           count(case when nu_nota_redacao >= 800 then 1 end) as Notas_800_plus format=comma10.,
           count(case when nu_nota_redacao = 0 then 1 end) as Notas_Zero format=comma10.,
           mean(nu_nota_redacao) as Media_Redacao format=8.2,
           max(nu_nota_redacao) as Maior_Nota format=8.0
    from enem_ceara_2024
    where nu_nota_redacao is not null;
quit;

/* RESUMO FINAL - CEARÁ */
proc sql;
    title "ENEM 2024 - Resumo Executivo - Ceará";
    select 'Participantes Ceará' as Indicador, 
           put(count(*), comma10.) as Valor
    from enem_ceara_2024
    union
    select 'Municípios Participantes' as Indicador, 
           put(count(distinct co_municipio_prova), 3.) as Valor
    from enem_ceara_2024
    union
    select 'Média Geral Ceará' as Indicador, 
           put(mean(media_5_notas), 8.2) as Valor
    from enem_ceara_2024
    union
    select 'Melhor Município' as Indicador, 
           (select no_municipio_prova 
            from enem_ceara_2024 
            group by no_municipio_prova 
            having count(*) >= 50
            order by mean(media_5_notas) desc 
            limit 1) as Valor
    from enem_ceara_2024;
quit;

/* Limpeza de datasets temporários */
proc datasets library=work nolist;
    delete enem_ceara_2024 top_municipios_ce medias_sexo_ce_long 
           medias_sexo_ce_stats notas_ce_long;
run;