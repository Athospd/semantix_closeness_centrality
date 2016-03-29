dashboardPage(
  dashboardHeader(title = "Closeness Centrality"),
  dashboardSidebar(
    fileInput("carrega_arquivo", "Carregar lista de arestas",
              multiple = FALSE),
    div(strong("OU"), class = "shiny-input-container", style = "margin-top: -30px;text-align: center;"),
    div(actionButton("dados_de_exemplo", "Exemplo", class = "shiny-input-container", style = "padding: 10px 10px;"), class = "shiny-input-container", style = "padding: 10px 5px"),
    sidebarMenu(
      menuItem("Resultado", tabName = "resultado", icon = icon("share-alt")),
      menuItem("Dados", tabName = "dados", icon = icon("database")),
      menuItem("Sobre", tabName = "sobre", icon = icon("info-circle")),
      div(downloadButton("baixar", label = "Baixar Resultado (CSV)"), class = "shiny-input-container", style = "padding-bottom: 10px; text-align: center;")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem("resultado",
        fluidRow(
          valueBoxOutput("vertices"),
          valueBoxOutput("arestas"),
          valueBoxOutput("tempo_de_execucao")
        ),
        fluidRow(
          box(width = 6, status = "info", solidHeader = TRUE,
            title = "Grafo",
            forceNetworkOutput("grafo")
          ),
          box(width = 6, status = "info", solidHeader = TRUE,
            title = "Tabela de Vértices",
            dataTableOutput("tabela_de_vertices")
          )
        )
      ),
      tabItem("dados",
              numericInput("maxlinhas", "Linhas para mostrar", 25),
              verbatimTextOutput("dados_carregados")
      ),
      tabItem("sobre",
              includeMarkdown("sobre.md")
      )
    )
  )
)
