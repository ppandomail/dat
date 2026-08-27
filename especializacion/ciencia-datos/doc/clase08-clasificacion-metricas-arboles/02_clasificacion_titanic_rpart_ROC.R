# =============================================================================
# CLASIFICACIÓN DE SUPERVIVENCIA DEL TITANIC CON ÁRBOL DE DECISIÓN + ROC
# =============================================================================
# Instructor: Fran - Universidad Nacional del Oeste (UNO)
# Fecha: 22 de Noviembre de 2025
# Dataset: Titanic Survival (Kaggle / UCI ML Repository)
# 
# Objetivo Pedagógico:
# 1. Predecir supervivencia de pasajeros del Titanic usando árbol de decisión
# 2. Evaluar el modelo con métricas de clasificación (precision, recall, F1)
# 3. Construir y analizar curva ROC + AUC
# 4. Discutir sesgos y equidad en modelos predictivos
# 
# Variables:
#   - Pclass: Clase del pasajero (1 = Primera, 2 = Segunda, 3 = Tercera)
#   - Sex: Sexo (male/female)
#   - Age: Edad en años
#   - SibSp: Número de hermanos/cónyuges a bordo
#   - Parch: Número de padres/hijos a bordo
#   - Fare: Tarifa pagada por el ticket
#   - Embarked: Puerto de embarque (C=Cherbourg, Q=Queenstown, S=Southampton)
#   - Survived: 0 = Murió, 1 = Sobrevivió (VARIABLE OBJETIVO)
# =============================================================================

# -----------------------------------------------------------------------------
# PASO 1: CARGAR LIBRERÍAS NECESARIAS
# -----------------------------------------------------------------------------

# Si no las tenés instaladas, descomentar estas líneas:
# install.packages("data.table")
# install.packages("rpart")
# install.packages("rpart.plot")
# install.packages("pROC")
# install.packages("caret")

library(data.table)   # Manipulación eficiente de datos
library(rpart)        # Árboles de decisión (Recursive Partitioning)
library(rpart.plot)   # Visualización bonita de árboles
library(pROC)         # Curvas ROC y cálculo de AUC
library(caret)        # Matriz de confusión y métricas

cat("\n✓ Librerías cargadas exitosamente\n")

# -----------------------------------------------------------------------------
# PASO 2: DESCARGAR Y CARGAR EL DATASET TITANIC
# -----------------------------------------------------------------------------

cat("\n=== DESCARGANDO DATASET TITANIC SURVIVAL ===\n")

# URL del dataset Titanic (versión completa con train + test etiquetado)
url <- "https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv"

# Descargar dataset
titanic_raw <- fread(url)

cat("✓ Dataset descargado\n")

# -----------------------------------------------------------------------------
# PASO 3: EXPLORACIÓN INICIAL DE DATOS
# -----------------------------------------------------------------------------

cat("\n=== EXPLORACIÓN INICIAL DEL DATASET ===\n\n")

# Mostrar estructura del dataset
cat("Estructura del dataset:\n")
str(titanic_raw)

cat("\n------------------------------------------------------\n")

# Primeras 6 filas
cat("\nPrimeras 6 observaciones:\n")
print(head(titanic_raw))

cat("\n------------------------------------------------------\n")

# Resumen estadístico
cat("\nResumen estadístico de las variables:\n")
print(summary(titanic_raw))

cat("\n------------------------------------------------------\n")

# Balance de clases (¿cuántos sobrevivieron vs. murieron?)
cat("\nBalance de clases (sin procesamiento):\n")
tabla_clases_raw <- table(titanic_raw$Survived)
names(tabla_clases_raw) <- c("Died", "Survived")
print(tabla_clases_raw)

# Calcular proporciones
prop_clases_raw <- prop.table(tabla_clases_raw) * 100
cat("\nProporciones:\n")
cat(sprintf("  Died:     %.1f%% (%d pasajeros)\n", 
            prop_clases_raw["Died"], tabla_clases_raw["Died"]))
cat(sprintf("  Survived: %.1f%% (%d pasajeros)\n", 
            prop_clases_raw["Survived"], tabla_clases_raw["Survived"]))

cat("\n------------------------------------------------------\n")

# Análisis de valores faltantes
cat("\nAnálisis de valores faltantes:\n")
missing_count <- colSums(is.na(titanic_raw))
missing_pct <- round(100 * missing_count / nrow(titanic_raw), 2)
missing_summary <- data.frame(
  Variable = names(missing_count),
  Missing_Count = missing_count,
  Missing_Pct = missing_pct
)
missing_summary <- missing_summary[missing_summary$Missing_Count > 0, ]

