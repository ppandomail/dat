rm(list = ls())
gc()

library(data.table)
library(pbapply)
library(igraph)
library(htmlwidgets)
library(threejs)

# Asumo que estoy parado en la carpeta de legislativas
carpeta_legislativas <- "C:/00_dev/00_playground/04_TEACH/UNO/2025/clases/clase_03/legislativas"
setwd(carpeta_legislativas)
setwd("./diputados/02_puntos ideales/idps")

# Leo los archivos a utilizar
distancias_idps <- fread("distancias_idps.csv.gz")
legisladores_bloque_provincia <- fread("legisladores_bloque_provincia.csv")
# Cambio los nombres
setnames(distancias_idps,c("nombre1","nombre2","distancia"),c("Source","Target","weight"))
setwd("../../03_redes")
# Levanto el algoritmo para calcular influencia colectiva
source("collective_influence_algorithm.R")
# Vector de anios
anios <- sort(unique(legisladores_bloque_provincia$yr))

# Generar un objeto grafo por cada periodo, con atributos que luego usamos
grafos_por_periodo <- pblapply(anios,function(x){
  # Extraer las distancias para un periodo determinado
  distancias_periodo <- distancias_idps[anio == x]
  # Extraer los legisladores para el mismo periodo
  diputades_periodo <- legisladores_bloque_provincia[yr==x]
  # Despues de probar puntos de corte para borrar edges
  punto_corte <- 0.4
  # Genero el grafo desde el dataframe
  g <- graph_from_data_frame(vertices = diputades_periodo$legislador,
                             d = distancias_periodo[,.(Source,Target,weight)],directed = F)
  
  # Agrego atributos a los vertices
  V(g)$legislador <- diputades_periodo$legislador
  V(g)$bloque <- diputades_periodo$bloque
  V(g)$anio <- diputades_periodo$yr
  V(g)$betweenness <- betweenness(g,directed = F,normalized = T)
  # Aca las etiquetas
  g <- set.vertex.attribute(g,"label",
                            value = paste0("<b>",V(g)$name,"</b>","<br>",V(g)$bloque))
  
  gsimp <- simplify(g)
  # Borro los dedges que implican mas distancia que el punto de corte
  gsimp <- delete_edges(g, E(g)[weight > punto_corte])
  # Simplifico el grafo para evitar duplicados
  gsimp <- simplify(gsimp)
  
})

dir.create("grafos",showWarnings = FALSE)
setwd("grafos")

# Generar las comunidades, visualizaciones del grafo y subgrafos
pblapply(grafos_por_periodo,function(g){
  periodo <- V(g)$anio[1]
  path <- paste0("grafos_",periodo)
  dir.create(path)
  g <- delete.vertices(g,V(g)[degree(g)<3]) # Para que no queden nodos perdidos en el espacio
  x <- fastgreedy.community(g, weights = (1/E(g)$weight)) # Detectar comunidades
  i <- membership(x)
  g <- set.vertex.attribute(g,"color",value = rainbow(length(x))[i]) # Mapea las comunidades a colores
  lapply(1:length(x),function(i){ # Iterador para guardar los subgrafos y csv de las comunidades
    archivo_subgrafo <- paste0("subgrafo_",periodo,"_",i,".html")
    archivo_csv <- paste0("lista_",periodo,"_",i,".csv")
    gs <- as.undirected(subgraph(g, which(x$membership==i)))
    saveWidget(graphjs(gs), file = paste0(getwd(),"/",path,"/",archivo_subgrafo))
    write.table(V(gs)$label,paste0(getwd(),"/",path,"/",archivo_csv),row.names = F,sep = ",")
  })
  # La visualizacion de un grafo es muy dependiente del layout. Para encontrar una buena proyeccion
  # Genero k grafos, cada uno con un layout distinto para luego elegir.
  # Cada grafo queda guardado en una carpeta del periodo y esta numerado de acuerdo a k
  k <- 1
  lapply(1:k,function(i){ # Iterador para generar grafos con diferente layout
    archivo_grafo <- paste0("grafo_",i,".html")
    filepath <- paste0(getwd(),"/",path,"/",archivo_grafo)
    l <- layout_nicely(g,dim = 3) # Calcula un layout
    # Guarda el grafo generado por graphjs
    saveWidget(graphjs(g,layout = l,vertex.size = (V(g)$betweenness+1)),file =filepath)
  })
})



# Generar un objeto grafo por cada anio, con atributos que luego usamos
dataframes_grafos_pruned <- pblapply(anios,function(x){
  # Extraer las distancias para un anio determinado
  distancias_periodo <- distancias_idps[anio == x]
  # Extraer los legisladores para el mismo anio
  diputades_periodo <- legisladores_bloque_provincia[yr == x]
  # Despues de probar puntos de corte para borrar edges
  punto_corte <- 0.7
  # Genero el grafo desde el dataframe
  g <- graph_from_data_frame(vertices = diputades_periodo$legislador,
                             d = distancias_periodo[,.(Source,Target,weight)],directed = F)# Agrego atributos a los vertices
  V(g)$legislador <- diputades_periodo$legislador
  V(g)$bloque <- diputades_periodo$bloque
  V(g)$anio <- diputades_periodo$yr
  # Aca las etiquetas
  g <- set.vertex.attribute(g,"label",
                            value = paste0("<b>",V(g)$name,"</b>","<br>",V(g)$bloque))
  
  g <- simplify(g)
  # Borro los dedges que implican mas distancia que el punto de corte
  g <- delete_edges(g, E(g)[weight > punto_corte])
  # Simplifico el grafo para evitar duplicados
  g <- simplify(g)
  
  V(g)$degree<-degree(g)
  V(g)$betweenness <- betweenness(g,directed = F,normalized = T)
  V(g)$triangles<-count_triangles(g)
  V(g)$transitivity<-transitivity(g,type='local',isolates='zero')
  V(g)$pageRank<-page.rank(g,weights = (1/V(g)$weight))$vector
  V(g)$collective_influence <- collectiveInfluence(g,d=2)
  
  x <- fastgreedy.community(g, weights = (1/E(g)$weight)) # Detectar comunidades
  i <- membership(x)
  g <- set.vertex.attribute(g,"color",value = rainbow(length(x))[i])
  
  gdf_pruned <- igraph::as_data_frame(g,what = "vertices")
})

dataframes_grafos_pruned <- rbindlist(dataframes_grafos_pruned)

setwd("../")
fwrite(dataframes_grafos_pruned,"dataframes_grafos_pruned.csv")
saveRDS(grafos_por_periodo,"grafos_por_periodo.rds")
