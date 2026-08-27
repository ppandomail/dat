# Trabajo Práctico 2
  
#Grupo 3 = {Lic. Leticia Sosa, Ing. Federico Czerniawski, Mg. Ing. Pablo Pandolfo} 
#Setiembre 2025 


## Exploración y Análisis de datos
library(ggplot2)
library(readxl)
library(GGally)
library(ResourceSelection)
library(DescTools)
library(caret)
library(ROCR)
library(gridExtra)
library(car)
library(dplyr)
library(corrplot)
library(e1071)
library(class)
library(fastDummies)
library(knitr)
  
setwd('G:/Mi unidad/Académicos/Posgrado_CienciasDeDatos/Modelos_Aprendizaje_Automatico/TP_Final')
getwd()

datos = read.csv("cancelacion.csv", header=TRUE, sep=";")
  
  # Se elimina variable id
  datos <- datos[, -1]
 
  # Se renombran las variables
  colnames(datos) <- c("dias_permanencia", "packtv", "min_llam", "total_llam", "carga_extra", "hs_sin_conexion", "reclamos", "llam_internac", "tiempo_internac", "dias_cortes", "cancela")
  head(datos)
  
  # Se visualiza la estructura de datos
  summary(datos)
  # Se verifica existencia de datos faltantes
  sum(is.na(datos))
  # Se observa un único dato faltante en la variable **hs_sin_conexion**, por ser sólo uno se decide eliminar
  
  # Se omite el caso con el dato faltante
  datos <- na.omit(datos)
  sum(is.na(datos))
  str(datos)
  
  # Se observa que las variables **packtv** y **cancela** son categóricas, por lo que se las convierte en factor
  datos$packtv <- as.factor(datos$packtv)
  datos$cancela <- as.factor(datos$cancela)
  summary(datos)
  
  
  
  # Se analizan las correlaciones
  varNumericas <- select_if(datos, is.numeric)
  correl <- cor(varNumericas)
  corrplot(correl, method="color",  tl.col="black", tl.cex=0.8)
  corrplot(correl, method="number", tl.col="black", tl.cex=0.8)
  # Se observa que las variables **carga_extra** y **min_llam** presentan alta correlación. Esto  tiene sentido ya que mientras más minutos consuma el usuario más necesidad tendrá de contratar carga extra 
  
  # Análisis de cada variable con respecto a cancela
  myplot <- function(yname, nomcol) {
    ggplot(data = datos, aes(y = yname), colour = factor(cancela)) +
      geom_boxplot(aes(x = cancela, fill = factor(cancela))) +
      xlab("cancela") + ylab(nomcol) +
      theme(axis.text.x = element_blank(), axis.ticks = element_blank(),
            axis.line = element_line(colour = "royalblue", linewidth = 0.5, linetype = "solid")) +
      labs(fill = "cancela") + scale_fill_brewer(palette="BuPu")
  }
  myplot(datos$dias_permanencia, 'dias_permanencia')
  myplot(datos$min_llam, 'min_llam')
  myplot(datos$total_llam, 'total_llam')
  myplot(datos$carga_extra, 'carga_extra')
  myplot(datos$hs_sin_conexion, 'horas_sin_conexion')
  myplot(datos$reclamos, 'reclamos')
  myplot(datos$llam_internac, 'llam_internac')
  myplot(datos$tiempo_internac, 'tiempo_internac')
  myplot(datos$dias_cortes, 'dias_cortes')
  # Se observa que las variables **dias_permanencia**, **min_llam**, **hs_sin_conexion** y **llam_internac** presentan datos atípicos que deberán ser analizados
  
  #plot(datos$hs_sin_conexion, datos$dias_permanencia)
  #plot(datos$min_llam, datos$llam_internac)
  
  #Se grafican las variables con outliers
  ggplot(datos, aes(x = hs_sin_conexion, y = dias_permanencia)) +
    geom_point(alpha = 0.6, color = "steelblue") +  # puntos con transparencia y color
    theme_minimal() +                              # tema limpio y minimalista
    labs(title = "hs_sin_conexion vs dias_permanencia",
         x = "Horas sin conexión",
         y = "Días de permanencia") +
    theme(
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(color = "black", size = 10),
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
    )
  
  ggplot(datos, aes(x = min_llam, y = llam_internac)) +
    geom_point(alpha = 0.6, color = "darkorange") +
    theme_minimal() +
    labs(title = "min_llam vs llam_internac",
         x = "Minutos de llamada",
         y = "Llamadas internacionales") +
    theme(
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(color = "black", size = 10),
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
    )
  
  
  datos1 <- datos
  
  
  ###################################################################
  ###################################################################
  #Análisis con los outliers
  
  ## Conjunto de entrenamiento y test
  set.seed(0123)
  index <- createDataPartition(datos1$cancela, p = 0.7, list = FALSE)
  train <- datos1[index, ]
  test <- datos1[-index, ]
  
  # Cantidad de casos en conjunto train (entrenamiento)
  nrow(train)
  # Cantidad de casos en conjunto test (validación)
  nrow(test)
  nrow(datos1)
  # Se separó el conjunto de datos original que contaba con 4995 observaciones en dos conjuntos de datos: un conjunto **train** (entrenamiento) con **3497** observaciones y otro conjunto **test** (validación) con **1498**
  #La separación se realizó en forma aleatoria con la proporción **70/30**
  
  
  
  ## Modelos de regresión logística
  mod_full <- glm(formula = cancela ~ ., data = train, family = "binomial")
  summary(mod_full)
  
  # Modelo1: seleccionando con step sobre todas las variables disponibles
  modelo1 <- step(mod_full, direction = "backward", trace = F)
  summary(modelo1)
  # Se ajustó un modelo **modelo1** con todas las variables y con el método Stepwise Backward (Selección hacia Atrás) se seleccionó el mejor modelo que contiene las siguientes variables significativas:
  # - packtv
  # - min_llam
  # - hs_sin_conexion
  # - llam_internac
  # - tiempo_internac
  # - dias_cortes
  # cancela ~ dias_permanencia + packtv + min_llam + carga_extra + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes
  # Comparando contra el **mod_full**, son modelos muy similares en cuanto a la significancia de variables, devianza y el valor de AIC. Optaríamos por el **modelo1** por ser más simple
  
  variables_numericas = colnames(select_if(datos1, is.numeric))
  formula = paste('cancela ~', paste(variables_numericas, collapse = '+'))
  mod_num = glm(formula, data = train, family = "binomial")
  summary(mod_num)
  
  
  # Modelo2: seleccionando con step sobre todas las variables numéricas disponibles
  modelo2 <- step(mod_num, direction = "backward", trace = F)
  summary(modelo2)
  # Considerando solo las variables numéricas se propone el modelo:
  # - cancela ~ dias_permanencia + min_llam + carga_extra + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes
  # Comparando contra el modelo1, son modelos muy similares en cuanto a la significancia de variables, la devianza y el valor de AIC es mejor (menor) en modelo_1.
  # El modelo_1 parece ser superior a modelo_2, claramente el haber eliminado la variable no numérica packtv (que es altamente significativa en el modelo_1) no fue una buena decisión.
  
  
  # Modelo3: se ajusto un modelo con las variables significativas del Modelo1
  modelo3 = glm(cancela ~ packtv + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes, data = train, family = "binomial")
  summary(modelo3)
  
  # Se comparan modelos con AIC
  AIC(mod_full, modelo1, modelo2, modelo3)
  # Según la métrica AIC, el **modelo1** es el que **mejor** se ajusta a los datos y el de menor complejidad (más parsimonioso)
  
  # Se comparan modelos con devianzas
  anova(mod_full, modelo1, modelo2, modelo3)
  # ANOVA se utiliza para comparar la bondad de ajuste de varios modelos anidados (es decir, modelos donde uno es un subconjunto del otro). 
  # Al comparar los cuatro modelos se observa:
  # - mod_full vs modelo1: La devianza residual del modelo1 es levemente mayor pero NO es estadisticamente significativa esa diferencia (p-valor muy alto). El modelo1 es preferible por su parsimonia.
  # modelo1 vs modelo2: La devianza residual del modelo2 es bastante mayor y esa diferencia es altamente signicativa (p-valor menor a 0.05). Se mantiene modelo1 como el mejor.
  # modelo2 vs modelo3: La devianza residual del modelo3 es bastante mayor y esa diferencia es altamente signicativa (p-valor menor a 0.05). Entre ambos, es mejor el modelo2.
  # El modelo1 es el más recomendable en base a la bondad de ajuste, además es más simple que el mod_full (excluye algunas variables no significativas)
  
  
  #Pseudo R2 - Se toma el modelo que tenga las métricas más altas
  PseudoR2(mod_full, c("CoxSnell", "Nagel"))
  PseudoR2(modelo1, c("CoxSnell", "Nagel"))
  PseudoR2(modelo2, c("CoxSnell", "Nagel"))
  PseudoR2(modelo3, c("CoxSnell", "Nagel"))
  # Refuerza las conclusiones obtenidas anteriormente con anova
  
  #Test de Hosmer-Lemeshow
  hoslem.test(mod_full$y, fitted(mod_full))
  hoslem.test(modelo1$y, fitted(modelo1))
  hoslem.test(modelo2$y, fitted(modelo2))
  hoslem.test(modelo3$y, fitted(modelo3))
  # H0: el modelo ajusta los datos
  # H1: el modelo no ajusta los datos
  # p-valor muy pequeño, se rechaza H0. El modelo no se ajusta bien a los datos.
  # El modelo3 da un mejor valor de ajuste con respecto a los otros modelos pero basandonos en los resultados de los tests anteriores, tomamos la decisión de mantener el modelo1 
  
 
  
  ############################################################
  ################################################
  #Repetimos el análisis sin los outliers
  
  
  # Se eliminan los outliers detectados
  datos <- datos[-which(datos$min_llam > 1000), ]
  datos <- datos[-which(datos$llam_internac < -5), ]
  datos <- datos[-which(datos$dias_permanencia > 1000), ]
  datos <- datos[-which(datos$hs_sin_conexion < -10), ]
  summary(datos)
  
  ## Conjunto de entrenamiento y test
  set.seed(0123)
  index <- createDataPartition(datos$cancela, p = 0.7, list = FALSE)
  train <- datos[index, ]
  test <- datos[-index, ]
  
  # Cantidad de casos en conjunto train (entrenamiento)
  nrow(train)
  # Cantidad de casos en conjunto test (validación)
  nrow(test)
  nrow(datos)
  # Se separó el conjunto de datos original que contaba con 4995 observaciones en dos conjuntos de datos: un conjunto **train** (entrenamiento) con **3497** observaciones y otro conjunto **test** (validación) con **1498**
  #La separación se realizó en forma aleatoria con la proporción **70/30**
  
  ## Modelos de regresión logística
  mod_full <- glm(formula = cancela ~ ., data = train, family = "binomial")
  summary(mod_full)
 
  # Modelo1: seleccionando con step sobre todas las variables disponibles
  modelo1 <- step(mod_full, direction = "backward", trace = F)
  summary(modelo1)
  # Se ajustó un modelo **modelo1** con todas las variables y con el método Stepwise Backward (Selección hacia Atrás) se seleccionó el mejor modelo que contiene las siguientes variables significativas:
  # - packtv
  # - hs_sin_conexion
  # - llam_internac
  # - tiempo_internac
  # - dias_cortes
  # cancela ~ dias_permanencia + packtv + min_llam + carga_extra + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes
  # Comparando contra el **mod_full**, son modelos muy similares en cuanto a la significancia de variables, devianza y el valor de AIC. Optaríamos por el **modelo1** por ser más simple
 
  variables_numericas = colnames(select_if(datos, is.numeric))
  formula = paste('cancela ~', paste(variables_numericas, collapse = '+'))
  mod_num = glm(formula, data = train, family = "binomial")
  summary(mod_num)
  
  
  # Modelo2: seleccionando con step sobre todas las variables numéricas disponibles
  modelo2 <- step(mod_num, direction = "backward", trace = F)
  summary(modelo2)
  # Considerando solo las variables numéricas se propone el modelo:
  # - cancela ~ dias_permanencia + min_llam + carga_extra + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes
  # Comparando contra el modelo1, son modelos muy similares en cuanto a la significancia de variables, la devianza y el valor de AIC es mejor (menor) en modelo_1.
  # El modelo_1 parece ser superior a modelo_2, claramente el haber eliminado la variable no numérica packtv (que es altamente significativa en el modelo_1) no fue una buena decisión.
  
  
  # Modelo3: se ajusto un modelo con las variables significativas del Modelo1
  modelo3 = glm(cancela ~ packtv + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes, data = train, family = "binomial")
  summary(modelo3)
  
  # Se comparan modelos con AIC
  AIC(mod_full, modelo1, modelo2, modelo3)
  # Según la métrica AIC, el **modelo1** es el que **mejor** se ajusta a los datos y el de menor complejidad (más parsimonioso)
 
  # Se comparan modelos con devianzas
  anova(mod_full, modelo1, modelo2, modelo3)
  # ANOVA se utiliza para comparar la bondad de ajuste de varios modelos anidados (es decir, modelos donde uno es un subconjunto del otro). 
  # Al comparar los cuatro modelos se observa:
    # - mod_full vs modelo1: La devianza residual del modelo1 es levemente mayor pero NO es estadisticamente significativa esa diferencia (p-valor muy alto). El modelo1 es preferible por su parsimonia.
  # modelo1 vs modelo2: La devianza residual del modelo2 es bastante mayor y esa diferencia es altamente signicativa (p-valor menor a 0.05). Se mantiene modelo1 como el mejor.
  # modelo2 vs modelo3: La devianza residual del modelo3 es bastante mayor y esa diferencia es altamente signicativa (p-valor menor a 0.05). Entre ambos, es mejor el modelo2.
  # El modelo1 es el más recomendable en base a la bondad de ajuste, además es más simple que el mod_full (excluye algunas variables no significativas)
  
  
  #Pseudo R2 - Se toma el modelo que tenga las métricas más altas
  PseudoR2(mod_full, c("CoxSnell", "Nagel"))
  PseudoR2(modelo1, c("CoxSnell", "Nagel"))
  PseudoR2(modelo2, c("CoxSnell", "Nagel"))
  PseudoR2(modelo3, c("CoxSnell", "Nagel"))
  # Refuerza las conclusiones obtenidas anteriormente con anova
  
  #Test de Hosmer-Lemeshow
  hoslem.test(mod_full$y, fitted(mod_full))
  hoslem.test(modelo1$y, fitted(modelo1))
  hoslem.test(modelo2$y, fitted(modelo2))
  hoslem.test(modelo3$y, fitted(modelo3))
  # H0: el modelo ajusta los datos
  # H1: el modelo no ajusta los datos
  # p-valor muy pequeño, se rechaza H0. El modelo no se ajusta bien a los datos.
  # El modelo3 da un mejor valor de ajuste con respecto a los otros modelos pero basandonos en los resultados de los tests anteriores, tomamos la decisión de mantener el modelo1 

  ##Como los resultados son muy similares, se decide continuar con el conjunto de datos sin los outliers
  ###########################################################################
  ##########################################################################
  
  ## Análisis del modelo elegido
  # El modelo1 es el modelo elegido
  # Fórmula: cancela ~ dias_permanencia + packtv + min_llam + carga_extra + hs_sin_conexion + llam_internac + tiempo_internac +   dias_cortes
  
  
  ### Variables significativas
  # Según el test de Wald, las variables más significativas son: 
    # - packtv (categórica)
    # - hs_sin_conexion
    # - llam_internac
    # - tiempo_internac
    # - dias_cortes
  
  
  ### Test de bondad de ajuste
  # Se hizo el test de bondad de ajuste con ANOVA, comparando los 4 modelos en evaluación.
  # Se llegó a la conclusión de que el modelo1 es el modelo estadístico que mejor se ajusta al conjunto de entrenamiento.
  # Si bien, no es el modelo con menor devianza residual (variabilidad que no hay sido explicada por el modelo), es el más equilibrado (+parsimonioso).
  # Además la diferencia de devianza con el mod_full no es estadísticamente significativa.
  ### Interpretación de coeficiente
  # **packtv**: Indica que tener el pack de tv contratado (packtv = yes) reduce la probabilidad de cancelar. Odds ratio = exp(-0.94) = 0.39
  # **hs_sin_conexion**: Indica que por cada hora sin conexión aumenta la probabilidad de cancelar. Odds ratio = exp(0.07) = 1.08
  # **llam_internac**: Indica que por cada llamada internacional realizada disminuye la probabilidad de cancelar. Odds ratio = exp(-0.06) = 0.93
  # **tiempo_internac**: Indica que si hay más tiempo de llamada internacional aumenta la probabilidad de cancelar. Odds ratio = exp(0.30) = 1.36
  # **dias_cortes**: Indica que más días de cortes aumenta la probabilidad de cancelar. Odds ratio = exp(0.05) = 1.06
  
  
  ### Multicolinealidad
  vif(modelo1)
  # Se observa una alta multicolinealidad en las variables **min_llam** y **carga_extra** por lo que se procederá a ajustar nuevos modelos sin esas variables juntas para comparar el comportamiento
  modelo1_sin_min_llam <- glm(cancela ~ dias_permanencia + packtv + carga_extra + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes, data = train, family = "binomial")
  modelo1_sin_carga_extra <- glm(cancela ~ dias_permanencia + packtv + min_llam + hs_sin_conexion + llam_internac + tiempo_internac + dias_cortes, data = train, family = "binomial")
  AIC(modelo1, modelo1_sin_min_llam, modelo1_sin_carga_extra)
  anova(modelo1, modelo1_sin_min_llam, modelo1_sin_carga_extra)
  # Comparando modelo1 con modelo1_sin_min_llam vemos que la devianza aumenta en 2.41 unidades y el p-valor no es estadisticamente significativo
  # Esto indica que eliminar esa variable no empeora significativamente el ajuste, por lo que esa variable puede ser prescindible
  # Entre los modelos: modelo1_sin_min_llam y modelo1_sin_carga_extra no hay diferencia en la devianza, por lo que sería lo mismo elegir cualquiera de esos modelos
  
  # Elegimos el modelo1_sin_carga_extra
  vif(modelo1_sin_carga_extra)
  
  
  ### Datos influyentes
  #par(mfrow = c(2,2))
  #plot(modelo1_sin_carga_extra)
  #par(mfrow = c(1,1))
  #car::influenceIndexPlot(modelo1_sin_carga_extra, vars = "Cook", id=T, main = "Cook's distance")
  #influenceIndexPlot(modelo1_sin_carga_extra, vars = "hat", id=T, main = "Leverages")
  
  par(mfrow = c(1,1), mar = c(5,5,3,2) + 0.1)
  car::influenceIndexPlot(modelo1_sin_carga_extra, vars = "Cook", id = TRUE,
                          main = "Cook's Distance",
                          col = "darkred", pch = 19, cex = 1.2)
  car::influenceIndexPlot(modelo1_sin_carga_extra, vars = "hat", id = TRUE,
                          main = "Leverages",
                          col = "steelblue", pch = 19, cex = 1.2)
  
  # Se observa que no hay datos influyentes, ya que fueron quitados en el análisis preliminar
  
  
  #Evaluar Independencia de las observaciones
  # Calcular residuos tipo 'response' y valores ajustados
  residualData <- tibble(
    resid = residuals(modelo1_sin_carga_extra, type = "response"),
    fitted = fitted(modelo1_sin_carga_extra)
  )
  
  # Graficar residuos vs valores ajustados
  ggplot(residualData, aes(x = fitted, y = resid)) +
    geom_point(alpha = 0.3) +
    xlab("Valores ajustados (probabilidad estimada)") +
    ylab("Residuos de respuesta") +
    ggtitle("Residuos vs Valores Ajustados para evaluar independencia") +
    theme_minimal()
  
  # Calcular residuos de desviación (deviance residuals)
  residuos <- residuals(modelo1_sin_carga_extra, type = "deviance")
  
  # Gráfico residuos vs índice
  plot(residuos, pch = 19, col = "steelblue",
       xlab = "Índice de observación", ylab = "Residuos deviance",
       main = "Grafico de residuos para evaluar independencia")
  abline(h = 0, col = "darkred", lty = 2)
  
  
  ## Métodos de clasificación
  
  ### Naive Bayes
  set.seed(0123)
  mod_bayes <- naiveBayes(cancela ~ ., data = train, laplace = 0)
  mod_bayes
  
  
  ### knn
  set.seed(0123)
  knnEntrenadoNum <- train(cancela ~ . -packtv, 
                           data = train, 
                           method = "knn",  
                           tuneLength = 10, # opcion para decir #valores de k que le pido que pruebe
                           trControl = trainControl(method="cv", number = 5),
                           preProcess = c("center","scale")
  )
  knnEntrenadoNum
  
  ## Se convierte factores en dummies
  datos_dummies <- dummy_cols(datos, select_columns = c("packtv"),
                              remove_selected_columns = T, remove_first_dummy = T)
  summary(datos_dummies)
  train2 <- datos_dummies[index, ]
  test2 <- datos_dummies[-index, ]
  knnEntrenado <- train(cancela ~ ., 
                        data = train2, 
                        method = "knn",  
                        tuneLength = 20, # opcion para decir #valores de k que le pido que pruebe
                        trControl = trainControl(method = "cv", number = 5),
                        preProcess = c("center","scale")
  )
  knnEntrenado
  # El algoritmo detectó que un valor de k = 7 (vecinos mas cercanos) es el mejor para clasificar casos nuevos
  
  
  ### SVM
  set.seed(0123)
  svm_radial <- tune("svm", cancela ~ ., 
                     data  = train, 
                     probability = TRUE,
                     kernel = 'radial',
                     ranges = list(cost = c(0.01, 1, 5, 10, 50)))
  svm_linear <- tune("svm", cancela ~ ., 
                     data = train, 
                     probability = TRUE,
                     kernel = 'linear',
                     ranges = list(cost = c(0.001, 0.01, 1, 5)))
  svm_polyn <- tune("svm", cancela ~ ., 
                    data = train, 
                    probability = TRUE,
                    kernel = 'polynomial',
                    ranges = list(cost = c(0.01, 1, 5, 10, 50)))
  summary(svm_radial)
  summary(svm_linear)
  summary(svm_polyn)
  
  
  # Se muestra la relación entre errores y Costo
  plot_radial = ggplot(data = svm_radial$performances, aes(x = cost, y = error)) +
    geom_line() +
    geom_point() +
    labs(title = "Kernel Radial - Error de clasificación vs hiperparámetro C") +
    theme_bw()
  
  plot_linear = ggplot(data = svm_linear$performances, aes(x = cost, y = error)) +
    geom_line() +
    geom_point() +
    labs(title = "Kernel Lineal - Error de clasificación vs hiperparámetro C") +
    theme_bw()
  
  plot_polyn = ggplot(data = svm_polyn$performances, aes(x = cost, y = error)) +
    geom_line() +
    geom_point() +
    labs(title = "Kernel Polynomial -Error de clasificación vs hiperparámetro C") +
    theme_bw()
  
  grid.arrange(plot_radial, plot_linear, plot_polyn)
  
  
  ## Análisis y evaluación en Test
  
  confusion_log <- function(nombre, modelo, test) {
    pred <- predict.glm(modelo, newdata = test, type = "response")
    predi_y <- ifelse(pred >= 0.5, "yes", "no")
    tabla <- table(predi_y, test$cancela)
    print(nombre)
    print(tabla)
    return (confusionMatrix(tabla, positive = "yes"))
  }
  confusion_bayes <- function(nombre, modelo, test) {
    pred <- predict(modelo, newdata = test, type = "class")
    tabla <- table(pred, test$cancela)
    print(nombre)
    print(tabla)
    return (confusionMatrix(tabla, positive = "yes"))
  }
  confusion_knn <- function(nombre, modelo, test) {
    pred <- predict(modelo, newdata = test)
    tabla <- table(pred, test$cancela)
    print(nombre)
    print(tabla)
    return (confusionMatrix(tabla, positive = "yes"))
  }
  confusion_svm <- function(nombre, modelo, test) {
    pred <- predict(modelo, test, type = "class")
    tabla <- table(pred, test$cancela)
    print(nombre)
    print(tabla)
    return (confusionMatrix(tabla, positive = "yes"))
  }
  area_roc_log <- function(nombre, modelo, test) {
    pred <- predict.glm(modelo, newdata = test, type = "response") 
    predi <- prediction(pred, test$cancela)
    roc  <- performance(predi, measure = "tpr", x.measure = "fpr")
    plot(roc, main = paste("curva ROC ", nombre), colorize = T)
    abline(a = 0, b = 1)
    return (performance(predi, "auc")@y.values)
  }
  area_roc_bayes <- function(nombre, modelo, test) {
    pred <- predict(modelo, newdata = test, type = "raw")
    predi <- prediction(pred[,2], test$cancela)
    roc <- performance(predi, measure = "tpr", x.measure = "fpr")
    plot(roc, main = paste("curva ROC ", nombre), colorize = T)
    abline(a = 0, b = 1)
    return (performance(predi, "auc")@y.values)
  }
  area_roc_knn <- function(nombre, modelo, test) {
    pred <- predict(modelo, newdata = test , type = "prob")
    predi <- prediction(pred[,2], test$cancela)
    roc <- performance(predi, measure = "tpr", x.measure = "fpr")
    plot(roc, main = paste("curva ROC ", nombre), colorize = T)
    abline(a = 0, b = 1)
    return (performance(predi, "auc")@y.values)
  }
  area_roc_svm <- function(nombre, modelo, test) {
    pred <- predict(modelo, test, type = "prob", probability = TRUE)
    predi <- prediction(attr(pred, "probabilities")[,2], test$cancela)
    roc <- performance(predi, measure = "tpr", x.measure = "fpr")
    plot(roc, main = paste("curva ROC SVM ", nombre), colorize = T)
    abline(a = 0, b = 1)
    return (performance(predi, "auc")@y.values)
  }
  metricas <- function(nombre, conf, area) {
    return (data.frame(
      Model = nombre,
      Accuracy = conf$overall["Accuracy"],
      Sensitivity = conf$byClass["Sensitivity"],
      Specificity = conf$byClass["Specificity"],
      Precision = conf$byClass["Pos Pred Value"],
      Area_ROC  = area[[1]]))
  }
  metricas_log <- function(nombre, modelo, test) {
    return (metricas(nombre, confusion_log(nombre, modelo, test), area_roc_log(nombre, modelo, test)))    
  }
  metricas_bayes <- function(nombre, modelo, test) {
    return (metricas(nombre, confusion_bayes(nombre, modelo, test), area_roc_bayes(nombre, modelo, test)))
  }
  metricas_knn <- function(nombre, modelo, test) {
    return (metricas(nombre, confusion_knn(nombre, modelo, test), area_roc_knn(nombre, modelo, test)))
  }
  metricas_svm <- function(nombre, modelo, test) {
    return (metricas(nombre, confusion_svm(nombre, modelo, test), area_roc_svm(nombre, modelo, test)))
  }
  m_modelo1 <- metricas_log("Regresión", modelo1, test)
  m_bayes <- metricas_bayes("Naive Bayes", mod_bayes, test)
  m_knn <- metricas_knn("KNN", knnEntrenado, test2)
  m_radial <- metricas_svm("Radial", svm_radial$best.model, test)
  m_linear <- metricas_svm("Linear", svm_linear$best.model, test)
  m_polyn <- metricas_svm("Polinomial", svm_polyn$best.model, test)
  m_combinado <- rbind(m_modelo1, m_bayes, m_knn, m_radial, m_linear, m_polyn)
  kable(m_combinado, caption = "Comparación de Métricas entre Modelos", row.names = F)