if (nrow(missing_summary) > 0) {
  print(missing_summary, row.names = FALSE)
  cat("\n⚠ IMPORTANTE: Hay valores faltantes que debemos manejar\n")
} else {
  cat("✓ No hay valores faltantes\n")
}

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 4: PREPARACIÓN Y LIMPIEZA DE DATOS
# -----------------------------------------------------------------------------

cat("\n=== PREPARACIÓN DE DATOS ===\n\n")

# Seleccionar solo las variables que vamos a usar
# Descartamos: PassengerId (ID), Name (texto), Ticket (texto), Cabin (muchos NAs)
titanic <- titanic_raw[, .(
  Survived,      # Variable objetivo
  Pclass,        # Clase socioeconómica
  Sex,           # Sexo
  Age,           # Edad
  SibSp,         # Hermanos/cónyuges
  Parch,         # Padres/hijos
  Fare,          # Tarifa pagada
  Embarked       # Puerto de embarque
)]

cat("Variables seleccionadas para el modelo:\n")
cat(paste(names(titanic), collapse = ", "))
cat("\n\n")

# Convertir Survived a factor con etiquetas descriptivas
titanic$Survived <- factor(titanic$Survived, 
                           levels = c(0, 1), 
                           labels = c("Died", "Survived"))

# Convertir Sex a factor
titanic$Sex <- factor(titanic$Sex)

# Convertir Pclass a factor (es categórica, no numérica)
titanic$Pclass <- factor(titanic$Pclass, 
                         levels = c(1, 2, 3),
                         labels = c("1st", "2nd", "3rd"))

# Convertir Embarked a factor
titanic$Embarked <- factor(titanic$Embarked)

cat("------------------------------------------------------\n")

# Manejar valores faltantes
cat("\nMANEJO DE VALORES FALTANTES:\n\n")

# Age: Imputar con la mediana (más robusta que la media)
age_median <- median(titanic$Age, na.rm = TRUE)
n_age_missing <- sum(is.na(titanic$Age))
cat(sprintf("• Age: %d valores faltantes (%.1f%%)\n", 
            n_age_missing, 100 * n_age_missing / nrow(titanic)))
cat(sprintf("  → Imputando con la mediana: %.1f años\n", age_median))
titanic[is.na(Age), Age := age_median]

# Embarked: Imputar con la moda (valor más frecuente)
embarked_mode <- names(which.max(table(titanic$Embarked)))
n_embarked_missing <- sum(is.na(titanic$Embarked))
if (n_embarked_missing > 0) {
  cat(sprintf("\n• Embarked: %d valores faltantes\n", n_embarked_missing))
  cat(sprintf("  → Imputando con la moda: %s\n", embarked_mode))
  titanic[is.na(Embarked), Embarked := embarked_mode]
}

# Fare: Verificar si hay NAs (raro, pero por las dudas)
n_fare_missing <- sum(is.na(titanic$Fare))
if (n_fare_missing > 0) {
  fare_median <- median(titanic$Fare, na.rm = TRUE)
  cat(sprintf("\n• Fare: %d valores faltantes\n", n_fare_missing))
  cat(sprintf("  → Imputando con la mediana: %.2f\n", fare_median))
  titanic[is.na(Fare), Fare := fare_median]
}

# Verificar que no queden NAs
cat("\n✓ Valores faltantes después de imputación:\n")
print(colSums(is.na(titanic)))

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 5: ANÁLISIS EXPLORATORIO RÁPIDO (SESGOS EVIDENTES)
# -----------------------------------------------------------------------------

cat("\n=== ANÁLISIS EXPLORATORIO: SESGOS EVIDENTES ===\n\n")

# Supervivencia por sexo
cat("1. SUPERVIVENCIA POR SEXO:\n")
tabla_sex <- table(titanic$Sex, titanic$Survived)
prop_sex <- prop.table(tabla_sex, margin = 1) * 100
cat("\n")
print(prop_sex)
cat("\nInterpretación:\n")
cat(sprintf("  • %.1f%% de las MUJERES sobrevivieron\n", prop_sex["female", "Survived"]))
cat(sprintf("  • %.1f%% de los HOMBRES sobrevivieron\n", prop_sex["male", "Survived"]))
cat("  → SESGO EVIDENTE: Política 'Mujeres y niños primero'\n")

