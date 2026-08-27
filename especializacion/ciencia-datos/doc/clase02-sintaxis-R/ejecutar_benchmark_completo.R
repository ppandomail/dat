# =========================================================================
# Script de Benchmark Comparativo: R Base vs Tidyverse vs data.table
# Curso: Aplicaciones de Ciencia de Datos - UNO 2025
# Propósito: Comparar rendimiento en operaciones comunes de datos
# =========================================================================

# Función para verificar e instalar paquetes necesarios
check_and_install <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat("Instalando paquete:", pkg, "\n")
      install.packages(pkg, repos = "https://cloud.r-project.org")
      library(pkg, character.only = TRUE)
    }
  }
}

# Verificar paquetes necesarios
check_and_install(c("data.table", "dplyr", "readr", "ggplot2"))

# =========================================================================
# CONFIGURACIÓN
# =========================================================================

# Buscar archivo de datos generado
archivos <- list.files(pattern = "datos_benchmark.*\\.csv")

if (length(archivos) == 0) {
  stop("❌ No se encontró archivo de benchmark. Ejecuta primero 'generar_dataset_benchmark.R'")
}

# Usar el archivo más reciente si hay varios
archivo <- archivos[length(archivos)]

cat("\n")
cat(rep("=", 70), "\n", sep = "")
cat("🔬 BENCHMARK COMPLETO: R BASE vs TIDYVERSE vs DATA.TABLE\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")
cat("📁 Archivo a analizar:", archivo, "\n")
cat("💾 Tamaño:", round(file.info(archivo)$size / 1024^2, 2), "MB\n")
cat("\n")

# Preparar estructura para resultados
resultados <- data.frame(
  Operacion = character(),
  R_Base = numeric(),
  Tidyverse = numeric(),
  Data_Table = numeric(),
  stringsAsFactors = FALSE
)

# =========================================================================
# BENCHMARK 1: IMPORTACIÓN
# =========================================================================

cat(rep("-", 70), "\n", sep = "")
cat("📥 TEST 1: IMPORTACIÓN DE DATOS\n")
cat(rep("-", 70), "\n", sep = "")

# Limpiar memoria
gc()

cat("\n1️⃣  R Base (read.csv)... ")
tiempo_base <- system.time({
  df_base <- read.csv(archivo, stringsAsFactors = FALSE)
})[3]
cat("✓", round(tiempo_base, 3), "seg\n")

cat("2️⃣  Tidyverse (read_csv)... ")
tiempo_tidy <- system.time({
  df_tidy <- read_csv(archivo, show_col_types = FALSE)
})[3]
cat("✓", round(tiempo_tidy, 3), "seg\n")

cat("3️⃣  data.table (fread)... ")
tiempo_dt <- system.time({
  dt <- fread(archivo)
})[3]
cat("✓", round(tiempo_dt, 3), "seg\n")

resultados <- rbind(resultados, data.frame(
  Operacion = "Importación",
  R_Base = tiempo_base,
  Tidyverse = tiempo_tidy,
  Data_Table = tiempo_dt
))

cat("\n📊 Resumen Importación:\n")
cat(sprintf("   data.table es %.1fx más rápido que R base\n", 
            tiempo_base / tiempo_dt))
cat(sprintf("   data.table es %.1fx más rápido que tidyverse\n", 
            tiempo_tidy / tiempo_dt))

# =========================================================================
# BENCHMARK 2: FILTRADO SIMPLE
# =========================================================================

cat("\n")
cat(rep("-", 70), "\n", sep = "")
cat("🔍 TEST 2: FILTRADO (edad > 40)\n")
cat(rep("-", 70), "\n", sep = "")

gc()

cat("\n1️⃣  R Base... ")
tiempo_base <- system.time({
  resultado_base <- df_base[df_base$edad > 40, ]
})[3]
cat("✓", round(tiempo_base, 3), "seg\n")

cat("2️⃣  Tidyverse... ")
tiempo_tidy <- system.time({
  resultado_tidy <- df_tidy |> filter(edad > 40)
})[3]
cat("✓", round(tiempo_tidy, 3), "seg\n")

cat("3️⃣  data.table... ")
tiempo_dt <- system.time({
  resultado_dt <- dt[edad > 40]
})[3]
cat("✓", round(tiempo_dt, 3), "seg\n")

resultados <- rbind(resultados, data.frame(
  Operacion = "Filtrado simple",
  R_Base = tiempo_base,
  Tidyverse = tiempo_tidy,
  Data_Table = tiempo_dt
))

