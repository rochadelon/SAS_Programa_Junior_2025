/*
 * Programa: alan_delon_sousa_rocha_pgm08.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Análise do ENEM 2024 - Visão Brasil
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

/* 6.2.1 Análise Estatística dos dados ENEM 2024 utilizando ED_ENEM_2024_RESULTADOS e ED_ENEM_2024_PARTICIPANTES */

/* Criação de dataset integrado para análise */
proc sql;
    create table enem_brasil_completo as
    select p.nu_inscricao,
           p.co_uf_prova,
           p.no_uf_prova,
           p.tp_sexo,
           p.tp_cor_raca,
           p.tp_faixa_etaria,
           p.tp_ensino,
           p.tp_estado_civil,
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
                else . end as media_5_notas
    from DataIesb.ED_ENEM_2024_PARTICIPANTES p
    inner join DataIesb.ED_ENEM_2024_RESULTADOS r
    on p.nu_inscricao = r.nu_inscricao
    where r.nu_nota_cn is not null or 
          r.nu_nota_ch is not null or 
          r.nu_nota_lc is not null or 
          r.nu_nota_mt is not null or 
          r.nu_nota_redacao is not null;
quit;

/* VISÃO BRASIL - Estatísticas Gerais */
proc sql;
    title "ENEM 2024 - Estatísticas Gerais Brasil";
    select count(*) as Total_Participantes format=comma15.,
           count(distinct co_uf_prova) as Total_UFs,
           mean(nu_nota_cn) as Media_CN format=8.2,
           mean(nu_nota_ch) as Media_CH format=8.2,
           mean(nu_nota_lc) as Media_LC format=8.2,
           mean(nu_nota_mt) as Media_MT format=8.2,
           mean(nu_nota_redacao) as Media_Redacao format=8.2,
           mean(media_5_notas) as Media_Geral format=8.2
    from enem_brasil_completo;
quit;

/* Medidas de resumo das notas por área - Brasil */
proc means data=enem_brasil_completo n mean median std min max q1 q3;
    title "ENEM 2024 - Medidas de Resumo das Notas - Brasil";
    var nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao media_5_notas;
run;

/* Gráfico das médias por área de conhecimento - Brasil */
proc sql;
    create table medias_brasil as
    select 'Ciências da Natureza' as Area, mean(nu_nota_cn) as Media
    from enem_brasil_completo
    union
    select 'Ciências Humanas' as Area, mean(nu_nota_ch) as Media
    from enem_brasil_completo
    union
    select 'Linguagens e Códigos' as Area, mean(nu_nota_lc) as Media
    from enem_brasil_completo
    union
    select 'Matemática' as Area, mean(nu_nota_mt) as Media
    from enem_brasil_completo
    union
    select 'Redação' as Area, mean(nu_nota_redacao) as Media
    from enem_brasil_completo;
quit;

proc sgplot data=medias_brasil;
    title "ENEM 2024 - Médias por Área de Conhecimento - Brasil";
    vbar Area / response=Media datalabel;
    xaxis label="Área de Conhecimento";
    yaxis label="Média das Notas" grid;
    format Media 8.1;
run;

/* ANÁLISE POR UNIDADE DA FEDERAÇÃO */
proc sql;
    title "ENEM 2024 - Médias por Unidade da Federação (Top 15)";
    select no_uf_prova as UF,
           count(*) as Participantes format=comma10.,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_brasil_completo
    group by no_uf_prova
    order by Media_Geral desc
    limit 15;
quit;

/* Gráfico das médias gerais por UF */
proc sql;
    create table medias_uf as
    select no_uf_prova as UF,
           mean(media_5_notas) as Media_Geral,
           count(*) as Participantes
    from enem_brasil_completo
    group by no_uf_prova
    having count(*) >= 1000  /* UFs com pelo menos 1000 participantes */
    order by Media_Geral desc;
quit;

proc sgplot data=medias_uf;
    title "ENEM 2024 - Média Geral por UF (UFs com 1000+ participantes)";
    vbar UF / response=Media_Geral datalabel;
    xaxis label="Unidade da Federação" fitpolicy=rotate;
    yaxis label="Média Geral" grid;
    format Media_Geral 8.1;
run;

/* ANÁLISE POR SEXO */
proc sql;
    title "ENEM 2024 - Análise por Sexo - Brasil";
    select tp_sexo as Sexo,
           count(*) as Participantes format=comma10.,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_brasil_completo
    where tp_sexo is not null
    group by tp_sexo
    order by Media_Geral desc;
quit;

/* Gráfico comparativo por sexo */
data medias_sexo_long;
    set enem_brasil_completo;
    where tp_sexo is not null;
    
    /* Transformar para formato longo */
    Area = 'CN'; Nota = nu_nota_cn; output;
    Area = 'CH'; Nota = nu_nota_ch; output;
    Area = 'LC'; Nota = nu_nota_lc; output;
    Area = 'MT'; Nota = nu_nota_mt; output;
    Area = 'RED'; Nota = nu_nota_redacao; output;
    
    keep tp_sexo Area Nota;
run;

proc means data=medias_sexo_long noprint;
    class tp_sexo Area;
    var Nota;
    output out=medias_sexo_stats mean=Media_Nota;
run;

proc sgplot data=medias_sexo_stats;
    where _TYPE_=3;  /* Somente combinações de sexo e área */
    title "ENEM 2024 - Médias por Área e Sexo - Brasil";
    vbar Area / response=Media_Nota group=tp_sexo groupdisplay=cluster;
    xaxis label="Área de Conhecimento";
    yaxis label="Média das Notas" grid;
    format Media_Nota 8.1;
