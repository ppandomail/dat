# Script: Mapa Hexagonal Tipo Panal - Proximidad Legislativa
# Visualización donde todos los hexágonos están contiguos (sin espacios)
# La posición relativa indica proximidad, no distancia absoluta

rm(list = ls())
gc()

library(data.table)
library(ggplot2)
library(stringr)
library(MASS) # Para escalamiento multidimensional

# Asumo que estoy parado en la carpeta de legislativas
carpeta_legislativas <- "C:/00_dev/00_playground/04_TEACH/UNO/2025/clases/clase_03/legislativas"
setwd(carpeta_legislativas)

setwd("./diputados/03_redes")
dataset_analisis_redes <- fread("dataframes_grafos_pruned.csv")

setwd("../../diputados/02_puntos ideales/idps")
distancias_idps <- fread("distancias_idps.csv.gz")

# Definir los radicales con peluca
radicales_con_peluca <- dataset_analisis_redes[anio==2025 &
                                         str_detect(legislador, "CAMPERO|PICAT|ARJOL|CERVI|TOURNIER")]

# Filtrar los datos de LLA en 2025
lla_2025 <- dataset_analisis_redes[anio==2025 & bloque=="La Libertad Avanza"]

# Filtrar los datos de UCR en 2025 (excluyendo radicales con peluca)
ucr_2025 <- dataset_analisis_redes[anio==2025 & bloque=="Ucr - Union Civica Radical" & 
                               !legislador %in% radicales_con_peluca$legislador]

# ============================================================================
# PREPARACIÓN DE DATOS
# ============================================================================

# Seleccionar legisladores para el análisis
legisladores_rcp <- radicales_con_peluca$legislador
legisladores_lla <- lla_2025$legislador
legisladores_ucr <- ucr_2025$legislador

legisladores_seleccionados <- c(legisladores_rcp, legisladores_lla, legisladores_ucr)

# Simplificar nombres para etiquetas
nombres_cortos <- sapply(legisladores_seleccionados, function(x) str_extract(x, "^[^,]+"))

setnames(distancias_idps,c("nombre1","nombre2","distancia"),c("from","to","weight"))

# Crear matriz de distancias
if("from" %in% names(distancias_idps) && "to" %in% names(distancias_idps)) {
  matriz_distancias <- distancias_idps[
    from %in% legisladores_seleccionados & to %in% legisladores_seleccionados,
    .(from, to, weight)
  ]
} else if("Source" %in% names(distancias_idps) && "Target" %in% names(distancias_idps)) {
  matriz_distancias <- distancias_idps[
    Source %in% legisladores_seleccionados & Target %in% legisladores_seleccionados,
    .(Source, Target, weight)
  ]
  setnames(matriz_distancias, c("Source", "Target"), c("from", "to"))
} else {
  stop("No se encuentran las columnas esperadas en distancias_idps")
}

# Crear matriz simétrica completa
todos_legisladores <- unique(c(matriz_distancias$from, matriz_distancias$to))
n <- length(todos_legisladores)
matriz_sim <- matrix(Inf, n, n)
diag(matriz_sim) <- 0

for (i in 1:nrow(matriz_distancias)) {
  idx_from <- match(matriz_distancias$from[i], todos_legisladores)
  idx_to <- match(matriz_distancias$to[i], todos_legisladores)
  matriz_sim[idx_from, idx_to] <- matriz_sim[idx_to, idx_from] <- matriz_distancias$weight[i]
}

max_val <- max(matriz_sim[matriz_sim < Inf])
matriz_sim[matriz_sim == Inf] <- max_val * 1.5

# ============================================================================
# ALGORITMO DE POSICIONAMIENTO HEXAGONAL CONTIGUO
# ============================================================================

# Función para generar coordenadas hexagonales contiguas
generar_coordenadas_hexagonales <- function(n) {
  # Generar patrón de panal hexagonal
  coords <- data.frame(q = integer(), r = integer())
  
  # Calcular número de anillos necesarios
  anillos <- ceiling(sqrt(n))
  
  # Centro
  coords <- rbind(coords, data.frame(q = 0, r = 0))
  
  # Generar anillos concéntricos
  for (ring in 1:anillos) {
    for (i in 0:(ring-1)) {
      # 6 direcciones del hexágono
      coords <- rbind(coords, data.frame(q = ring - i, r = i))
      coords <- rbind(coords, data.frame(q = -i, r = ring))
      coords <- rbind(coords, data.frame(q = -ring, r = ring - i))
      coords <- rbind(coords, data.frame(q = -ring + i, r = -i))
      coords <- rbind(coords, data.frame(q = i, r = -ring))
      coords <- rbind(coords, data.frame(q = ring, r = -ring + i))
    }
  }
  
  # Eliminar duplicados y tomar solo los n necesarios
  coords <- unique(coords)
  coords <- coords[1:min(n, nrow(coords)), ]
  
  return(coords)
}

