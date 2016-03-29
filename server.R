function(input, output, session) {
  
  ultimo_input_de_dados_alterado <- reactiveValues(input = NULL)
  tempo_ini <- reactiveValues(tempo = NULL)
  
  observe({
    input$dados_de_exemplo
    ultimo_input_de_dados_alterado$input <- "dados_de_exemplo"
  })
  
  observe({
    input$carrega_arquivo
    ultimo_input_de_dados_alterado$input <- "dados_carregados"
  })
  
  observe({
    input$carrega_arquivo
    input$dados_de_exemplo
    tempo_ini$tempo <- Sys.time()
  })
  
  dados <- reactive({
    withProgress({
      if(ultimo_input_de_dados_alterado$input %in% "dados_de_exemplo") {
        readRDS("exemplos/edges.RDS")
      } else if(ultimo_input_de_dados_alterado$input %in% "dados_carregados") {
        arq_metadados <- input$carrega_arquivo %>% as.data.frame
        if(is.null(input$carrega_arquivo)) # verifica se algo foi carregado
          data.frame(V1 = "Carregue uma lista de arestas", V2 = "Carregue uma lista de arestas")
        else # caso tenha algo carregado...
          read.table(arq_metadados$datapath, sep = " ")
      } else 
        NULL
    }, message = "Lendo arquivo...")
  })
  
  lista_de_adjacencia <- reactive({
    withProgress({
      if(dados() %>% is.null %>% not)
        gera_lista_de_adjacencia(dados())
    }, message = "Gerando lista de adjadência...")
  })
  tabela_de_vertices <- reactive({
    withProgress({
      tempo_ini <- Sys.time()
      if(lista_de_adjacencia() %>% is.null %>% not) {
        bfs <- gera_funcao_bfs(lista_de_adjacencia())
        raiz <- names(lista_de_adjacencia())
        vertices <- data_frame(raiz = raiz,
                               distancia = map_dbl(raiz, bfs)) %>%
          mutate(centralidade_de_proximidade = 1/sum(distancia),
                 normalizada = round(100*(centralidade_de_proximidade - min(centralidade_de_proximidade))/(max(centralidade_de_proximidade) - min(centralidade_de_proximidade)), 1))
      }
    }, message = "Calculando centralidade de proximidade.",
    detail = "Por favor aguarde...")
  })
  
  tempo_de_execucao <- reactive({
    as.numeric(Sys.time() - tempo_ini$tempo, units = "secs") %>% round(3)
  })
  
  n_vertices <- reactive({
    tabela_de_vertices() %>% nrow
  })
  
  output$vertices <- renderValueBox({
    valueBox(
      value = n_vertices(),
      subtitle = "Vértices",
      icon = icon("angle-double-left"),
      color = "yellow"
    )
  })
  
  n_arestas <- reactive({
    if(dados() %>% is.null %>% not)
      dados() %>% nrow
    else "-"
  })
  
  output$arestas <- renderValueBox({
    valueBox(
      value = n_arestas(),
      subtitle = "Arestas",
      icon = icon("bars"),
      color = "purple"
    )
  })
  
  output$tempo_de_execucao <- renderValueBox({
    valueBox(
      value = paste(tempo_de_execucao(), "s"),
      subtitle = "Tempo de execução",
      icon = icon("clock-o")
    )
  })
  
  output$grafo <- renderSimpleNetwork({
      forceNetwork(Links = dados(), 
                   Nodes = tabela_de_vertices() %>% mutate(grupo = centralidade_de_proximidade %>% as.factor %>% as.numeric),
                   Source = "V1", 
                   Target = "V2", 
                   NodeID = "raiz",
                   Group = "grupo",
                   fontSize = 18, 
                   zoom = TRUE,
                   bounded = TRUE)
  })
  
  output$tabela_de_vertices <- renderDataTable({
    tabela_de_vertices()
  })
  
  output$baixar <- downloadHandler(
    filename = "closeness_centrality.csv",
    content = function(file) {
      write.csv2(tabela_de_vertices(), file, row.names = FALSE)
    },
    contentType = "text/csv"
  )
  
  output$dados_carregados <- renderPrint({
    if(input$maxlinhas %>% is.numeric && dados() %>% is.null %>% not) {
      print(head(dados(), input$maxlinhas))
    } else {
      print("")
    }
  })
}