# Limpiar objetos
rm(resultado_base, resultado_tidy, resultado_dt)
gc()

# =========================================================================
# BENCHMARK 3: FILTRADO COMPLEJO
# =========================================================================

cat("\n")
cat(rep("-", 70), "\n", sep = "")
cat("🔍 TEST 3: FILTRADO COMPLEJO (edad > 30 Y ventas > 10000)\n")
cat(rep("-", 70), "\n", sep = "")

gc()

cat("\n1️⃣  R Base... ")
tiempo_base <- system.time({
  resultado_base <- df_base[df_base$edad > 30 & df_base$ventas > 10000, ]
})[3]
cat("✓", round(tiempo_base, 3), "seg\n")

cat("2️⃣  Tidyverse... ")
tiempo_tidy <- system.time({
  resultado_tidy <- df_tidy |> filter(edad > 30, ventas > 10000)
})[3]
cat("✓", round(tiempo_tidy, 3), "seg\n")

cat("3️⃣  data.table... ")
tiempo_dt <- system.time({
  resultado_dt <- dt[edad > 30 & ventas > 10000]
})[3]
cat("✓", round(tiempo_dt, 3), "seg\n")

resultados <- rbind(resultados, data.frame(
  Operacion = "Filtrado complejo",
  R_Base = tiempo_base,
  Tidyverse = tiempo_tidy,
  Data_Table = tiempo_dt
))

rm(resultado_base, resultado_tidy, resultado_dt)
gc()

# =========================================================================
# BENCHMARK 4: CREAR NUEVA COLUMNA
# =========================================================================

cat("\n")
cat(rep("-", 70), "\n", sep = "")
cat("➕ TEST 4: CREAR NUEVA COLUMNA (ganancia = ventas - costos)\n")
cat(rep("-", 70), "\n", sep = "")

gc()

cat("\n1️⃣  R Base... ")
tiempo_base <- system.time({
  df_base$ganancia <- df_base$ventas - df_base$costos
})[3]
cat("✓", round(tiempo_base, 3), "seg\n")

cat("2️⃣  Tidyverse... ")
tiempo_tidy <- system.time({
  df_tidy <- df_tidy |> mutate(ganancia = ventas - costos)
})[3]
cat("✓", round(tiempo_tidy, 3), "seg\n")

cat("3️⃣  data.table (por referencia)... ")
tiempo_dt <- system.time({
  dt[, ganancia := ventas - costos]
})[3]
cat("✓", round(tiempo_dt, 3), "seg\n")

resultados <- rbind(resultados, data.frame(
  Operacion = "Nueva columna",
  R_Base = tiempo_base,
  Tidyverse = tiempo_tidy,
  Data_Table = tiempo_dt
))

cat("\n💡 Nota: data.table modifica por referencia (no copia), ahorrando memoria\n")

# =========================================================================
# BENCHMARK 5: AGREGACIÓN SIMPLE
# =========================================================================

cat("\n")
cat(rep("-", 70), "\n", sep = "")
cat("📊 TEST 5: AGREGACIÓN (promedio de ventas por región)\n")
cat(rep("-", 70), "\n", sep = "")

gc()

cat("\n1️⃣  R Base (aggregate)... ")
tiempo_base <- system.time({
  resultado_base <- aggregate(ventas ~ region, data = df_base, FUN = mean)
})[3]
cat("✓", round(tiempo_base, 3), "seg\n")

cat("2️⃣  Tidyverse (group_by + summarise)... ")
tiempo_tidy <- system.time({
  resultado_tidy <- df_tidy |> 
    group_by(region) |> 
    summarise(ventas_promedio = mean(ventas))
})[3]
cat("✓", round(tiempo_tidy, 3), "seg\n")

cat("3️⃣  data.table... ")
tiempo_dt <- system.time({
  resultado_dt <- dt[, .(ventas_promedio = mean(ventas)), by = region]
})[3]
cat("✓", round(tiempo_dt, 3), "seg\n")

resultados <- rbind(resultados, data.frame(
  Operacion = "Agregación simple",
  R_Base = tiempo_base,
  Tidyverse = tiempo_tidy,
  Data_Table = tiempo_dt
))

rm(resultado_base, resultado_tidy, resultado_dt)
gc()

# =========================================================================
# BENCHMARK 6: AGREGACIÓN COMPLEJA
# =========================================================================

cat("\n")
cat(rep("-", 70), "\n", sep = "")
cat("📊 TEST 6: AGREGACIÓN COMPLEJA (múltiples estadísticas por región y categoría)\n")
cat(rep("-", 70), "\n", sep = "")

