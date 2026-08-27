# =========================================================================
# Script para generar dataset de benchmark
# Curso: Aplicaciones de Ciencia de Datos - UNO 2025
# Propósito: Crear dataset sintético grande para demostrar diferencias
#            en velocidad de importación entre R base, tidyverse y data.table
# =========================================================================

# Cargar librerías necesarias
library(data.table)

# =========================================================================
# CONFIGURACIÓN DEL DATASET
# =========================================================================

# Tamaño del dataset (ajustar según necesidad)
n_filas <- 1000000  # 1 millón de filas (ajustar a 5M o 10M para más diferencias)

# Establecer semilla para reproducibilidad
set.seed(42)

cat("Generando dataset de", format(n_filas, big.mark = ","), "filas...\n")
cat("Esto puede tomar 1-2 minutos dependiendo de tu computadora.\n\n")

# =========================================================================
# GENERAR DATOS SINTÉTICOS REALISTAS
# =========================================================================

# Vectores de valores posibles (para hacer datos realistas)
nombres <- c("Ana", "Juan", "María", "Carlos", "Laura", "Pedro", "Sofía", 
             "Diego", "Valentina", "Martín", "Camila", "Lucas", "Lucía", 
             "Mateo", "Victoria", "Santiago", "Catalina", "Nicolás")

apellidos <- c("García", "Rodríguez", "González", "Fernández", "López", 
               "Martínez", "Sánchez", "Pérez", "Gómez", "Martín", "Jiménez",
               "Ruiz", "Hernández", "Díaz", "Moreno", "Muñoz", "Álvarez")

ciudades <- c("Buenos Aires", "Córdoba", "Rosario", "Mendoza", "La Plata",
              "San Miguel de Tucumán", "Mar del Plata", "Salta", "Santa Fe",
              "San Juan", "Resistencia", "Neuquén", "Posadas", "Bahía Blanca")

regiones <- c("Centro", "NOA", "NEA", "Cuyo", "Patagonia", "AMBA")

categorias <- c("Electrónica", "Ropa", "Alimentos", "Hogar", "Deportes",
                "Libros", "Juguetes", "Salud", "Automotor", "Muebles")

estados <- c("Activo", "Inactivo", "Pendiente", "Completado", "Cancelado")

# =========================================================================
# CREAR DATASET
# =========================================================================

cat("Paso 1/5: Generando IDs y nombres...\n")
datos <- data.table(
  id = 1:n_filas,
  nombre = paste(
    sample(nombres, n_filas, replace = TRUE),
    sample(apellidos, n_filas, replace = TRUE)
  )
)

cat("Paso 2/5: Generando ubicación y demografía...\n")
datos[, `:=`(
  edad = sample(18:80, n_filas, replace = TRUE),
  ciudad = sample(ciudades, n_filas, replace = TRUE),
  region = sample(regiones, n_filas, replace = TRUE)
)]

cat("Paso 3/5: Generando fechas y categorías...\n")
# Fechas entre 2023-01-01 y 2024-12-31
fechas_inicio <- as.Date("2023-01-01")
fechas_fin <- as.Date("2024-12-31")
datos[, fecha := sample(seq(fechas_inicio, fechas_fin, by = "day"), 
                        n_filas, replace = TRUE)]

datos[, categoria := sample(categorias, n_filas, replace = TRUE)]

cat("Paso 4/5: Generando datos financieros...\n")
datos[, `:=`(
  # Ventas entre 100 y 50000
  ventas = round(runif(n_filas, 100, 50000), 2),
  # Costos entre 50 y 30000 (siempre menor que ventas)
  costos = round(runif(n_filas, 50, 30000), 2)
)]

# Asegurar que costos < ventas
datos[costos >= ventas, costos := ventas * 0.7]

# Precio unitario
datos[, precio := round(runif(n_filas, 10, 5000), 2)]

cat("Paso 5/5: Generando estados y campos adicionales...\n")
datos[, `:=`(
  estado = sample(estados, n_filas, replace = TRUE),
  cantidad = sample(1:100, n_filas, replace = TRUE),
  descuento = round(runif(n_filas, 0, 0.3), 2)  # 0-30% descuento
)]

# =========================================================================
# GUARDAR ARCHIVO
# =========================================================================

# Crear nombre de archivo con tamaño
nombre_archivo <- paste0("datos_benchmark_", 
                         format(n_filas / 1e6, nsmall = 1), "M.csv")

cat("\nGuardando archivo:", nombre_archivo, "\n")
cat("Esto puede tomar 1-2 minutos...\n")

# Usar fwrite para guardar rápidamente
fwrite(datos, nombre_archivo, row.names = FALSE)

# =========================================================================
# INFORMACIÓN DEL ARCHIVO GENERADO
# =========================================================================

# Obtener tamaño del archivo
tamaño_bytes <- file.info(nombre_archivo)$size
tamaño_mb <- round(tamaño_bytes / 1024^2, 2)

