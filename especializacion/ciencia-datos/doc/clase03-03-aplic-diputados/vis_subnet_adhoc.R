library(data.table)
library(igraph)
library(htmlwidgets)
library(threejs)
library(tidyverse)

library(visNetwork)

setwd("C:/00_dev/00_playground/04_TEACH/UNO/2025/clases/clase_03/legislativas/diputados/03_redes")

diputados <- fread("dataframes_grafos_pruned.csv")
diputados_2025 <- diputados[anio==2025 & !str_detect(legislador,"MARZ")]
bloque_interes <- diputados_2025[bloque=="Union Por La Patria"]

comunidades_interes <- diputados_2025[color %in% unique(bloque_interes$color)]

distancias <- fread("../02_puntos ideales/idps/distancias_idps.csv.gz")
distancias_2025 <- distancias[anio==2025]
distancias_2025_ci <- distancias_2025[nombre1 %in% comunidades_interes$legislador & nombre2 %in% comunidades_interes$legislador]

legisladores_bloque_provincia <- fread("../02_puntos ideales/idps/legisladores_bloque_provincia.csv")
legisladores_bloque_provincia_2025 <- legisladores_bloque_provincia[yr==2025]

comunidades_interes <- comunidades_interes[legisladores_bloque_provincia_2025[,.(legislador,provincia)],on=.(legislador),nomatch = 0]

# Primero define la función
primer_apellido <- function(nombre_completo) {
  # Dividir por la coma
  partes <- strsplit(nombre_completo, ", ")[[1]]
  # Obtener la parte del apellido (la primera parte)
  apellidos <- partes[1]
  # Dividir los apellidos por espacio y tomar el primero
  primer_ap <- strsplit(apellidos, " ")[[1]][1]
  return(primer_ap)
}

# Luego aplícala correctamente dentro de data.table
comunidades_interes[, primer_apellido := sapply(legislador, primer_apellido)]

# Corrección en la creación del grafo
g <- graph_from_data_frame(d = distancias_2025_ci[,.(nombre1,nombre2,distancia)],
                           vertices = data.frame(name = comunidades_interes$legislador),
                           directed = FALSE)

# Agrego atributos a los vertices
V(g)$legislador <- comunidades_interes$legislador
V(g)$apellido <- comunidades_interes$primer_apellido
V(g)$bloque <- comunidades_interes$bloque
V(g)$betweenness <- comunidades_interes$betweenness
V(g)$ci <- comunidades_interes$collective_influence
V(g)$provincia <-  comunidades_interes$provincia
V(g)$color <-  comunidades_interes$color
# Aca las etiquetas
g <- set_vertex_attr(g,"label",
                     value = paste0(V(g)$apellido))

punto_corte <- 0.4
g <- delete_edges(g, E(g)[distancia > punto_corte])

g <- simplify(g)

# Visualizar el grafo con los colores directamente
plot(g, 
     vertex.color = V(g)$color,  # Usar directamente los colores asignados
     vertex.size = 15,
     vertex.label.cex = 0.8,
     vertex.label.dist = 0,
     edge.arrow.size = 0.5,
     main = "Grafo con nodos coloreados por comunidad")

# 1. Layout Fruchterman-Reingold con más iteraciones y área
layout_fr <- layout_with_fr(g, niter = 500, area = vcount(g)^2.5)

# 2. O layout Kamada-Kawai 
layout_kk <- layout_with_kk(g, kkconst = vcount(g))

# 3. O layout DrL (mejor para grafos grandes)
layout_drl <- layout_with_drl(g)

# Visualizar con el layout elegido
plot(g, 
     layout = layout_drl,  # Puedes cambiar a layout_kk o layout_drl para comparar
     vertex.color = V(g)$color,
     vertex.size = 10,    # Reducir un poco el tamaño de los nodos
     vertex.label.cex = 0.6,  # Reducir el tamaño de las etiquetas
     vertex.label.dist = 0.7, # Aumentar distancia de etiquetas respecto al nodo
     edge.width = 0.5,    # Líneas más delgadas
     edge.color = "lightgray", # Color más claro para las aristas
     vertex.label.color = "black", # Color de las etiquetas
     margin = c(0, 0, 0, 0), # Reducir márgenes
     main = "Grafo con nodos coloreados por comunidad")



# Configuración más avanzada
par(mar = c(1, 1, 2, 1)) # Reducir los márgenes
plot(g, 
     layout = layout_with_fr(g, niter = 1000, area = vcount(g)^3, repulserad = vcount(g)^3),
     vertex.color = V(g)$color,
     vertex.size = 8,
     vertex.label.cex = 0.5,
     vertex.label.dist = 1.2,
     vertex.label.color = "black",
     vertex.label.family = "sans",
     vertex.frame.color = NA, # Sin borde en los nodos
     edge.color = rgb(0.5, 0.5, 0.5, 0.2), # Aristas semi-transparentes
     edge.curved = 0.1, # Ligera curvatura en las aristas
     main = "Grafo con nodos coloreados por comunidad")
###############################3
l <- layout_nicely(g,dim = 3) # Calcula un layout
# Guarda el grafo generado por graphjs
saveWidget(graphjs(g,layout = l,vertex.size = (V(g)$betweenness+1)),file ="comunidad_uplp.html")
