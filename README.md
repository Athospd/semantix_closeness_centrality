# semantix_closeness_centrality
Web app que mostra a proximidade de um vértice ao centro de sua rede social ([Closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality)). 

## Instalação

```
install.packages(c("magrittr", "networkD3", "stringi", "shiny", "purrr", "tidyr", "plyr", "dplyr", "digest", "devtools"))
devtools::install_github("rstudio/shinydashboard")
```
## Como rodar

Abra o R e rode diretamente do github

```
shiny::runGitHub("semantix_closeness_centrality", "Athospd")
```

## Como usar

Carregue um arquivo texto de arestas, ou seja, com um par de vértices por linha: origem e destino.

Exemplo:
```
1 2
1 3
1 4
2 3
2 4
3 4
```

## Crétidos

Layout baseado no aplicativo [Crandash](https://github.com/rstudio/shiny-examples/tree/master/087-crandash).