# Convertir coordenadas hexagonales (q,r) a cartesianas (x,y)
hex_to_pixel <- function(q, r, size = 1) {
  x <- size * (sqrt(3) * q + sqrt(3)/2 * r)
  y <- size * (3/2 * r)
  return(list(x = x, y = y))
}

# ============================================================================
# POSICIONAMIENTO BASADO EN MDS Y ASIGNACIÓN A HEXÁGONOS CONTIGUOS
# ============================================================================

# MDS para obtener orden de proximidad
set.seed(42)
mds <- isoMDS(matriz_sim, k=2)

coord_mds <- data.frame(
  legislador = todos_legisladores,
  x_mds = mds$points[,1],
  y_mds = mds$points[,2]
)

# Generar coordenadas hexagonales contiguas
hex_coords <- generar_coordenadas_hexagonales(n)

# Algoritmo greedy para asignar legisladores a posiciones hexagonales
# Comenzar desde el centro y expandir asignando los más cercanos
asignar_hexagonos_contiguos <- function(coord_mds, hex_coords, matriz_dist) {
  n <- nrow(coord_mds)
  asignados <- rep(FALSE, n)
  asignaciones <- data.frame(
    legislador = character(n),
    q = integer(n),
    r = integer(n),
    orden = integer(n),
    stringsAsFactors = FALSE
  )
  
  # Comenzar con el legislador más central (menor distancia promedio a todos)
  dist_promedio <- rowMeans(matriz_dist)
  idx_inicial <- which.min(dist_promedio)
  
  # Asignar al centro
  asignaciones[1, ] <- list(coord_mds$legislador[idx_inicial], 0, 0, 1)
  asignados[idx_inicial] <- TRUE
  
  # Expandir en espiral
  for (i in 2:n) {
    # Buscar el no asignado más cercano a algún asignado
    mejor_idx <- NA
    mejor_dist <- Inf
    
    for (j in which(!asignados)) {
      # Distancia mínima a cualquier ya asignado
      dist_min <- min(matriz_dist[j, which(asignados)])
      if (dist_min < mejor_dist) {
        mejor_dist <- dist_min
        mejor_idx <- j
      }
    }
    
    # Asignar a la siguiente posición hexagonal
    asignaciones[i, ] <- list(
      coord_mds$legislador[mejor_idx],
      hex_coords$q[i],
      hex_coords$r[i],
      i
    )
    asignados[mejor_idx] <- TRUE
  }
  
  return(asignaciones)
}

# Asignar legisladores a hexágonos
asignaciones <- asignar_hexagonos_contiguos(coord_mds, hex_coords, matriz_sim)

# Convertir coordenadas hexagonales a cartesianas
size_hex <- 1.5  # Tamaño de los hexágonos (AJUSTABLE)
pixel_coords <- hex_to_pixel(asignaciones$q, asignaciones$r, size_hex)

coord_final <- data.frame(
  legislador = asignaciones$legislador,
  x = pixel_coords$x,
  y = pixel_coords$y,
  q = asignaciones$q,
  r = asignaciones$r
)

# Añadir información de grupo
coord_final$grupo <- ifelse(coord_final$legislador %in% legisladores_rcp, "RCP",
                            ifelse(coord_final$legislador %in% legisladores_lla, "LLA", "UCR"))

# Añadir nombres cortos
idx_match <- match(coord_final$legislador, legisladores_seleccionados)
coord_final$nombre_corto <- nombres_cortos[idx_match]

# Insertar salto de línea cuando el apellido tiene un espacio
coord_final$nombre_corto <- sapply(coord_final$nombre_corto, function(nombre) {
  # Si el nombre tiene un espacio, reemplazar el primer espacio con salto de línea
  if (grepl(" ", nombre)) {
    return(sub(" ", "\n", nombre))
  } else {
    return(nombre)
  }
})

# ============================================================================
# AGREGAR INFORMACIÓN DE COLORES/COMUNIDADES DESDE EL DATASET
# ============================================================================

# Obtener colores del dataset (asumiendo que existe columna 'color')
setwd(carpeta_legislativas)
setwd("./diputados/03_redes")

if ("color" %in% names(dataset_analisis_redes)) {
  # Crear lookup table de legislador -> color
  color_lookup <- dataset_analisis_redes[legislador %in% coord_final$legislador, 
                                          .(legislador, color)]
  # Eliminar duplicados si existen
  color_lookup <- unique(color_lookup)
  
  # Agregar color a coord_final
  coord_final <- merge(coord_final, color_lookup, by = "legislador", all.x = TRUE)
  
  cat("Colores de comunidad agregados correctamente\n")
  cat("Número de comunidades diferentes:", length(unique(coord_final$color)), "\n")
} else {
  warning("No se encontró la columna 'color' en el dataset")
  coord_final$color <- "#CCCCCC"  # Color por defecto si no existe
}

# ============================================================================
# CREAR HEXÁGONOS PARA VISUALIZACIÓN
# ============================================================================

