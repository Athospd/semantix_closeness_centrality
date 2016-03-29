library(magrittr)
library(networkD3)
library(stringi)
library(shiny)
library(purrr)
library(tidyr)
library(plyr)
library(dplyr)
library(shinydashboard)

options(dplyr.show_progress = FALSE)

#------------------------------------------------------------------#
# transforma um vetor factor em character 
factor_para_character <- function(x) {
  if(x %>% class %in% "factor")
    x %<>% as.character
  return(x)
}

#------------------------------------------------------------------#
# Cria lista de adjacencia a partir de uma base de arestas 
gera_lista_de_adjacencia <- function(bd_de_arestas) {
  bd_de_arestas %<>% mutate_each(funs(factor_para_character))
  
  names(bd_de_arestas)[1:2] <- c("V1", "V2")
  vertices <- bd_de_arestas %$% dplyr::union(V1, V2) %>% as.character
  
  v1 <- bd_de_arestas %>% dlply(.(V1), function(df) {c(df$V2)})
  v2 <- bd_de_arestas %>% dlply(.(V2), function(df) {c(df$V1)})
  
  lista_de_adjacencias <- mapply(union, v1[vertices], v2[vertices], 
                                SIMPLIFY = FALSE) %>% setNames(vertices)
  
  return(lista_de_adjacencias)
}

#------------------------------------------------------------------#
# tira o vértice 'vertice_a_retirar' da fila de vértices que ainda
# precisam ser visitados
tira_da_fila <- function(fila_de_vertices_a_visitar, vertice_a_retirar) {
  fila_de_vertices_a_visitar[(fila_de_vertices_a_visitar %in% vertice_a_retirar) %>% not]
}

#------------------------------------------------------------------#
# coloca o vértice v na fila de vértices que ainda
# precisam ser visitados
coloca_na_fila <- function(fila_de_vertices_a_visitar, vertice_a_colocar) {
  fila_de_vertices_a_visitar %<>% c(vertice_a_colocar) %>% unique
}

# -----------------------------------------------------------------#
# Cria uma função Breadth-first Search (BFS) específica para uma 
# lista de adjacencia (ver 'gera_lista_de_adjacencia()')
gera_funcao_bfs <- function(lista_de_adjacencias) {
  bfs <- function(v) {
    resultado <- lista_de_adjacencias %>% map(~Inf)
    
    vertice_atual <- v
    
    resultado[[vertice_atual]] <- 0
    
    vertices_a_visitar <- vertice_atual
    while(vertices_a_visitar %>% length != 0) {
      
      vertice_atual <- vertices_a_visitar %>% first
      vertices_a_visitar %<>% tira_da_fila(vertice_atual)
      
      for(vertice_adjacente in lista_de_adjacencias[[vertice_atual]] %>% as.character) {
        if(resultado[[vertice_adjacente]] %>% is.infinite) {
          resultado[[vertice_adjacente]] <- resultado[[vertice_atual]] + 1
          vertices_a_visitar %<>% coloca_na_fila(vertice_adjacente)
        }
      }
    }
    return(invoke(sum, resultado))
  }
  return(bfs)
}