cat("\n------------------------------------------------------\n")

# Supervivencia por clase
cat("\n2. SUPERVIVENCIA POR CLASE SOCIOECONÓMICA:\n")
tabla_pclass <- table(titanic$Pclass, titanic$Survived)
prop_pclass <- prop.table(tabla_pclass, margin = 1) * 100
cat("\n")
print(prop_pclass)
cat("\nInterpretación:\n")
cat(sprintf("  • %.1f%% de pasajeros de 1ra clase sobrevivieron\n", 
            prop_pclass["1st", "Survived"]))
cat(sprintf("  • %.1f%% de pasajeros de 2da clase sobrevivieron\n", 
            prop_pclass["2nd", "Survived"]))
cat(sprintf("  • %.1f%% de pasajeros de 3ra clase sobrevivieron\n", 
            prop_pclass["3rd", "Survived"]))
cat("  → SESGO EVIDENTE: Clase social determinó acceso a botes salvavidas\n")

cat("\n------------------------------------------------------\n")

# Estadísticas descriptivas por supervivencia
cat("\n3. EDAD Y TARIFA PROMEDIO POR SUPERVIVENCIA:\n\n")
stats_survived <- titanic[, .(
  Edad_Promedio = mean(Age),
  Tarifa_Promedio = mean(Fare),
  N = .N
), by = Survived]
print(stats_survived)

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 6: DIVISIÓN EN TRAIN Y TEST (70% / 30%)
# -----------------------------------------------------------------------------

cat("\n=== DIVISIÓN TRAIN/TEST ===\n\n")

# Fijar semilla para reproducibilidad
set.seed(42)

# Crear índices para el conjunto de entrenamiento (70% de los datos)
n_total <- nrow(titanic)
n_train <- floor(0.7 * n_total)

# Muestreo aleatorio de índices
train_idx <- sample(1:n_total, n_train)

# Dividir en train y test
train <- titanic[train_idx]
test <- titanic[-train_idx]

cat(sprintf("Dataset original: %d pasajeros\n", n_total))
cat(sprintf("Conjunto TRAIN:   %d pasajeros (%.1f%%)\n", 
            nrow(train), 100 * nrow(train) / n_total))
cat(sprintf("Conjunto TEST:    %d pasajeros (%.1f%%)\n", 
            nrow(test), 100 * nrow(test) / n_total))

cat("\n------------------------------------------------------\n")

# Verificar balance de clases en train y test
cat("\nBalance de clases en TRAIN:\n")
print(table(train$Survived))

cat("\nBalance de clases en TEST:\n")
print(table(test$Survived))

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 7: ENTRENAR ÁRBOL DE DECISIÓN CON rpart
# -----------------------------------------------------------------------------

cat("\n=== ENTRENANDO ÁRBOL DE DECISIÓN ===\n\n")

# Entrenar árbol de clasificación
# Formula: Survived ~ . significa "predecir Survived usando todas las demás variables"
# method = "class" indica que es clasificación (no regresión)
arbol_titanic <- rpart(
  formula = Survived ~ .,          # Predecir supervivencia con todas las variables
  data = train,                     # Usar datos de entrenamiento
  method = "class",                 # Clasificación (no regresión)
  control = rpart.control(
    cp = 0.001,                     # Permitir árboles más complejos (menor cp)
    minsplit = 20,                  # Mínimo 20 obs para hacer split
    maxdepth = 10                   # Máximo 10 niveles de profundidad
  )
)

cat("✓ Árbol entrenado exitosamente\n\n")

# Ver resumen del árbol
cat("Resumen del árbol:\n")
print(arbol_titanic)

cat("\n------------------------------------------------------\n")

# Importancia de variables
cat("\nImportancia de las variables:\n")
if (!is.null(arbol_titanic$variable.importance)) {
  importancia <- arbol_titanic$variable.importance
  print(round(importancia, 2))
  
  cat("\nInterpretación:\n")
  cat("  → Variables con mayor valor tienen más poder predictivo\n")
  cat(sprintf("  → Variable más importante: %s\n", names(importancia)[1]))
} else {
  cat("  (Árbol muy simple, pocas variables usadas)\n")
}

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 8: VISUALIZAR EL ÁRBOL DE DECISIÓN
# -----------------------------------------------------------------------------