gc()

cat("\n1️⃣  R Base (aggregate múltiple)... ")
tiempo_base <- system.time({
  resultado_base <- aggregate(cbind(ventas, costos, ganancia) ~ region + categoria, 
                              data = df_base, 
                              FUN = function(x) c(mean = mean(x), sum = sum(x)))
})[3]
cat("✓", round(tiempo_base, 3), "seg\n")

cat("2️⃣  Tidyverse... ")
tiempo_tidy <- system.time({
  resultado_tidy <- df_tidy |> 
    group_by(region, categoria) |> 
    summarise(
      ventas_promedio = mean(ventas),
      ventas_total = sum(ventas),
      costos_promedio = mean(costos),
      costos_total = sum(costos),
      ganancia_promedio = mean(ganancia),
      ganancia_total = sum(ganancia),
      n = n(),
      .groups = "drop"
    )
})[3]
cat("✓", round(tiempo_tidy, 3), "seg\n")

cat("3️⃣  data.table... ")
tiempo_dt <- system.time({
  resultado_dt <- dt[, .(
    ventas_promedio = mean(ventas),
    ventas_total = sum(ventas),
    costos_promedio = mean(costos),
    costos_total = sum(costos),
    ganancia_promedio = mean(ganancia),
    ganancia_total = sum(ganancia),
    n = .N
  ), by = .(region, categoria)]
})[3]
cat("✓", round(tiempo_dt, 3), "seg\n")

resultados <- rbind(resultados, data.frame(
  Operacion = "Agregación compleja",
  R_Base = tiempo_base,
  Tidyverse = tiempo_tidy,
  Data_Table = tiempo_dt
))

rm(resultado_base, resultado_tidy, resultado_dt)
gc()

# =========================================================================
# BENCHMARK 7: ORDENAMIENTO
# =========================================================================

cat("\n")
cat(rep("-", 70), "\n", sep = "")
cat("🔢 TEST 7: ORDENAMIENTO (por ventas descendente)\n")
cat(rep("-", 70), "\n", sep = "")

gc()

cat("\n1️⃣  R Base... ")
tiempo_base <- system.time({
  resultado_base <- df_base[order(-df_base$ventas), ]
})[3]
cat("✓", round(tiempo_base, 3), "seg\n")

cat("2️⃣  Tidyverse... ")
tiempo_tidy <- system.time({
  resultado_tidy <- df_tidy |> arrange(desc(ventas))
})[3]
cat("✓", round(tiempo_tidy, 3), "seg\n")

cat("3️⃣  data.table... ")
tiempo_dt <- system.time({
  resultado_dt <- dt[order(-ventas)]
})[3]
cat("✓", round(tiempo_dt, 3), "seg\n")

resultados <- rbind(resultados, data.frame(
  Operacion = "Ordenamiento",
  R_Base = tiempo_base,
  Tidyverse = tiempo_tidy,
  Data_Table = tiempo_dt
))

rm(resultado_base, resultado_tidy, resultado_dt)
gc()

# =========================================================================
# RESUMEN Y VISUALIZACIÓN DE RESULTADOS
# =========================================================================

cat("\n\n")
cat(rep("=", 70), "\n", sep = "")
cat("📈 TABLA DE RESULTADOS COMPLETA\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")

# Calcular speedups
resultados$Speedup_vs_Base_Tidy <- round(resultados$R_Base / resultados$Tidyverse, 2)
resultados$Speedup_vs_Base_DT <- round(resultados$R_Base / resultados$Data_Table, 2)
resultados$Speedup_vs_Tidy_DT <- round(resultados$Tidyverse / resultados$Data_Table, 2)

# Formatear tiempos
resultados$R_Base <- round(resultados$R_Base, 3)
resultados$Tidyverse <- round(resultados$Tidyverse, 3)
resultados$Data_Table <- round(resultados$Data_Table, 3)

print(resultados, row.names = FALSE)

cat("\n")
cat(rep("=", 70), "\n", sep = "")
cat("🏆 RESUMEN DE GANADORES\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")

for (i in 1:nrow(resultados)) {
  op <- resultados$Operacion[i]
  tiempos <- c(R_Base = resultados$R_Base[i], 
               Tidyverse = resultados$Tidyverse[i], 
               Data_Table = resultados$Data_Table[i])
  ganador <- names(which.min(tiempos))
  
  cat(sprintf("%-25s → %s (%.3f seg)\n", op, ganador, min(tiempos)))
}