cat("\n" , rep("=", 70), "\n", sep = "")
cat("✅ DATASET GENERADO EXITOSAMENTE\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")
cat("📁 Archivo:", nombre_archivo, "\n")
cat("📊 Filas:", format(nrow(datos), big.mark = ","), "\n")
cat("📋 Columnas:", ncol(datos), "\n")
cat("💾 Tamaño:", tamaño_mb, "MB\n")
cat("\n")
cat("Columnas generadas:\n")
for (col in names(datos)) {
  cat("  •", col, "\n")
}
cat("\n")
cat("🔍 Vista previa (primeras 5 filas):\n")
print(head(datos, 5))
cat("\n")
cat("📈 Estadísticas rápidas:\n")
cat("  • Edad promedio:", round(mean(datos$edad), 1), "años\n")
cat("  • Ventas totales: $", format(sum(datos$ventas), big.mark = ","), "\n")
cat("  • Rango de fechas:", as.character(min(datos$fecha)), "a", 
    as.character(max(datos$fecha)), "\n")
cat("  • Categorías únicas:", length(unique(datos$categoria)), "\n")
cat("  • Regiones únicas:", length(unique(datos$region)), "\n")
cat("\n")

# =========================================================================
# INSTRUCCIONES PARA USAR EL DATASET
# =========================================================================

cat(rep("=", 70), "\n", sep = "")
cat("📖 INSTRUCCIONES DE USO\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")
cat("Ahora puedes comparar velocidades de importación:\n\n")

cat("# R BASE (más lento)\n")
cat("system.time({\n")
cat("  df_base <- read.csv('", nombre_archivo, "', stringsAsFactors = FALSE)\n", sep = "")
cat("})\n\n")

cat("# TIDYVERSE (medio)\n")
cat("library(readr)\n")
cat("system.time({\n")
cat("  df_tidy <- read_csv('", nombre_archivo, "')\n", sep = "")
cat("})\n\n")

cat("# DATA.TABLE (más rápido)\n")
cat("library(data.table)\n")
cat("system.time({\n")
cat("  dt <- fread('", nombre_archivo, "')\n", sep = "")
cat("})\n\n")

cat(rep("=", 70), "\n", sep = "")
cat("💡 SUGERENCIAS\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")
cat("• Para datasets MÁS GRANDES (más diferencias dramáticas):\n")
cat("  Cambia n_filas <- 5000000  # 5 millones (~400 MB)\n")
cat("  o      n_filas <- 10000000 # 10 millones (~800 MB)\n")
cat("\n")
cat("• Para datasets más PEQUEÑOS (demo rápida):\n")
cat("  Cambia n_filas <- 500000   # 500 mil (~40 MB)\n")
cat("\n")
cat("• El archivo CSV está en tu directorio de trabajo actual.\n")
cat("  Usa getwd() para verificar la ubicación.\n")
cat("\n")
cat(rep("=", 70), "\n", sep = "")

# =========================================================================
# SCRIPT DE BENCHMARK AUTOMÁTICO
# =========================================================================

cat("\n¿Deseas ejecutar un benchmark automático ahora? (s/n): ")
respuesta <- tolower(trimws(readline()))

if (respuesta == "s" || respuesta == "si" || respuesta == "sí") {
  cat("\n")
  cat(rep("=", 70), "\n", sep = "")
  cat("🏁 EJECUTANDO BENCHMARK DE IMPORTACIÓN\n")
  cat(rep("=", 70), "\n", sep = "")
  cat("\n")
  
  # Limpiar memoria antes de benchmark
  rm(datos)
  gc()
  
  cat("📊 Importando con R BASE (read.csv)...\n")
  tiempo_base <- system.time({
    df_base <- read.csv(nombre_archivo, stringsAsFactors = FALSE)
  })
  cat("   Tiempo:", round(tiempo_base[3], 2), "segundos\n\n")
  rm(df_base)
  gc()
  
  if (require(readr, quietly = TRUE)) {
    cat("📊 Importando con TIDYVERSE (read_csv)...\n")
    tiempo_tidy <- system.time({
      df_tidy <- read_csv(nombre_archivo, show_col_types = FALSE)
    })
    cat("   Tiempo:", round(tiempo_tidy[3], 2), "segundos\n\n")
    rm(df_tidy)
    gc()
  } else {
    cat("⚠️  readr no está instalado. Saltando tidyverse.\n\n")
    tiempo_tidy <- NA
  }
  
  cat("📊 Importando con DATA.TABLE (fread)...\n")
  tiempo_dt <- system.time({
    dt <- fread(nombre_archivo)
  })
  cat("   Tiempo:", round(tiempo_dt[3], 2), "segundos\n\n")
  rm(dt)
  gc()
  
  cat(rep("=", 70), "\n", sep = "")
  cat("📈 RESULTADOS DEL BENCHMARK\n")
  cat(rep("=", 70), "\n", sep = "")
  cat("\n")
  cat(sprintf("%-25s %10.2f segundos\n", "R Base (read.csv):", tiempo_base[3]))
  if (!is.na(tiempo_tidy[3])) {
    cat(sprintf("%-25s %10.2f segundos (%.1fx más rápido que base)\n", 
                "Tidyverse (read_csv):", tiempo_tidy[3], 
                tiempo_base[3] / tiempo_tidy[3]))
  }
  cat(sprintf("%-25s %10.2f segundos (%.1fx más rápido que base)\n", 
              "data.table (fread):", tiempo_dt[3], 
              tiempo_base[3] / tiempo_dt[3]))
  cat("\n")
  cat("🏆 GANADOR: data.table (fread)\n")
  cat("\n")
  cat(rep("=", 70), "\n", sep = "")
}

cat("\n✅ Script completado exitosamente.\n")