cat("\n=== VISUALIZANDO EL ÁRBOL DE DECISIÓN ===\n\n")

# Crear gráfico del árbol con rpart.plot
rpart.plot(
  arbol_titanic,
  type = 5,                         # Tipo 5: muestra splits y proporciones
  box.palette = "RdYlGn",           # Paleta Rojo-Amarillo-Verde
  branch.lty = 3,                   # Líneas de rama punteadas
  shadow.col = "gray",              # Sombra gris detrás de nodos
  nn = TRUE,                        # Mostrar número de nodo
  main = "Árbol de Decisión: Supervivencia del Titanic\n(Died vs. Survived)",
  extra = 104,                      # Muestra probabilidad y porcentaje
  under = TRUE                      # Información adicional bajo el nodo
)

cat("✓ Árbol visualizado\n")
cat("\nInterpretación del árbol:\n")
cat("  - Nodos ROJOS: Mayoría de pasajeros MURIERON\n")
cat("  - Nodos VERDES: Mayoría de pasajeros SOBREVIVIERON\n")
cat("  - Cada nodo muestra: clase predicha / probabilidad / % de datos\n")
cat("  - Las ramas muestran las reglas de decisión\n")

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 9: HACER PREDICCIONES EN EL CONJUNTO TEST
# -----------------------------------------------------------------------------

cat("\n=== PREDICCIONES EN CONJUNTO TEST ===\n\n")

# Predecir clases (Died o Survived)
predicciones_clase <- predict(arbol_titanic, test, type = "class")

# Predecir probabilidades (útil para curva ROC)
predicciones_prob <- predict(arbol_titanic, test, type = "prob")

cat("Primeras 10 predicciones:\n\n")
cat("  Real       Predicho    P(Died)    P(Survived)\n")
cat("  ------------------------------------------------\n")
for (i in 1:10) {
  cat(sprintf("  %-10s %-10s  %.4f     %.4f\n",
              test$Survived[i],
              predicciones_clase[i],
              predicciones_prob[i, "Died"],
              predicciones_prob[i, "Survived"]))
}

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 10: MATRIZ DE CONFUSIÓN
# -----------------------------------------------------------------------------

cat("\n=== MATRIZ DE CONFUSIÓN ===\n\n")

# Crear matriz de confusión usando caret::confusionMatrix
conf_matrix <- confusionMatrix(
  data = predicciones_clase,        # Predicciones del modelo
  reference = test$Survived,        # Valores reales
  positive = "Survived"             # Clase positiva (la que queremos detectar)
)

# Mostrar matriz de confusión completa
print(conf_matrix)

cat("\n------------------------------------------------------\n")

# Extraer y explicar manualmente los componentes
cat("\nDESGLOSE DE LA MATRIZ DE CONFUSIÓN:\n\n")

# Extraer tabla 2x2
tabla <- conf_matrix$table

# Extraer valores individuales
TN <- tabla["Died", "Died"]           # True Negatives
FP <- tabla["Survived", "Died"]       # False Positives
FN <- tabla["Died", "Survived"]       # False Negatives
TP <- tabla["Survived", "Survived"]   # True Positives

cat("                 Predicho\n")
cat("                 Died      Survived\n")
cat("           -------------------------\n")
cat(sprintf("  Died     |   %4d   |  %4d   | (Realmente murieron)\n", TN, FN))
cat(sprintf("  Survived |   %4d   |  %4d   | (Realmente sobrevivieron)\n", FP, TP))
cat("           -------------------------\n\n")

cat("Interpretación:\n")
cat(sprintf("  True Negatives (TN):  %4d - Muertes correctamente predichas\n", TN))
cat(sprintf("  False Positives (FP): %4d - Predijimos sobrevivencia pero murieron\n", FP))
cat(sprintf("  False Negatives (FN): %4d - Predijimos muerte pero sobrevivieron\n", FN))
cat(sprintf("  True Positives (TP):  %4d - Sobrevivencias correctamente predichas\n", TP))

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 11: MÉTRICAS DE CLASIFICACIÓN DETALLADAS
# -----------------------------------------------------------------------------

cat("\n=== MÉTRICAS DE CLASIFICACIÓN ===\n\n")

# Calcular métricas manualmente
accuracy <- (TP + TN) / (TP + TN + FP + FN)
precision <- TP / (TP + FP)
recall <- TP / (TP + FN)
specificity <- TN / (TN + FP)
f1_score <- 2 * (precision * recall) / (precision + recall)
fpr <- FP / (FP + TN)

