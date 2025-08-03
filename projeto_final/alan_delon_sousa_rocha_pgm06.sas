/*
 * Programa: alan_delon_sousa_rocha_pgm06.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Exploração filtrada do arquivo "Enem_2024_Amostra_Perfeita"
 * Data: 03/08/2025
 */

/* Garantindo acesso à library Dados_04 */
libname Dados_04 "/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04";

/* 5.4.1 Criar um novo Dataset SAS com filtros específicos */
/* Considerando CE (Ceará) como UF da faculdade Centro Universitário Farias Brito */

data Dados_04.Enem_2024_Filtrado;
    set Dados_04.Enem_2024_Amostra_Perfeita;
    
    /* Aplicar filtros conforme especificado */
    where sg_uf_prova = 'CE' and nota_ch_ciencias_humanas > 600;
    
    /* Calcular a variável Nota_Media_Exatas */
    Nota_Media_Exatas = (nota_mt_matematica + nota_cn_ciencias_natureza) / 2;
    
    /* Aplicar formatação às variáveis de notas */
    format nota_media_5_notas 8.1
           nota_cn_ciencias_natureza 8.0
           nota_ch_ciencias_humanas 8.0
           nota_lc_linguagens_codigos 8.0
           nota_mt_matematica 8.0
           nota_redacao 8.0
           Nota_Media_Exatas 8.1;
    
    /* Selecionar apenas as variáveis especificadas */
    keep sg_uf_prova 
         tp_sexo 
         tp_cor_raca 
         nota_cn_ciencias_natureza 
         nota_ch_ciencias_humanas 
         nota_lc_linguagens_codigos 
         nota_mt_matematica 
         nota_redacao 
         nota_media_5_notas 
         Nota_Media_Exatas;
    
    /* Aplicar labels às variáveis */
    label sg_uf_prova = "Sigla da UF da Prova"
          tp_sexo = "Sexo"
          tp_cor_raca = "Cor e Raça"
          nota_cn_ciencias_natureza = "Nota Ciências da Natureza"
          nota_ch_ciencias_humanas = "Nota Ciências Humanas"
          nota_lc_linguagens_codigos = "Nota Linguagens e Códigos"
          nota_mt_matematica = "Nota Matemática"
          nota_redacao = "Nota Redação"
          nota_media_5_notas = "Média das 5 Notas"
          Nota_Media_Exatas = "Média das Notas Exatas (Mat + CN)";
run;

/* Verificar o dataset criado */
proc contents data=Dados_04.Enem_2024_Filtrado;
    title "Estrutura do Dataset Filtrado - ENEM 2024 Ceará";
run;

proc print data=Dados_04.Enem_2024_Filtrado (obs=10);
    title "Primeiras 10 observações do Dataset Filtrado - ENEM 2024 Ceará";
run;

/* 5.4.2 Análises utilizando o Dataset de saída */

/* Distribuição de frequência da variável "Sexo" */
proc freq data=Dados_04.Enem_2024_Filtrado;
    title "Distribuição de Frequência - Sexo (Participantes CE com CH > 600)";
    tables tp_sexo / nocum plots=freqplot(scale=freq);
run;

/* Distribuição de frequência da variável "Cor e Raça" */
proc freq data=Dados_04.Enem_2024_Filtrado;
    title "Distribuição de Frequência - Cor e Raça (Participantes CE com CH > 600)";
    tables tp_cor_raca / nocum plots=freqplot(scale=freq orient=horizontal);
run;

/* Distribuição de frequência cruzada entre "Sexo" e "Cor e Raça" */
proc freq data=Dados_04.Enem_2024_Filtrado;
    title "Distribuição de Frequência Cruzada - Sexo por Cor e Raça";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    tables tp_sexo * tp_cor_raca / nocum;
run;

/* Tabela de percentuais por linha */
proc freq data=Dados_04.Enem_2024_Filtrado;
    title "Distribuição de Frequência Cruzada - Sexo por Cor e Raça (Percentuais)";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    tables tp_sexo * tp_cor_raca / nocum nofreq;
run;

/* Análise da distribuição da variável nota_media_5_notas */
proc univariate data=Dados_04.Enem_2024_Filtrado normal;
    title "Análise da Distribuição - Média das 5 Notas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    var nota_media_5_notas;
    histogram nota_media_5_notas / normal kernel;
    qqplot nota_media_5_notas / normal (mu=est sigma=est);
    inset mean std min max n / pos=ne;
run;

/* Análise da distribuição da variável Nota_Media_Exatas */
proc univariate data=Dados_04.Enem_2024_Filtrado normal;
    title "Análise da Distribuição - Média das Notas Exatas (Matemática + CN)";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    var Nota_Media_Exatas;
    histogram Nota_Media_Exatas / normal kernel;
    qqplot Nota_Media_Exatas / normal (mu=est sigma=est);
    inset mean std min max n / pos=ne;
