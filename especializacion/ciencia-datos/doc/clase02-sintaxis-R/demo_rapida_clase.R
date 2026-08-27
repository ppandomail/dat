# =========================================================================
# Demo Rápida en Clase: Comparación de Importación
# Curso: Aplicaciones de Ciencia de Datos - UNO 2025
# Propósito: Demostración visual rápida (5-10 minutos) de las diferencias
# =========================================================================

# Este script es ideal para usar EN VIVO durante la clase

cat("\n")
cat("╔════════════════════════════════════════════════════════════════════╗\n")
cat("║          DEMO EN VIVO: R Base vs Tidyverse vs data.table         ║\n")
cat("║             Aplicaciones de Ciencia de Datos - UNO               ║\n")
cat("╚════════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# =========================================================================
# VERIFICAR PAQUETES
# =========================================================================

cat("🔧 Verificando paquetes necesarios...\n")

if (!require(data.table, quietly = TRUE)) {
  stop("❌ Instala data.table primero: install.packages('data.table')")
}

tiene_readr <- require(readr, quietly = TRUE)
if (!tiene_readr) {
  cat("⚠️  readr no instalado. Solo compararemos R base y data.table\n")
  cat("   Para instalar: install.packages('readr')\n\n")
}

# =========================================================================
# BUSCAR ARCHIVO
# =========================================================================

archivos <- list.files(pattern = "datos_benchmark.*\\.csv")

if (length(archivos) == 0) {
  cat("\n❌ No encontré archivo de datos.\n")
  cat("   Primero ejecuta: source('generar_dataset_benchmark.R')\n\n")
  stop("Archivo no encontrado")
}

archivo <- archivos[1]
tamaño_mb <- round(file.info(archivo)$size / 1024^2, 2)

cat("\n✓ Paquetes OK\n")
cat("✓ Archivo encontrado:", archivo, "\n")
cat("  Tamaño:", tamaño_mb, "MB\n")

# =========================================================================
# PREPARAR PANTALLA
# =========================================================================

cat("\n")
cat(rep("═", 70), "\n", sep = "")
cat("                    🏁 INICIANDO BENCHMARK                           \n")
cat(rep("═", 70), "\n", sep = "")
cat("\n")

Sys.sleep(1)  # Pausa dramática

# =========================================================================
# COMPARACIÓN DE IMPORTACIÓN
# =========================================================================

cat("Vamos a importar el mismo archivo CSV con tres métodos diferentes.\n")
cat("Observa la diferencia de tiempo...\n\n")

Sys.sleep(2)

# Limpiar memoria
gc(verbose = FALSE)

# -------------------------------------------------------------------------
# R BASE
# -------------------------------------------------------------------------

cat(rep("-", 70), "\n", sep = "")
cat("🐢 Método 1: R Base (read.csv)\n")
cat(rep("-", 70), "\n", sep = "")
cat("\n")
cat("Código ejecutado:\n")
cat("  df <- read.csv('", archivo, "', stringsAsFactors = FALSE)\n\n", sep = "")

cat("⏱️  Ejecutando")
for (i in 1:3) {
  cat(".")
  flush.console()
  Sys.sleep(0.3)
}
cat("\n")

tiempo_inicio <- Sys.time()
df_base <- read.csv(archivo, stringsAsFactors = FALSE)
tiempo_base <- as.numeric(difftime(Sys.time(), tiempo_inicio, units = "secs"))

cat("\n")
cat("✅ COMPLETADO en", round(tiempo_base, 2), "segundos\n")
cat("   Filas importadas:", format(nrow(df_base), big.mark = ","), "\n")
cat("   Columnas:", ncol(df_base), "\n")

Sys.sleep(2)

# Limpiar
rm(df_base)
gc(verbose = FALSE)

# -------------------------------------------------------------------------
# TIDYVERSE
# -------------------------------------------------------------------------

if (tiene_readr) {
  cat("\n")
  cat(rep("-", 70), "\n", sep = "")
  cat("🐇 Método 2: Tidyverse (read_csv)\n")
  cat(rep("-", 70), "\n", sep = "")
  cat("\n")
  cat("Código ejecutado:\n")
  cat("  library(readr)\n")
  cat("  df <- read_csv('", archivo, "')\n\n", sep = "")
  
  cat("⏱️  Ejecutando")
  for (i in 1:3) {
    cat(".")
    flush.console()
    Sys.sleep(0.3)
  }
  cat("\n")
  
  tiempo_inicio <- Sys.time()
  df_tidy <- read_csv(archivo, show_col_types = FALSE)
  tiempo_tidy <- as.numeric(difftime(Sys.time(), tiempo_inicio, units = "secs"))
  
  cat("\n")
  cat("✅ COMPLETADO en", round(tiempo_tidy, 2), "segundos\n")
  cat("   Filas importadas:", format(nrow(df_tidy), big.mark = ","), "\n")
  cat("   Mejora vs R base:", round(tiempo_base / tiempo_tidy, 1), "x más rápido 🚀\n")
  
  Sys.sleep(2)
  
  rm(df_tidy)
  gc(verbose = FALSE)
}

# -------------------------------------------------------------------------
# DATA.TABLE
# -------------------------------------------------------------------------

cat("\n")
cat(rep("-", 70), "\n", sep = "")
cat("🚀 Método 3: data.table (fread)\n")
cat(rep("-", 70), "\n", sep = "")
cat("\n")
cat("Código ejecutado:\n")
cat("  library(data.table)\n")
cat("  dt <- fread('", archivo, "')\n\n", sep = "")

cat("⏱️  Ejecutando")
for (i in 1:3) {
  cat(".")
  flush.console()
  Sys.sleep(0.3)
}
cat("\n")

tiempo_inicio <- Sys.time()
dt <- fread(archivo)
tiempo_dt <- as.numeric(difftime(Sys.time(), tiempo_inicio, units = "secs"))

cat("\n")
cat("✅ COMPLETADO en", round(tiempo_dt, 2), "segundos\n")
cat("   Filas importadas:", format(nrow(dt), big.mark = ","), "\n")
cat("   Mejora vs R base:", round(tiempo_base / tiempo_dt, 1), "x más rápido 🚀🚀🚀\n")
if (tiene_readr) {
  cat("   Mejora vs tidyverse:", round(tiempo_tidy / tiempo_dt, 1), "x más rápido\n")
}

# =========================================================================
# RESUMEN VISUAL
# =========================================================================

cat("\n\n")
cat(rep("═", 70), "\n", sep = "")
cat("                      📊 RESUMEN DE RESULTADOS                       \n")
cat(rep("═", 70), "\n", sep = "")
cat("\n")

# Crear barras ASCII
max_tiempo <- tiempo_base
escala <- 60 / max_tiempo

barra_base <- paste(rep("█", as.integer(tiempo_base * escala)), collapse = "")
if (tiene_readr) {
  barra_tidy <- paste(rep("█", as.integer(tiempo_tidy * escala)), collapse = "")
}
barra_dt <- paste(rep("█", as.integer(tiempo_dt * escala)), collapse = "")

cat(sprintf("%-15s %s %.2f seg\n", "R Base:", barra_base, tiempo_base))
if (tiene_readr) {
  cat(sprintf("%-15s %s %.2f seg\n", "Tidyverse:", barra_tidy, tiempo_tidy))
}
cat(sprintf("%-15s %s %.2f seg\n", "data.table:", barra_dt, tiempo_dt))

cat("\n")
cat(rep("═", 70), "\n", sep = "")
cat("\n")

# =========================================================================
# CONCLUSIONES PARA MOSTRAR EN CLASE
# =========================================================================

cat("🎯 PUNTOS CLAVE PARA RECORDAR:\n\n")

cat("1. VELOCIDAD:\n")
cat("   • data.table (fread) es el CLARO GANADOR\n")
cat("   • Con datasets grandes, la diferencia es aún más dramática\n")
cat("   • En archivos de 5GB+, fread puede ahorrar HORAS de tiempo\n\n")

cat("2. CUÁNDO USAR CADA UNO:\n")
cat("   • R Base: Scripts simples, sin dependencias, datos pequeños\n")
if (tiene_readr) {
  cat("   • Tidyverse: Análisis exploratorio, reportes, legibilidad\n")
}
cat("   • data.table: Producción, big data, cuando la velocidad importa\n\n")

cat("3. NOTA IMPORTANTE:\n")
cat("   • TODOS producen el mismo resultado\n")
cat("   • La diferencia está en CÓMO lo hacen\n")
cat("   • No siempre necesitas la máxima velocidad\n")
cat("   • A veces la legibilidad es más importante\n\n")

# =========================================================================
# DEMO ADICIONAL: OPERACIÓN SIMPLE
# =========================================================================

cat(rep("═", 70), "\n", sep = "")
cat("              🔬 DEMO BONUS: Filtrado y Agregación                  \n")
cat(rep("═", 70), "\n", sep = "")
cat("\n")

cat("Tarea: Calcular promedio de ventas por región para personas > 40 años\n\n")

Sys.sleep(2)

# Limpiar y preparar
gc(verbose = FALSE)

# data.table (lo más rápido)
cat("⏱️  Con data.table... ")
tiempo_inicio <- Sys.time()
resultado_dt <- dt[edad > 40, .(promedio_ventas = mean(ventas)), by = region]
tiempo_operacion <- as.numeric(difftime(Sys.time(), tiempo_inicio, units = "secs"))
cat("✓", round(tiempo_operacion, 3), "segundos\n\n")

cat("Código usado:\n")
cat("  dt[edad > 40, .(promedio_ventas = mean(ventas)), by = region]\n\n")

cat("Resultado (primeras 3 regiones):\n")
print(head(resultado_dt, 3))

cat("\n")
cat(rep("═", 70), "\n", sep = "")
cat("✅ DEMOSTRACIÓN COMPLETADA\n")
cat(rep("═", 70), "\n", sep = "")
cat("\n")

cat("💡 PARA PROFUNDIZAR:\n")
cat("   • Ejecuta 'ejecutar_benchmark_completo.R' para análisis detallado\n")
cat("   • Prueba con diferentes tamaños de datos\n")
cat("   • Experimenta con tus propios datasets\n")
cat("\n")

# =========================================================================
# INFORMACIÓN ADICIONAL
# =========================================================================

cat("📚 RECURSOS:\n")
cat("   • data.table: https://rdatatable.gitlab.io/data.table\n")
cat("   • readr: https://readr.tidyverse.org\n")
cat("   • R Base: ?read.csv en consola\n")
cat("\n")

cat("👨‍🏫 Aplicaciones de Ciencia de Datos - UNO 2025\n")
cat("\n")