cat("MÉTRICAS PRINCIPALES:\n\n")

cat(sprintf("1. ACCURACY (Exactitud):           %.4f (%.2f%%)\n", accuracy, accuracy * 100))
cat("   → Proporción de predicciones correctas\n\n")

cat(sprintf("2. PRECISION (Valor Predictivo +): %.4f (%.2f%%)\n", precision, precision * 100))
cat("   → De los que predijimos SURVIVED, ¿cuántos realmente sobrevivieron?\n")
cat("   → Fórmula: TP / (TP + FP)\n\n")

cat(sprintf("3. RECALL (Sensibilidad, TPR):     %.4f (%.2f%%)\n", recall, recall * 100))
cat("   → De los que realmente SURVIVED, ¿cuántos logramos detectar?\n")
cat("   → Fórmula: TP / (TP + FN)\n\n")

cat(sprintf("4. SPECIFICITY (Especificidad):    %.4f (%.2f%%)\n", specificity, specificity * 100))
cat("   → De los que realmente DIED, ¿cuántos identificamos correctamente?\n")
cat("   → Fórmula: TN / (TN + FP)\n\n")

cat(sprintf("5. F1-SCORE (Media armónica):      %.4f\n", f1_score))
cat("   → Balance entre Precision y Recall\n\n")

cat(sprintf("6. FALSE POSITIVE RATE (FPR):      %.4f (%.2f%%)\n", fpr, fpr * 100))
cat("   → Proporción de muertes mal clasificadas como supervivencias\n\n")

