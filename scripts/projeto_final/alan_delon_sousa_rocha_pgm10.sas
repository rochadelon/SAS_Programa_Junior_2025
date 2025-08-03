/*
 * Programa: alan_delon_sousa_rocha_pgm10.sas
 * Autor: Alan Delon Sousa Rocha
 * Instituição: Centro Universitário Farias Brito
 * Descrição: Exportação de Resultados do ENEM 2024
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

/* Criação do dataset de resultados interessantes para exportação */
proc sql;
    create table resultados_exportacao as
    select p.nu_inscricao,
           p.no_uf_prova,
           p.no_municipio_prova,
           p.tp_sexo,
           p.tp_cor_raca,
           p.tp_faixa_etaria,
           p.tp_ensino,
           p.tp_escola,
           r.nu_nota_cn,
           r.nu_nota_ch,
           r.nu_nota_lc,
           r.nu_nota_mt,
           r.nu_nota_redacao,
           /* Calcular média das 5 notas */
           case when r.nu_nota_cn is not null and 
                     r.nu_nota_ch is not null and 
                     r.nu_nota_lc is not null and 
                     r.nu_nota_mt is not null and 
                     r.nu_nota_redacao is not null
                then (r.nu_nota_cn + r.nu_nota_ch + r.nu_nota_lc + r.nu_nota_mt + r.nu_nota_redacao) / 5
                else . end as media_5_notas,
           /* Classificação de desempenho */
           case when calculated media_5_notas >= 700 then 'Excelente'
                when calculated media_5_notas >= 600 then 'Bom'
                when calculated media_5_notas >= 500 then 'Regular'
                when calculated media_5_notas >= 400 then 'Insuficiente'
                else 'Muito Baixo' end as classificacao_desempenho
    from DataIesb.ED_ENEM_2024_PARTICIPANTES p
    inner join DataIesb.ED_ENEM_2024_RESULTADOS r
    on p.nu_inscricao = r.nu_inscricao
    where p.no_uf_prova in ('Ceará', 'São Paulo', 'Rio de Janeiro', 'Minas Gerais', 'Bahia')
    and r.nu_nota_cn is not null and 
        r.nu_nota_ch is not null and 
        r.nu_nota_lc is not null and 
        r.nu_nota_mt is not null and 
        r.nu_nota_redacao is not null
    order by media_5_notas desc;
quit;

/* Criar tabela de estatísticas por UF para exportação */
proc sql;
    create table estatisticas_uf as
    select no_uf_prova as UF,
           count(*) as Total_Participantes,
           mean(nu_nota_cn) as Media_CN format=8.2,
           mean(nu_nota_ch) as Media_CH format=8.2,
           mean(nu_nota_lc) as Media_LC format=8.2,
           mean(nu_nota_mt) as Media_MT format=8.2,
           mean(nu_nota_redacao) as Media_Redacao format=8.2,
           mean(media_5_notas) as Media_Geral format=8.2,
           std(media_5_notas) as Desvio_Padrao format=8.2,
           min(media_5_notas) as Minimo format=8.2,
           max(media_5_notas) as Maximo format=8.2
    from resultados_exportacao
    group by no_uf_prova
    order by Media_Geral desc;
quit;

/* 6.4.1 Exportação dos resultados para diferentes formatos */

/* a) Exportação para PDF */
ods pdf file="/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/Relatorio_ENEM_2024.pdf" 
        style=HTMLBlue;

proc print data=estatisticas_uf noobs;
    title "ENEM 2024 - Estatísticas por Unidade da Federação";
    title2 "Relatório Exportado em PDF";
    title3 "Autor: Alan Delon Sousa Rocha - Centro Universitário Farias Brito";
    var UF Total_Participantes Media_CN Media_CH Media_LC Media_MT Media_Redacao Media_Geral Desvio_Padrao;
run;

/* Gráfico das médias por UF */
proc sgplot data=estatisticas_uf;
    title "Médias Gerais por UF - ENEM 2024";
    vbar UF / response=Media_Geral datalabel;
    xaxis label="Unidade da Federação";
    yaxis label="Média Geral" grid;
run;

/* Distribuição de classificações de desempenho */
proc freq data=resultados_exportacao;
    title "Distribuição de Classificações de Desempenho";
    tables classificacao_desempenho / plots=freqplot;
run;

/* Top 20 melhores desempenhos */
proc print data=resultados_exportacao (obs=20) noobs;
    title "Top 20 Melhores Desempenhos - ENEM 2024";
    var nu_inscricao no_uf_prova no_municipio_prova tp_sexo tp_cor_raca 
        nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao media_5_notas classificacao_desempenho;
run;

ods pdf close;

/* b) Exportação para PowerPoint */
ods powerpoint file="/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/Apresentacao_ENEM_2024.pptx" 
               style=PowerPointLight;

proc print data=estatisticas_uf noobs;
    title "ENEM 2024 - Estatísticas por UF";
    title2 "Apresentação PowerPoint";
    title3 "Centro Universitário Farias Brito";
run;

proc sgplot data=estatisticas_uf;
    title "Comparação das Médias Gerais por UF";
    vbar UF / response=Media_Geral datalabel;
    xaxis label="UF";
    yaxis label="Média Geral";
run;

/* Análise por sexo */
proc sql;
    create table analise_sexo as
    select tp_sexo,
           count(*) as Participantes,
           mean(media_5_notas) as Media_Geral format=8.2
    from resultados_exportacao
    where tp_sexo is not null
    group by tp_sexo;
quit;

