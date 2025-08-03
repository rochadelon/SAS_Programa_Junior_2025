# Let's create a comprehensive overview of all 10 programs based on the PDF requirements
# This will help structure our solution

program_requirements = {
    "Programa 01": {
        "title": "Importação de Dados no SAS Studio com a Proc Import",
        "tasks": [
            "Importar arquivo Enem_2024_Amostra_Perfeita.xlsx",
            "Importar arquivo SUS_PROD_AMB_2024_2025.csv com parâmetros específicos",
            "Criar Library Dados_04",
            "Aplicar Labels na tabela SUS_PROD_AMB_2024_2025"
        ],
        "key_parameters": {
            "encoding": "windows-1252",
            "delimiter": ";",
            "guessingrows": "MAX"
        }
    },
    "Programa 02": {
        "title": "Acesso ao Banco de Dados PostgreSQL do projeto Big Data – IESB",
        "tasks": [
            "Criar conexão com PostgreSQL",
            "Criar Library DataIESB",
            "Usar credenciais específicas fornecidas"
        ]
    },
    "Programa 03": {
        "title": "Exploração do arquivo censo_2022_municipio_sexo_idade",
        "tasks": [
            "Calcular população do Brasil",
            "Calcular população por Região",
            "Calcular população por UF",
            "Calcular população por Sexo",
            "Calcular população por Idade",
            "Calcular população por UF*Sexo",
            "Calcular população por UF*Sexo*Idade",
            "Construir gráfico por UF",
            "Construir Mapa do Brasil por Município",
            "Sugerir e construir mais 3 relatórios"
        ]
    },
    "Programa 04": {
        "title": "Exploração do arquivo Enem_2024_Amostra_Perfeita - Análise de Distribuição",
        "tasks": [
            "Análise da distribuição de 'Nota de Matemática' e 'Media das 5 notas'",
            "Incluir Histograma com Curva Normal",
            "Incluir Estimativa de Densidade",
            "Incluir todas as Estatísticas"
        ]
    },
    "Programa 05": {
        "title": "Exploração do arquivo ed_enem_2024_participantes",
        "tasks": [
            "Distribuição de Frequência com gráficos de barras para: UF, Faixa Etária, Sexo, Cor e Raça",
            "Distribuição de Frequência Cruzada para: UF por Sexo, Sexo por Cor e Raça, Cor e Raça por Faixa Etária"
        ]
    },
    "Programa 06": {
        "title": "Exploração filtrada do arquivo Enem_2024_Amostra_Perfeita",
        "tasks": [
            "Criar novo Dataset com filtros específicos (UF da faculdade e nota_ch > 600)",
            "Formatar variáveis",
            "Calcular Nota_Media_Exatas",
            "Selecionar variáveis específicas",
            "Fazer análises de distribuição do dataset filtrado"
        ]
    },
    "Programa 07": {
        "title": "Carga de dados e acesso ao projeto Big Data-IESB (SAS Workbench)",
        "tasks": [
            "Criar pastas Dados e Programas",
            "Upload e import de arquivo Excel",
            "Criar Libraries",
            "Executar Proc Contents para múltiplas tabelas"
        ]
    },
    "Programa 08": {
        "title": "Análise do ENEM 2024 - Visão Brasil",
        "tasks": [
            "Análise estatística usando ED_ENEM_2024_RESULTADOS e ED_ENEM_2024_PARTICIPANTES",
            "Visão Brasil, por UF, Sexo, Cor e Raça",
            "Medidas de resumo e gráficos apropriados"
        ]
    },
    "Programa 09": {
        "title": "Análise do ENEM 2024 - Visão por Estado",
        "tasks": [
            "Criar dataset filtrado por UF específica",
            "Análise estatística focada no estado selecionado",
            "Variáveis importantes para explicar resultados ENEM 2024"
        ]
    },
    "Programa 10": {
        "title": "Exportação de Resultados",
        "tasks": [
            "Exportar resultados para PDF",
            "Exportar para PowerPoint",
            "Exportar para Word",
            "Exportar para Excel",
            "Exportar para CSV (100 observações)"
        ]
    }
}

print("=== RESUMO DOS 10 PROGRAMAS SAS ===")
for prog_num, details in program_requirements.items():
    print(f"\n{prog_num}: {details['title']}")
    print("Tarefas principais:")
    for i, task in enumerate(details['tasks'], 1):
        print(f"  {i}. {task}")
    
    if 'key_parameters' in details:
        print("Parâmetros importantes:")
        for param, value in details['key_parameters'].items():
            print(f"  - {param}: {value}")

print("\n=== INFORMAÇÕES DO ESTUDANTE ===")
print("Nome: Alan Delon Sousa Rocha")
print("Instituição: Centro Universitário Farias Brito")
print("Caminho base dos dados: /export/viya/homes/2320048@aluno.fbuni.edu.br/SAS Programa Júnior/Dados_04")