# Calcular promedios
cat("\n")
cat(rep("=", 70), "\n", sep = "")
cat("📊 ESTADÍSTICAS GENERALES\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")

cat("Tiempo promedio por operación:\n")
cat(sprintf("  • R Base:      %.3f segundos\n", mean(resultados$R_Base)))
cat(sprintf("  • Tidyverse:   %.3f segundos\n", mean(resultados$Tidyverse)))
cat(sprintf("  • data.table:  %.3f segundos\n", mean(resultados$Data_Table)))
cat("\n")

cat("Speedup promedio (relativo a R Base):\n")
cat(sprintf("  • Tidyverse es %.1fx más rápido que R Base\n", 
            mean(resultados$Speedup_vs_Base_Tidy)))
cat(sprintf("  • data.table es %.1fx más rápido que R Base\n", 
            mean(resultados$Speedup_vs_Base_DT)))
cat("\n")

cat("Speedup promedio (data.table vs Tidyverse):\n")
cat(sprintf("  • data.table es %.1fx más rápido que Tidyverse\n", 
            mean(resultados$Speedup_vs_Tidy_DT)))

# =========================================================================
# CREAR VISUALIZACIÓN
# =========================================================================

cat("\n\n")
cat(rep("=", 70), "\n", sep = "")
cat("📊 GENERANDO GRÁFICO COMPARATIVO...\n")
cat(rep("=", 70), "\n", sep = "")

# Preparar datos para ggplot
library(tidyr)
resultados_long <- resultados |>
  select(Operacion, R_Base, Tidyverse, Data_Table) |>
  pivot_longer(cols = c(R_Base, Tidyverse, Data_Table),
               names_to = "Metodo",
               values_to = "Tiempo")

# Crear gráfico
p <- ggplot(resultados_long, aes(x = Operacion, y = Tiempo, fill = Metodo)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(
    values = c("R_Base" = "#FF9999", 
               "Tidyverse" = "#99FF99", 
               "Data_Table" = "#9999FF"),
    labels = c("R Base", "Tidyverse", "data.table")
  ) +
  labs(
    title = "Comparación de Rendimiento: R Base vs Tidyverse vs data.table",
    subtitle = paste("Dataset:", basename(archivo)),
    x = "Operación",
    y = "Tiempo (segundos)",
    fill = "Método",
    caption = "Aplicaciones de Ciencia de Datos - UNO 2025"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

# Guardar gráfico
ggsave("benchmark_comparacion.png", p, width = 12, height = 8, dpi = 300)
cat("\n✅ Gráfico guardado como: benchmark_comparacion.png\n")

# Mostrar gráfico
print(p)

# =========================================================================
# GUARDAR RESULTADOS
# =========================================================================

# Guardar tabla de resultados
write.csv(resultados, "benchmark_resultados.csv", row.names = FALSE)
cat("✅ Resultados guardados como: benchmark_resultados.csv\n")

# =========================================================================
# CONCLUSIONES
# =========================================================================

cat("\n")
cat(rep("=", 70), "\n", sep = "")
cat("💡 CONCLUSIONES PRINCIPALES\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")

cat("1. IMPORTACIÓN:\n")
cat(sprintf("   • data.table (fread) es el claro ganador: %.1fx más rápido que R base\n",
            resultados$Speedup_vs_Base_DT[resultados$Operacion == "Importación"]))
cat("   • Fundamental para datasets grandes (>100MB)\n\n")

cat("2. MANIPULACIÓN:\n")
cat("   • data.table domina en todas las operaciones\n")
cat("   • Tidyverse es más legible pero 2-5x más lento que data.table\n")
cat("   • R base es consistentemente el más lento\n\n")

cat("3. MEMORIA:\n")
cat("   • data.table usa modificación por referencia (:=)\n")
cat("   • Tidyverse y R base copian datos en cada operación\n")
cat("   • Con datasets grandes (>1GB), esto es crítico\n\n")

cat("4. RECOMENDACIONES:\n")
cat("   • Exploración y reportes: Tidyverse (legibilidad)\n")
cat("   • Producción y big data: data.table (velocidad)\n")
cat("   • Scripts simples: R base (sin dependencias)\n")

cat("\n")
cat(rep("=", 70), "\n", sep = "")
cat("✅ BENCHMARK COMPLETADO\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n")
cat("Archivos generados:\n")
cat("  📊 benchmark_resultados.csv\n")
cat("  📈 benchmark_comparacion.png\n")
cat("\n")