cat("------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 12: INTERPRETACIÓN EN CONTEXTO DEL TITANIC
# -----------------------------------------------------------------------------

cat("\n=== INTERPRETACIÓN EN EL CONTEXTO DEL TITANIC ===\n\n")

cat("¿QUÉ SIGNIFICA CADA MÉTRICA PARA LA TRAGEDIA DEL TITANIC?\n\n")

cat("• RECALL (Sensibilidad):\n")
cat("  → \"¿Cuántos SUPERVIVIENTES logramos identificar correctamente?\"\n")
cat(sprintf("  → Con recall = %.2f%%, estamos identificando %.0f de cada 100 supervivientes\n", 
            recall * 100, recall * 100))
cat("  → Recall BAJO significa que estamos clasificando supervivientes como muertos\n\n")

cat("• PRECISION:\n")
cat("  → \"Cuando predecimos que alguien sobrevivió, ¿qué tan seguros estamos?\"\n")
cat(sprintf("  → Con precision = %.2f%%, de cada 100 predicciones de 'sobrevivió',\n", 
            precision * 100))
cat(sprintf("     %.0f realmente sobrevivieron y %.0f murieron\n", 
            precision * 100, (1 - precision) * 100))
cat("  → Precision BAJA significa predicciones optimistas pero incorrectas\n\n")

cat("• F1-SCORE:\n")
cat("  → Balance entre ambos objetivos\n")
cat(sprintf("  → F1 = %.4f indica un %s balance\n", 
            f1_score, 
            ifelse(f1_score > 0.8, "muy buen", 
                   ifelse(f1_score > 0.7, "buen", "aceptable"))))

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 13: CURVA ROC Y AUC
# -----------------------------------------------------------------------------

cat("\n=== CURVA ROC Y ÁREA BAJO LA CURVA (AUC) ===\n\n")

# Extraer probabilidad de "Survived"
prob_survived <- predicciones_prob[, "Survived"]

# Crear objeto ROC
roc_obj <- roc(
  response = test$Survived,         # Valores reales
  predictor = prob_survived,        # Probabilidades predichas
  levels = c("Died", "Survived"),   # Orden: negativo, positivo
  direction = "<"                   # Menor prob → clase negativa
)

# Calcular AUC
auc_value <- auc(roc_obj)

cat("INFORMACIÓN DE LA CURVA ROC:\n\n")
cat(sprintf("AUC (Área bajo la curva): %.4f\n\n", auc_value))

cat("INTERPRETACIÓN DEL AUC:\n")
cat("  • AUC = 1.0   → Clasificador perfecto\n")
cat("  • AUC = 0.9   → Excelente\n")
cat("  • AUC = 0.8   → Muy bueno\n")
cat("  • AUC = 0.7   → Bueno\n")
cat("  • AUC = 0.5   → Aleatorio (línea diagonal)\n\n")

cat(sprintf("Con AUC = %.4f, nuestro modelo es %s\n", 
            auc_value,
            ifelse(auc_value > 0.85, "MUY BUENO",
                   ifelse(auc_value > 0.75, "BUENO", 
                          ifelse(auc_value > 0.65, "ACEPTABLE", "MEJORABLE")))))

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 14: GRAFICAR CURVA ROC
# -----------------------------------------------------------------------------

cat("\n=== GRAFICANDO CURVA ROC ===\n\n")

# Graficar ROC curve
plot.roc(
  roc_obj,
  col = "darkblue",                 # Color de la curva
  lwd = 2.5,                        # Grosor de línea
  main = paste0("Curva ROC - Supervivencia del Titanic\n",
                "AUC = ", round(auc_value, 4)),
  print.auc = TRUE,                 # Mostrar AUC en el gráfico
  print.auc.x = 0.4,                # Posición X del AUC
  print.auc.y = 0.3,                # Posición Y del AUC
  auc.polygon = TRUE,               # Sombrear área bajo la curva
  auc.polygon.col = "lightblue",    # Color del área sombreada
  grid = TRUE,                      # Mostrar grilla
  legacy.axes = TRUE                # Ejes tradicionales
)

# Línea diagonal de referencia
abline(a = 0, b = 1, lty = 2, col = "gray50", lwd = 1.5)

# Leyenda
legend("bottomright",
       legend = c("Árbol de Decisión (rpart)", 
                  "Clasificador Aleatorio (AUC=0.5)"),
       col = c("darkblue", "gray50"),
       lwd = c(2.5, 1.5),
       lty = c(1, 2),
       bty = "n")

cat("✓ Curva ROC graficada\n\n")

cat("COMPONENTES DE LA CURVA ROC:\n\n")
cat("• EJE X: False Positive Rate (FPR) = 1 - Specificity\n")
cat("  → Proporción de MUERTES clasificadas erróneamente como SUPERVIVENCIAS\n\n")
cat("• EJE Y: True Positive Rate (TPR) = Recall = Sensitivity\n")
cat("  → Proporción de SUPERVIVENCIAS detectadas correctamente\n\n")
cat("• LÍNEA DIAGONAL: Clasificador aleatorio\n")
cat("• LÍNEA AZUL: Nuestro árbol de decisión\n")
cat("• ÁREA SOMBREADA: Representa el AUC\n\n")

cat("------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 15: ENCONTRAR EL MEJOR THRESHOLD (YOUDEN)
# -----------------------------------------------------------------------------

cat("\n=== SELECCIÓN DEL MEJOR THRESHOLD ===\n\n")

# Obtener coordenadas ROC
coords_roc <- coords(roc_obj, 
                     x = "all", 
                     ret = c("threshold", "specificity", "sensitivity"))

# Calcular índice de Youden
youden <- coords_roc$sensitivity + coords_roc$specificity - 1

# Encontrar threshold óptimo
idx_best <- which.max(youden)
best_threshold <- coords_roc$threshold[idx_best]
best_sens <- coords_roc$sensitivity[idx_best]
best_spec <- coords_roc$specificity[idx_best]
best_youden <- youden[idx_best]

cat("Índice de Youden (J = Sensitivity + Specificity - 1)\n")
cat("  → Maximiza la distancia de la curva ROC a la diagonal\n\n")

cat(sprintf("Threshold óptimo: %.4f\n", best_threshold))
cat(sprintf("  Sensitivity: %.4f\n", best_sens))
cat(sprintf("  Specificity: %.4f\n", best_spec))
cat(sprintf("  Índice J:    %.4f\n\n", best_youden))

cat("------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 16: DISCUSIÓN SOBRE SESGOS Y EQUIDAD
# -----------------------------------------------------------------------------

cat("\n=== DISCUSIÓN: SESGOS Y EQUIDAD EN MODELOS PREDICTIVOS ===\n\n")

cat("REFLEXIÓN CRÍTICA SOBRE EL MODELO:\n\n")

cat("1. SESGOS HISTÓRICOS CAPTURADOS:\n")
cat("   • El modelo aprende de datos históricos del desastre del Titanic\n")
cat("   • Estos datos reflejan sesgos sociales de 1912:\n")
cat("     - Género: 'Mujeres y niños primero' → Sesgo favorable a mujeres\n")
cat("     - Clase social: Pasajeros de 1ra clase tuvieron acceso preferencial\n")
cat("     - Ubicación: Cabinas cercanas a cubiertas superiores → mayor supervivencia\n\n")

cat("2. IMPLICACIONES ÉTICAS:\n")
cat("   • ¿Es 'justo' un modelo que predice mejor para ciertos grupos?\n")
cat("   • Si usáramos este modelo para decisiones reales:\n")
cat("     - ¿Estaríamos perpetuando inequidades históricas?\n")
cat("     - ¿Deberíamos penalizar o rebalancear según género/clase?\n\n")

cat("3. PRECISIÓN vs. EQUIDAD:\n")
cat("   • Modelo preciso ≠ Modelo justo\n")
cat("   • Alta accuracy puede esconder disparidades entre grupos\n")
cat("   • Importante analizar métricas SEPARADAS por grupo:\n")
cat("     - Recall para hombres vs. mujeres\n")
cat("     - Precision para 1ra clase vs. 3ra clase\n\n")

cat("4. LECCIONES PARA ML EN LA PRÁCTICA:\n")
cat("   ✓ Siempre explorar sesgos en los datos históricos\n")
cat("   ✓ Evaluar fairness además de accuracy\n")
cat("   ✓ Considerar el impacto social de las predicciones\n")
cat("   ✓ Documentar limitaciones y sesgos del modelo\n\n")

cat("------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 17: ANÁLISIS DE EQUIDAD POR GRUPO
# -----------------------------------------------------------------------------

cat("\n=== ANÁLISIS DE EQUIDAD: MÉTRICAS POR SEXO ===\n\n")

# Crear predicciones para todo el conjunto test
test_con_pred <- copy(test)
test_con_pred$Predicted <- predicciones_clase

# Función para calcular métricas por grupo
calcular_metricas_grupo <- function(data, grupo) {
  tabla <- table(data$Survived, data$Predicted)
  
  if (nrow(tabla) < 2 || ncol(tabla) < 2) {
    return(data.frame(
      Grupo = grupo,
      N = nrow(data),
      Accuracy = NA,
      Recall = NA,
      Precision = NA
    ))
  }
  
  TN <- tabla["Died", "Died"]
  FP <- ifelse("Survived" %in% rownames(tabla) && "Died" %in% colnames(tabla),
               tabla["Survived", "Died"], 0)
  FN <- ifelse("Died" %in% rownames(tabla) && "Survived" %in% colnames(tabla),
               tabla["Died", "Survived"], 0)
  TP <- ifelse("Survived" %in% rownames(tabla) && "Survived" %in% colnames(tabla),
               tabla["Survived", "Survived"], 0)
  
  acc <- (TP + TN) / sum(tabla)
  rec <- ifelse((TP + FN) > 0, TP / (TP + FN), NA)
  prec <- ifelse((TP + FP) > 0, TP / (TP + FP), NA)
  
  return(data.frame(
    Grupo = grupo,
    N = nrow(data),
    Accuracy = round(acc, 4),
    Recall = round(rec, 4),
    Precision = round(prec, 4)
  ))
}

# Calcular métricas por sexo
metricas_hombres <- calcular_metricas_grupo(test_con_pred[Sex == "male"], "Hombres")
metricas_mujeres <- calcular_metricas_grupo(test_con_pred[Sex == "female"], "Mujeres")

# Calcular métricas por clase
metricas_1st <- calcular_metricas_grupo(test_con_pred[Pclass == "1st"], "1ra Clase")
metricas_2nd <- calcular_metricas_grupo(test_con_pred[Pclass == "2nd"], "2da Clase")
metricas_3rd <- calcular_metricas_grupo(test_con_pred[Pclass == "3rd"], "3ra Clase")

cat("MÉTRICAS POR SEXO:\n")
metricas_sexo <- rbind(metricas_hombres, metricas_mujeres)
print(metricas_sexo, row.names = FALSE)

cat("\n\nMÉTRICAS POR CLASE SOCIOECONÓMICA:\n")
metricas_clase <- rbind(metricas_1st, metricas_2nd, metricas_3rd)
print(metricas_clase, row.names = FALSE)

cat("\n\nINTERPRETACIÓN:\n")
cat("• Diferencias en Recall entre grupos indican sesgo en la capacidad de detectar supervivientes\n")
cat("• Diferencias en Precision indican sesgo en la confiabilidad de predicciones positivas\n")
cat("• Estas disparidades reflejan tanto los sesgos históricos como las limitaciones del modelo\n")

cat("\n------------------------------------------------------\n")

# -----------------------------------------------------------------------------
# PASO 18: RESUMEN FINAL Y CONCLUSIONES
# -----------------------------------------------------------------------------

cat("\n=== RESUMEN FINAL ===\n\n")

cat("DATASET TITANIC SURVIVAL:\n")
cat(sprintf("  • Total pasajeros: %d\n", n_total))
cat(sprintf("  • Train: %d | Test: %d\n", nrow(train), nrow(test)))
cat(sprintf("  • Tasa supervivencia real: %.1f%%\n\n", 
            prop_clases_raw["Survived"]))

cat("ÁRBOL DE DECISIÓN (rpart):\n")
if (!is.null(arbol_titanic$variable.importance)) {
  cat(sprintf("  • Variable más importante: %s\n", 
              names(arbol_titanic$variable.importance)[1]))
}
cat(sprintf("  • Número de nodos: %d\n\n", nrow(arbol_titanic$frame)))

cat("PERFORMANCE EN TEST SET:\n")
cat(sprintf("  • Accuracy:    %.4f (%.2f%%)\n", accuracy, accuracy * 100))
cat(sprintf("  • Precision:   %.4f (%.2f%%)\n", precision, precision * 100))
cat(sprintf("  • Recall:      %.4f (%.2f%%)\n", recall, recall * 100))
cat(sprintf("  • F1-Score:    %.4f\n", f1_score))
cat(sprintf("  • AUC:         %.4f\n\n", auc_value))

cat("INTERPRETACIÓN:\n")
if (auc_value > 0.85) {
  cat("  ✓ El modelo tiene un performance MUY BUENO\n")
  cat("  ✓ Las variables sociodemográficas son muy predictivas\n")
} else if (auc_value > 0.75) {
  cat("  ✓ El modelo tiene un performance BUENO\n")
  cat("  ✓ Hay patrones claros en los datos históricos\n")
} else {
  cat("  ⚠ El modelo tiene un performance ACEPTABLE\n")
  cat("  ⚠ Podría mejorarse con feature engineering o modelos más complejos\n")
}

cat("\n=============================================================================\n")
cat("                        FIN DEL ANÁLISIS                                     \n")
cat("=============================================================================\n\n")

cat("PRÓXIMOS PASOS SUGERIDOS:\n\n")
cat("1. Feature Engineering:\n")
cat("   • Extraer 'Title' del nombre (Mr., Mrs., Miss., Master.)\n")
cat("   • Crear variable 'FamilySize' = SibSp + Parch + 1\n")
cat("   • Crear variable 'IsAlone' (FamilySize == 1)\n")
cat("   • Agrupar tarifas en rangos (low/medium/high fare)\n\n")

cat("2. Comparar con otros algoritmos:\n")
cat("   • Logistic Regression (baseline interpretable)\n")
cat("   • Random Forest (ensemble de árboles)\n")
cat("   • XGBoost (gradient boosting)\n")
cat("   • SVM (Support Vector Machine)\n\n")

cat("3. Análisis de Fairness:\n")
cat("   • Calcular Disparate Impact Ratio entre grupos\n")
cat("   • Evaluar Equal Opportunity (igual TPR para ambos sexos)\n")
cat("   • Considerar técnicas de debiasing (reweighting, resampling)\n\n")

cat("4. Validación más robusta:\n")
cat("   • K-Fold Cross-Validation (en lugar de single split)\n")
cat("   • Stratified CV para mantener balance de clases\n\n")

cat("5. Interpretabilidad:\n")
cat("   • Analizar reglas de decisión del árbol\n")
cat("   • Identificar casos mal clasificados\n")
cat("   • SHAP values para explicar predicciones individuales\n\n")

cat("✓ Script ejecutado exitosamente\n\n")

cat("=============================================================================\n")
cat("REFLEXIÓN FINAL:\n")
cat("El modelo del Titanic es un recordatorio de que los datos históricos\n")
cat("contienen sesgos de su época. Como científicos de datos, debemos:\n")
cat("  1. Reconocer estos sesgos explícitamente\n")
cat("  2. Evaluar el impacto en diferentes grupos\n")
cat("  3. Considerar las implicaciones éticas de nuestros modelos\n")
cat("  4. Buscar equidad además de exactitud\n")
cat("=============================================================================\n")