run;

/* ANÁLISE POR COR E RAÇA */
proc sql;
    title "ENEM 2024 - Análise por Cor e Raça - Brasil";
    select tp_cor_raca as Cor_Raca,
           count(*) as Participantes format=comma10.,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_brasil_completo
    where tp_cor_raca is not null
    group by tp_cor_raca
    order by Media_Geral desc;
quit;

/* Gráfico por cor/raça */
proc sql;
    create table medias_cor_raca as
    select tp_cor_raca,
           mean(media_5_notas) as Media_Geral,
           count(*) as Participantes
    from enem_brasil_completo
    where tp_cor_raca is not null
    group by tp_cor_raca
    order by Media_Geral desc;
quit;

proc sgplot data=medias_cor_raca;
    title "ENEM 2024 - Média Geral por Cor/Raça - Brasil";
    vbar tp_cor_raca / response=Media_Geral datalabel;
    xaxis label="Cor/Raça" fitpolicy=rotate;
    yaxis label="Média Geral" grid;
    format Media_Geral 8.1;
run;

/* ANÁLISE POR FAIXA ETÁRIA */
proc sql;
    title "ENEM 2024 - Análise por Faixa Etária - Brasil";
    select tp_faixa_etaria as Faixa_Etaria,
           count(*) as Participantes format=comma10.,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_brasil_completo
    where tp_faixa_etaria is not null
    group by tp_faixa_etaria
    order by tp_faixa_etaria;
quit;

/* ANÁLISE DE DESEMPENHO POR TIPO DE ENSINO */
proc sql;
    title "ENEM 2024 - Análise por Tipo de Ensino - Brasil";
    select tp_ensino as Tipo_Ensino,
           count(*) as Participantes format=comma10.,
           mean(nu_nota_cn) as Media_CN format=8.1,
           mean(nu_nota_ch) as Media_CH format=8.1,
           mean(nu_nota_lc) as Media_LC format=8.1,
           mean(nu_nota_mt) as Media_MT format=8.1,
           mean(nu_nota_redacao) as Media_Redacao format=8.1,
           mean(media_5_notas) as Media_Geral format=8.1
    from enem_brasil_completo
    where tp_ensino is not null
    group by tp_ensino
    order by Media_Geral desc;
quit;

/* DISTRIBUIÇÕES DAS NOTAS - Histogramas */
proc sgplot data=enem_brasil_completo;
    title "ENEM 2024 - Distribuição da Média Geral - Brasil";
    histogram media_5_notas / transparency=0.5;
    density media_5_notas / type=normal;
    density media_5_notas / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label="Média das 5 Notas";
    yaxis label="Densidade";
run;

/* Box Plot das notas por área */
data notas_long;
    set enem_brasil_completo;
    
    Area = 'Ciências da Natureza'; Nota = nu_nota_cn; if not missing(Nota) then output;
    Area = 'Ciências Humanas'; Nota = nu_nota_ch; if not missing(Nota) then output;
    Area = 'Linguagens e Códigos'; Nota = nu_nota_lc; if not missing(Nota) then output;
    Area = 'Matemática'; Nota = nu_nota_mt; if not missing(Nota) then output;
    Area = 'Redação'; Nota = nu_nota_redacao; if not missing(Nota) then output;
    
    keep Area Nota;
run;

proc sgplot data=notas_long;
    title "ENEM 2024 - Box Plot das Notas por Área - Brasil";
    vbox Nota / category=Area;
    xaxis label="Área de Conhecimento" fitpolicy=rotate;
    yaxis label="Pontuação" grid;
run;

/* RANKING DAS MELHORES PERFORMANCES */
proc sql;
    title "ENEM 2024 - Top 10 Melhores Médias Gerais por UF";
    select no_uf_prova as UF,
           count(*) as Participantes format=comma10.,
           mean(media_5_notas) as Media_Geral format=8.2,
           std(media_5_notas) as Desvio_Padrao format=8.2
    from enem_brasil_completo
    where media_5_notas is not null
    group by no_uf_prova
    having count(*) >= 500  /* UFs com pelo menos 500 participantes */
    order by Media_Geral desc
    limit 10;
quit;

/* CORRELAÇÕES ENTRE AS ÁREAS DE CONHECIMENTO */
proc corr data=enem_brasil_completo plots=matrix;
    title "ENEM 2024 - Correlações entre Áreas de Conhecimento - Brasil";
    var nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao;
run;

/* Resumo Final da Análise Brasil */
proc sql;
    title "ENEM 2024 - Resumo Final da Análise Brasil";
    select 'Total de Participantes' as Indicador, 
           put(count(*), comma15.) as Valor
    from enem_brasil_completo
    union
    select 'Média Geral Brasil' as Indicador, 
           put(mean(media_5_notas), 8.2) as Valor
    from enem_brasil_completo
    union
    select 'Desvio Padrão Geral' as Indicador, 
           put(std(media_5_notas), 8.2) as Valor
    from enem_brasil_completo
    union
    select 'UFs Participantes' as Indicador, 
           put(count(distinct co_uf_prova), 3.) as Valor
    from enem_brasil_completo;
quit;

/* Limpeza de datasets temporários */
proc datasets library=work nolist;
    delete enem_brasil_completo medias_brasil medias_uf medias_sexo_long 
           medias_sexo_stats medias_cor_raca notas_long;
run;