proc sgplot data=analise_sexo;
    title "Desempenho por Sexo - ENEM 2024";
    vbar tp_sexo / response=Media_Geral datalabel;
    xaxis label="Sexo";
    yaxis label="Média Geral";
run;

ods powerpoint close;

/* c) Exportação para Word */
ods word file="/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/Documento_ENEM_2024.docx" 
         style=Journal;

proc print data=estatisticas_uf noobs;
    title "Relatório ENEM 2024 - Análise por Unidade da Federação";
    title2 "Documento Word";
    title3 "Elaborado por: Alan Delon Sousa Rocha";
    title4 "Instituição: Centro Universitário Farias Brito";
run;

/* Análise detalhada por tipo de ensino */
proc sql;
    create table analise_ensino as
    select tp_ensino,
           count(*) as Participantes,
           mean(media_5_notas) as Media_Geral format=8.2,
           std(media_5_notas) as Desvio_Padrao format=8.2
    from resultados_exportacao
    where tp_ensino is not null
    group by tp_ensino
    order by Media_Geral desc;
quit;

proc print data=analise_ensino noobs;
    title "Análise por Tipo de Ensino";
run;

/* Correlações entre áreas */
proc corr data=resultados_exportacao;
    title "Correlações entre Áreas de Conhecimento";
    var nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao;
run;

ods word close;

/* d) Exportação para Excel */
ods excel file="/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/Planilha_ENEM_2024.xlsx" 
          options(sheet_name="Estatisticas_UF");

proc print data=estatisticas_uf noobs;
    title "ENEM 2024 - Estatísticas por UF";
run;

ods excel options(sheet_name="Analise_Sexo");
proc print data=analise_sexo noobs;
    title "Análise por Sexo";
run;

ods excel options(sheet_name="Analise_Ensino");
proc print data=analise_ensino noobs;
    title "Análise por Tipo de Ensino";
run;

ods excel options(sheet_name="Top_100_Participantes");
proc print data=resultados_exportacao (obs=100) noobs;
    title "Top 100 Participantes";
    var nu_inscricao no_uf_prova no_municipio_prova tp_sexo tp_cor_raca tp_ensino
        nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao media_5_notas classificacao_desempenho;
run;

ods excel close;

/* e) Exportação para CSV (100 observações do arquivo selecionado) */
proc export data=resultados_exportacao (obs=100)
    outfile="/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/ENEM_2024_Top100.csv"
    dbms=csv
    replace;
run;

/* Exportação adicional - Estatísticas por UF em CSV */
proc export data=estatisticas_uf
    outfile="/export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04/Estatisticas_UF_ENEM_2024.csv"
    dbms=csv
    replace;
run;

/* Criar um relatório final de exportação */
proc sql;
    title "Resumo das Exportações Realizadas";
    select 'PDF' as Formato, 
           'Relatorio_ENEM_2024.pdf' as Arquivo,
           'Relatório completo com gráficos e tabelas' as Descricao
    union
    select 'PowerPoint' as Formato, 
           'Apresentacao_ENEM_2024.pptx' as Arquivo,
           'Apresentação com gráficos principais' as Descricao
    union
    select 'Word' as Formato, 
           'Documento_ENEM_2024.docx' as Arquivo,
           'Documento com análises detalhadas' as Descricao
    union
    select 'Excel' as Formato, 
           'Planilha_ENEM_2024.xlsx' as Arquivo,
           'Planilha com múltiplas abas de dados' as Descricao
    union
    select 'CSV' as Formato, 
           'ENEM_2024_Top100.csv' as Arquivo,
           'Top 100 participantes em formato CSV' as Descricao
    union
    select 'CSV' as Formato, 
           'Estatisticas_UF_ENEM_2024.csv' as Arquivo,
           'Estatísticas por UF em formato CSV' as Descricao;
quit;

/* Verificação dos arquivos exportados */
proc print data=resultados_exportacao (obs=10) noobs;
    title "Verificação Final - Amostra dos Dados Exportados";
    title2 "Primeiras 10 observações do dataset principal";
    var nu_inscricao no_uf_prova tp_sexo nu_nota_cn nu_nota_ch nu_nota_lc nu_nota_mt nu_nota_redacao media_5_notas classificacao_desempenho;
run;

/* Estatísticas finais dos dados exportados */
proc sql;
    title "Estatísticas Finais dos Dados Exportados";
    select count(*) as Total_Registros_Exportados format=comma10.,
           count(distinct no_uf_prova) as UFs_Incluidas,
           mean(media_5_notas) as Media_Geral_Exportacao format=8.2,
           min(media_5_notas) as Menor_Media format=8.2,
           max(media_5_notas) as Maior_Media format=8.2
    from resultados_exportacao;
quit;

/* Mensagem final */
data _null_;
    put "===============================================";
    put "EXPORTAÇÕES CONCLUÍDAS COM SUCESSO!";
    put "===============================================";
    put "Autor: Alan Delon Sousa Rocha";
    put "Instituição: Centro Universitário Farias Brito";
    put "Data: 03/08/2025";
    put "===============================================";
    put "Arquivos gerados:";
    put "1. Relatorio_ENEM_2024.pdf";
    put "2. Apresentacao_ENEM_2024.pptx";
    put "3. Documento_ENEM_2024.docx";
    put "4. Planilha_ENEM_2024.xlsx";
    put "5. ENEM_2024_Top100.csv";
    put "6. Estatisticas_UF_ENEM_2024.csv";
    put "===============================================";
run;

/* Limpeza de datasets temporários */
proc datasets library=work nolist;
    delete resultados_exportacao estatisticas_uf analise_sexo analise_ensino;
run;