# Función para crear polígono hexagonal
crear_hexagono <- function(x, y, tamaño = 1) {
  angulos <- seq(0, 2*pi, length.out = 7) + pi/6  # +pi/6 para orientación flat-top
  hex_x <- x + tamaño * cos(angulos)
  hex_y <- y + tamaño * sin(angulos)
  return(data.frame(x = hex_x, y = hex_y))
}

# Crear hexágonos para cada legislador (con info de grupo)
hexagonos_grupo <- data.frame()
for (i in 1:nrow(coord_final)) {
  hex <- crear_hexagono(coord_final$x[i], coord_final$y[i], size_hex * 0.95)
  hex$id <- i
  hex$grupo <- coord_final$grupo[i]
  hex$nombre <- coord_final$nombre_corto[i]
  hex$legislador <- coord_final$legislador[i]
  hexagonos_grupo <- rbind(hexagonos_grupo, hex)
}

# Crear hexágonos para cada legislador (con info de color/comunidad)
hexagonos_comunidad <- data.frame()
for (i in 1:nrow(coord_final)) {
  hex <- crear_hexagono(coord_final$x[i], coord_final$y[i], size_hex * 0.95)
  hex$id <- i
  hex$color_comunidad <- coord_final$color[i]
  hex$nombre <- coord_final$nombre_corto[i]
  hex$legislador <- coord_final$legislador[i]
  hexagonos_comunidad <- rbind(hexagonos_comunidad, hex)
}

# ============================================================================
# VISUALIZACIÓN 1: MAPA HEXAGONAL POR GRUPO (RCP, LLA, UCR)
# ============================================================================

p_panal_grupo <- ggplot() +
  geom_polygon(data = hexagonos_grupo, 
               aes(x = x, y = y, group = id, fill = grupo),
               color = "white", linewidth = 2, alpha = 0.85) +
  geom_text(data = coord_final, 
            aes(x = x, y = y, label = nombre_corto),
            size = 3.5, fontface = "bold", color = "black") +
  scale_fill_manual(values = c("RCP" = "orange", 
                               "LLA" = "skyblue3", 
                               "UCR" = "steelblue4"),
                    name = "Grupo") +
  coord_equal() +
  theme_void() +
  labs(title = "Mapa Hexagonal de Proximidad Legislativa - Por Grupo",
       subtitle = "Legisladores adyacentes tienen mayor afinidad en votaciones") +
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 13),
        legend.position = "right",
        legend.title = element_text(size = 13, face = "bold"),
        legend.text = element_text(size = 11),
        plot.margin = margin(20, 20, 20, 20))

# ============================================================================
# VISUALIZACIÓN 2: MAPA HEXAGONAL POR COMUNIDAD (COLORES DEL DATASET)
# ============================================================================

# Obtener colores únicos para la leyenda
colores_unicos <- unique(coord_final$color)
nombres_colores <- setNames(colores_unicos, colores_unicos)

p_panal_comunidad <- ggplot() +
  geom_polygon(data = hexagonos_comunidad, 
               aes(x = x, y = y, group = id, fill = color_comunidad),
               color = "white", linewidth = 2, alpha = 0.85) +
  geom_text(data = coord_final, 
            aes(x = x, y = y, label = nombre_corto),
            size = 3.5, fontface = "bold", color = "black") +
  scale_fill_identity() +  # Usar los colores hexadecimales directamente
  coord_equal() +
  theme_void() +
  labs(title = "Mapa Hexagonal de Proximidad Legislativa - Por Comunidad",
       subtitle = "Colores representan comunidades detectadas algorítmicamente") +
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 13),
        legend.position = "none",  # Sin leyenda porque los colores son directos
        plot.margin = margin(20, 20, 20, 20))

# ============================================================================
# GUARDAR VISUALIZACIONES
# ============================================================================
setwd(carpeta_legislativas)

# Guardar PDF con ambas visualizaciones
pdf("mapa_hexagonal_panal.pdf", width = 16, height = 12)
print(p_panal_grupo)
print(p_panal_comunidad)
dev.off()

# Guardar PNG de alta resolución - Por Grupo
png("mapa_hexagonal_panal_grupo.png", width = 1600, height = 1200, res = 120)
print(p_panal_grupo)
dev.off()

# Guardar PNG de alta resolución - Por Comunidad
png("mapa_hexagonal_panal_comunidad.png", width = 1600, height = 1200, res = 120)
print(p_panal_comunidad)
dev.off()

cat("\n====================================\n")
cat("Visualización tipo PANAL generada!\n")
cat("====================================\n")
cat("Archivos creados:\n")
cat("- mapa_hexagonal_panal.pdf (ambas visualizaciones)\n")
cat("- mapa_hexagonal_panal_grupo.png\n")
cat("- mapa_hexagonal_panal_comunidad.png\n")
cat("====================================\n")
cat("Total de legisladores:", nrow(coord_final), "\n")
cat("Número de comunidades:", length(unique(coord_final$color)), "\n")
cat("====================================\n\n")