run;

/* Análise da distribuição da variável nota_ch_ciencias_humanas */
proc univariate data=Dados_04.Enem_2024_Filtrado normal;
    title "Análise da Distribuição - Nota de Ciências Humanas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    var nota_ch_ciencias_humanas;
    histogram nota_ch_ciencias_humanas / normal kernel;
    qqplot nota_ch_ciencias_humanas / normal (mu=est sigma=est);
    inset mean std min max n / pos=ne;
run;

/* Estatísticas descritivas das três variáveis principais */
proc means data=Dados_04.Enem_2024_Filtrado n mean median std min max q1 q3 skew kurt;
    title "Estatísticas Descritivas - Principais Variáveis Numéricas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    var nota_media_5_notas Nota_Media_Exatas nota_ch_ciencias_humanas;
run;

/* Histogramas comparativos das três variáveis */
proc sgplot data=Dados_04.Enem_2024_Filtrado;
    title "Histograma - Média das 5 Notas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    histogram nota_media_5_notas / transparency=0.5;
    density nota_media_5_notas / type=normal;
    density nota_media_5_notas / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label="Média das 5 Notas";
    yaxis label="Densidade";
run;

proc sgplot data=Dados_04.Enem_2024_Filtrado;
    title "Histograma - Média das Notas Exatas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    histogram Nota_Media_Exatas / transparency=0.5;
    density Nota_Media_Exatas / type=normal;
    density Nota_Media_Exatas / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label="Média das Notas Exatas (Matemática + CN)";
    yaxis label="Densidade";
run;

proc sgplot data=Dados_04.Enem_2024_Filtrado;
    title "Histograma - Nota de Ciências Humanas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    histogram nota_ch_ciencias_humanas / transparency=0.5;
    density nota_ch_ciencias_humanas / type=normal;
    density nota_ch_ciencias_humanas / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label="Nota de Ciências Humanas";
    yaxis label="Densidade";
run;

/* Box Plot comparativo das variáveis numéricas */
data temp_melted_06;
    set Dados_04.Enem_2024_Filtrado;
    
    /* Transformar para formato longo para comparação */
    Variavel = "Media_5_Notas";
    Valor = nota_media_5_notas;
    if not missing(Valor) then output;
    
    Variavel = "Media_Exatas";
    Valor = Nota_Media_Exatas;
    if not missing(Valor) then output;
    
    Variavel = "Ciencias_Humanas";
    Valor = nota_ch_ciencias_humanas;
    if not missing(Valor) then output;
    
    keep Variavel Valor;
run;

proc sgplot data=temp_melted_06;
    title "Box Plot Comparativo - Principais Variáveis Numéricas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    vbox Valor / category=Variavel;
    xaxis label="Variável";
    yaxis label="Pontuação";
run;

/* Matriz de correlação entre as variáveis numéricas */
proc corr data=Dados_04.Enem_2024_Filtrado plots=matrix;
    title "Matriz de Correlação - Variáveis Numéricas";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    var nota_media_5_notas Nota_Media_Exatas nota_ch_ciencias_humanas 
        nota_mt_matematica nota_cn_ciencias_natureza nota_lc_linguagens_codigos nota_redacao;
run;

/* Análise por sexo das variáveis principais */
proc means data=Dados_04.Enem_2024_Filtrado n mean std;
    title "Estatísticas por Sexo - Principais Variáveis";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    class tp_sexo;
    var nota_media_5_notas Nota_Media_Exatas nota_ch_ciencias_humanas;
run;

/* Análise por cor/raça das variáveis principais */
proc means data=Dados_04.Enem_2024_Filtrado n mean std;
    title "Estatísticas por Cor/Raça - Principais Variáveis";
    title2 "Participantes do Ceará com Ciências Humanas > 600";
    class tp_cor_raca;
    var nota_media_5_notas Nota_Media_Exatas nota_ch_ciencias_humanas;
run;

/* Resumo final do dataset filtrado */
proc sql;
    title "Resumo Final do Dataset Filtrado - ENEM 2024 Ceará";
    select count(*) as Total_Participantes format=comma10.,
           count(distinct tp_sexo) as Total_Sexos,
           count(distinct tp_cor_raca) as Total_Cor_Raca,
           min(nota_ch_ciencias_humanas) as Min_CH format=8.0,
           max(nota_ch_ciencias_humanas) as Max_CH format=8.0,
           mean(nota_media_5_notas) as Media_Geral format=8.2,
           mean(Nota_Media_Exatas) as Media_Exatas format=8.2
    from Dados_04.Enem_2024_Filtrado;
quit;

/* Limpeza de datasets temporários */
proc datasets library=work nolist;
    delete temp_melted_06;
run;