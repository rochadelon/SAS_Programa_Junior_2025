/*
 * Programa: alan_delon_sousa_rocha_pgm04.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Exploração do arquivo "Enem_2024_Amostra_Perfeita" - Análise de Distribuição
 * Data: 03/08/2025
 */

/* Garantindo acesso à library Dados_04 */
libname Dados_04 "/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04";

/* 5.2.1 Análise da Distribuição das variáveis "Nota de Matemática" e "Media das 5 notas" */
/* Análise da variável Nota de Matemática */
proc univariate data=Dados_04.Enem_2024_Amostra_Perfeita normal;
    title "Análise da Distribuição - Nota de Matemática - ENEM 2024";
    var nota_mt_matematica;
    histogram nota_mt_matematica / normal kernel;
    qqplot nota_mt_matematica / normal (mu=est sigma=est);
    inset mean std min max n / pos=ne;
run;

/* Análise da variável Media das 5 notas */
proc univariate data=Dados_04.Enem_2024_Amostra_Perfeita normal;
    title "Análise da Distribuição - Média das 5 Notas - ENEM 2024";
    var nota_media_5_notas;
    histogram nota_media_5_notas / normal kernel;
    qqplot nota_media_5_notas / normal (mu=est sigma=est);
    inset mean std min max n / pos=ne;
run;

/* 5.2.2 Histogramas com Curva Normal, Estimativa de Densidade e todas as Estatísticas */

/* Histograma detalhado para Nota de Matemática */
proc sgplot data=Dados_04.Enem_2024_Amostra_Perfeita;
    title "Distribuição da Nota de Matemática - ENEM 2024";
    title2 "Histograma com Curva Normal e Estimativa de Densidade";
    histogram nota_mt_matematica / transparency=0.5;
    density nota_mt_matematica / type=normal;
    density nota_mt_matematica / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label="Nota de Matemática";
    yaxis label="Densidade";
run;

/* Histograma detalhado para Média das 5 notas */
proc sgplot data=Dados_04.Enem_2024_Amostra_Perfeita;
    title "Distribuição da Média das 5 Notas - ENEM 2024";
    title2 "Histograma com Curva Normal e Estimativa de Densidade";
    histogram nota_media_5_notas / transparency=0.5;
    density nota_media_5_notas / type=normal;
    density nota_media_5_notas / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label="Média das 5 Notas";
    yaxis label="Densidade";
run;

/* Estatísticas descritivas completas para Nota de Matemática */
proc means data=Dados_04.Enem_2024_Amostra_Perfeita n mean median mode std var min max q1 q3 skew kurt;
    title "Estatísticas Descritivas Completas - Nota de Matemática";
    var nota_mt_matematica;
run;

/* Estatísticas descritivas completas para Média das 5 notas */
proc means data=Dados_04.Enem_2024_Amostra_Perfeita n mean median mode std var min max q1 q3 skew kurt;
    title "Estatísticas Descritivas Completas - Média das 5 Notas";
    var nota_media_5_notas;
run;

/* Análise comparativa das duas variáveis */
proc means data=Dados_04.Enem_2024_Amostra_Perfeita n mean median std min max;
    title "Comparação das Estatísticas - Nota de Matemática vs Média das 5 Notas";
    var nota_mt_matematica nota_media_5_notas;
run;

/* Box Plot comparativo */
data temp_melted;
    set Dados_04.Enem_2024_Amostra_Perfeita;
    keep nu_inscricao nota_mt_matematica nota_media_5_notas;
    
    /* Transformar para formato longo */
    Variavel = "Nota_Matematica";
    Valor = nota_mt_matematica;
    if not missing(Valor) then output;
    
    Variavel = "Media_5_Notas";
    Valor = nota_media_5_notas;
    if not missing(Valor) then output;
    
    drop nota_mt_matematica nota_media_5_notas;
run;

proc sgplot data=temp_melted;
    title "Box Plot Comparativo - Nota de Matemática vs Média das 5 Notas";
    vbox Valor / category=Variavel;
    xaxis label="Variável";
    yaxis label="Pontuação";
run;

/* Correlação entre as variáveis */
proc corr data=Dados_04.Enem_2024_Amostra_Perfeita plots=matrix;
    title "Correlação entre Nota de Matemática e Média das 5 Notas";
    var nota_mt_matematica nota_media_5_notas;
run;

/* Gráfico de dispersão */
proc sgplot data=Dados_04.Enem_2024_Amostra_Perfeita;
    title "Gráfico de Dispersão - Nota de Matemática vs Média das 5 Notas";
    scatter x=nota_mt_matematica y=nota_media_5_notas / transparency=0.3;
    reg x=nota_mt_matematica y=nota_media_5_notas;
    xaxis label="Nota de Matemática";
    yaxis label="Média das 5 Notas";
run;

/* Análise de valores extremos (outliers) */
proc means data=Dados_04.Enem_2024_Amostra_Perfeita noprint;
    var nota_mt_matematica;
    output out=stats_mat q1=q1_mat q3=q3_mat;
run;

proc means data=Dados_04.Enem_2024_Amostra_Perfeita noprint;
    var nota_media_5_notas;
    output out=stats_med q1=q1_med q3=q3_med;
run;

data outliers_analysis;
    if _n_ = 1 then do;
        set stats_mat;
        iqr_mat = q3_mat - q1_mat;
        lower_mat = q1_mat - 1.5 * iqr_mat;
        upper_mat = q3_mat + 1.5 * iqr_mat;
        
        set stats_med;
        iqr_med = q3_med - q1_med;
        lower_med = q1_med - 1.5 * iqr_med;
        upper_med = q3_med + 1.5 * iqr_med;
        
        retain q1_mat q3_mat iqr_mat lower_mat upper_mat
               q1_med q3_med iqr_med lower_med upper_med;
    end;
    
    set Dados_04.Enem_2024_Amostra_Perfeita;
    
    outlier_matematica = (nota_mt_matematica < lower_mat or nota_mt_matematica > upper_mat);
    outlier_media = (nota_media_5_notas < lower_med or nota_media_5_notas > upper_med);
run;

proc freq data=outliers_analysis;
    title "Análise de Valores Extremos (Outliers)";
    tables outlier_matematica outlier_media / nocum;
run;

/* Limpeza de datasets temporários */
proc datasets library=work nolist;
    delete temp_melted stats_mat stats_med outliers_analysis;
run;