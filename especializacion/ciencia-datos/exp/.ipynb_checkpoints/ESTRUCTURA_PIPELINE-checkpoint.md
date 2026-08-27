# 📁 Estructura de Carpetas - Pipeline de ML

## 🎯 Objetivo
Este documento describe la estructura de carpetas estándar para proyectos de Machine Learning siguiendo una arquitectura modular y reproducible.

---

## 🏗️ Estructura General

```
proyecto_ml/
│
├── datasets/                    # 📊 Datos originales (RAW)
│   ├── prescripciones.rds
│   ├── medicos.rds
│   └── [otros_datos].rds
│
├── exp/                         # 🔬 Experimentos (todos los pasos del pipeline)
│   │
│   ├── 01_FE/                   # Feature Engineering
│   │   ├── 01_FE_execute.R
│   │   ├── 01_FE_prxs.R
│   │   ├── 01_FE_prxs_01a.yml
│   │   └── prxs_01a/            # Output de este experimento
│   │       └── prescripciones202112_fma6.csv.gz
│   │
│   ├── 02_TS/                   # Training Strategy
│   │   ├── 02_TS_prxs_01a.R
│   │   ├── 02_TS_prxs_01a.yml
│   │   └── prxs_01a/            # Output de este experimento
│   │       ├── TS_train_strategy.csv.gz
│   │       ├── TS_train_final.csv.gz
│   │       ├── TS_future_data.csv.gz
│   │       └── control.txt
│   │
│   ├── 03_HT/                   # Hyperparameter Tuning
│   │   ├── 03_HT_execute_prxs_01a.R
│   │   ├── 03_HT_prxs_01a.yml
│   │   └── prxs_01a/            # Output de este experimento
│   │       ├── BO_log.txt
│   │       ├── impo_1.txt
│   │       ├── impo_7.txt
│   │       ├── impo_12.txt
│   │       └── impo_28.txt
│   │
│   ├── 04_ZZ/                   # Utilidades y Predicción Final
        ├── 04_prediction.R
        └── read_log.R
   

```

---

## 📋 Descripción de Carpetas

### 1️⃣ `datasets/` - Datos Originales
**Propósito:** Almacenar los datos crudos (RAW) sin modificar.

**Contenido típico:**
- Archivos `.rds`, `.csv`, `.parquet`
- Datos de múltiples fuentes
- Datos históricos sin procesar

**⚠️ Regla de oro:** NUNCA modificar estos archivos. Son la fuente de verdad.

**Ejemplo:**
```
datasets/
├── prescripciones.rds          # Datos transaccionales
├── medicos.rds                 # Datos maestros
└── historico_2020_2021.csv     # Datos históricos
```

---

### 2️⃣ `exp/` - Experimentos
**Propósito:** Contener todos los pasos del pipeline de ML de forma modular.

#### 🔧 `01_FE/` - Feature Engineering
**Función:** Crear características (features) a partir de los datos crudos.

**Archivos principales:**
- `01_FE_execute.R`: Ejecutor principal
- `01_FE_prxs.R`: Lógica de ingeniería de características
- `01_FE_prxs_01a.yml`: Configuración del experimento

**Output:** Carpeta `prxs_01a/` con dataset enriquecido

**Procesos típicos:**
- Cálculo de lags (valores pasados)
- Cálculo de deltas (diferencias)
- Tendencias (regresiones lineales en ventanas)
- Ratios y promedios móviles
- Eliminación de canaritos (features ruidosas)

**Ejemplo de configuración (`01_FE_prxs_01a.yml`):**
```yaml
param:
  lags: 
    correr:    [TRUE, TRUE, FALSE]
    lag:       [1, 2, 3]
    delta:     [TRUE, TRUE, FALSE]
  
  tendenciaYmuchomas:
    correr:    [TRUE, TRUE, FALSE]
    ventana:   [6, 3, 12]
    tendencia: [TRUE, TRUE, TRUE]
```

---

#### 🎯 `02_TS/` - Training Strategy
**Función:** Definir la estrategia de entrenamiento (train/validate/test splits).

**Archivos principales:**
- `02_TS_prxs_01a.R`: Lógica de splitting temporal
- `02_TS_prxs_01a.yml`: Configuración de periodos

**Output:** Carpeta `prxs_01a/` con 3 datasets:
1. `TS_train_strategy.csv.gz`: Train + Validate + Test (para optimizar hiperparámetros)
2. `TS_train_final.csv.gz`: Train + Validate + Test (para modelo final)
3. `TS_future_data.csv.gz`: Datos sin clase (para predicción)

**Configuración típica:**
```yaml
param:
  train:
    rango:
      desde: 202001
      hasta: 202104
  
  validate:
    periodos: [202105]
  
  test:
    periodos: [202106]
  
  train_final:
    rango:
      desde: 202001
      hasta: 202106
  
  future:
    periodos: [202112]
```

**📌 Concepto clave:** Splitting temporal para series de tiempo.

---

#### 🔍 `03_HT/` - Hyperparameter Tuning
**Función:** Optimizar hiperparámetros del modelo usando Bayesian Optimization.

**Archivos principales:**
- `03_HT_execute_prxs_01a.R`: Ejecutor de optimización
- `03_HT_prxs_01a.yml`: Configuración de BO y modelo

**Output:** Carpeta `prxs_01a/` con:
- `BO_log.txt`: Log de la optimización bayesiana
- `impo_X.txt`: Importancia de variables en diferentes iteraciones

**Configuración típica:**
```yaml
param:
  lightgbm:
    learning_rate:     [0.02, 0.3]        # Rango para BO
    feature_fraction:  [0.1, 1.0]         # Rango para BO
    num_leaves:        [10, 36000, "integer"]
    min_data_in_leaf:  [0, 100000, "integer"]
    max_depth:  -1                        # Fijo
    seed: 999983                          # Fijo
  
  BO:
    iterations: 50                        # Número de iteraciones BO
```

**📌 Concepto clave:** Optimización bayesiana busca los mejores hiperparámetros en un espacio definido.

---

#### 🎲 `04_ZZ/` - Utilidades
**Función:** Scripts auxiliares y de predicción final.

**Contenido:**
- `04_prediction.R`: Genera predicciones sobre `TS_future_data`
- `read_log.R`: Lee logs de experimentos

---

#### 🤖 `lightGBM/` - Modelos Entrenados
**Función:** Almacenar modelos finales entrenados.

**Estructura:**
```
lightGBM/
└── KA741-prxs_01a/              # ID único del experimento
    ├── KA741-prxs_01a.txt       # Modelo serializado
    └── impo_val.txt             # Importancia final de variables
```

---

## 🔄 Flujo del Pipeline

```
┌─────────────┐
│  datasets/  │  Datos RAW
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   01_FE/    │  Feature Engineering
│  prxs_01a/ │  → Output: dataset enriquecido
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   02_TS/    │  Training Strategy
│  prxs_01a/ │  → Output: train/validate/test/future splits
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   03_HT/    │  Hyperparameter Tuning
│  prxs_01a/ │  → Output: mejores hiperparámetros + importancias
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  lightGBM/  │  Modelo Final Entrenado
│ KA741-...  │  → Output: modelo serializado
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   04_ZZ/    │  Predicción Final
└─────────────┘
```

---

## 🎨 Convención de Nombres

### Experimentos
Formato: `[paso]_[tipo]_[nombre]_[versión].extensión`

**Ejemplos:**
- `01_FE_prxs_01a.yml` → Feature Engineering, prescripciones, versión 01a
- `02_TS_prxs_01a.R` → Training Strategy, prescripciones, versión 01a
- `03_HT_execute_prxs_01a.R` → Hyperparameter Tuning, prescripciones, versión 01a

### Carpetas de Output
Cada paso genera una carpeta con el nombre del experimento:
```
01_FE/
└── prxs_01a/          # Nombre del experimento

02_TS/
└── prxs_01a/          # Mismo nombre (coherencia)

03_HT/
└── prxs_01a/          # Mismo nombre (coherencia)
```

---

## 📝 Archivos de Configuración (.yml)

Cada paso del pipeline tiene un archivo YAML que define:

1. **Metadata del experimento:**
```yaml
experiment:
  name: "prxs_01a"
  type: "FeatureEngineering"
  tags: ["base"]
  description: "Lags2, delta2, tendencia2, media2"
  requires: []              # Dependencias de otros experimentos
```

2. **Parámetros del proceso:**
```yaml
param:
  dummiesNA: FALSE
  lags: [...]
  tendenciaYmuchomas: [...]
```

3. **Archivos de entrada/salida:**
```yaml
  files:
    input:
      dentrada: ["prescripciones.rds"]
    output:
      dsalida: "prescripciones202112_fma6.csv.gz"
```

4. **Configuración del entorno:**
```yaml
environment:
  base_dir: "C:/proyecto_ml/"
  repo_dir: "./datasets"
  exp_dir: "./exp/01_FE"
```

---

## ⚙️ Campo `requires` - Dependencias

**Función:** Especificar qué experimento previo es necesario.

**Ejemplo en `02_TS_prxs_01a.yml`:**
```yaml
experiment:
  requires: "./exp/01_FE/prxs_01a/"    # Necesita output de FE
```

**Ejemplo en `03_HT_prxs_01a.yml`:**
```yaml
experiment:
  requires: "./exp/02_TS/prxs_01a/"    # Necesita output de TS
```

**Ventajas:**
- ✅ Rastreabilidad clara de dependencias
- ✅ Validación automática de inputs
- ✅ Documentación implícita del flujo

---

## 🛠️ Cómo Crear un Nuevo Experimento

### Paso 1: Definir versión
Incrementar la versión del experimento: `prxs_01a` → `prxs_01b`

### Paso 2: Crear archivos
```bash
# En 01_FE/
01_FE_prxs_01b.yml
01_FE_prxs_01b.R       # Si necesitas lógica nueva

# En 02_TS/
02_TS_prxs_01b.yml
# (Reutilizar script si no cambia la lógica)

# En 03_HT/
03_HT_prxs_01b.yml
# (Reutilizar script si no cambia la lógica)
```

### Paso 3: Actualizar `requires`
```yaml
# En 02_TS_prxs_01b.yml
experiment:
  requires: "./exp/01_FE/prxs_01b/"    # Nueva versión

# En 03_HT_prxs_01b.yml
experiment:
  requires: "./exp/02_TS/prxs_01b/"    # Nueva versión
```

### Paso 4: Ejecutar
```r
source("01_FE/01_FE_execute.R")
source("02_TS/02_TS_execute.R")
source("03_HT/03_HT_execute.R")
```

---

## ✅ Checklist de Estructura Correcta

Antes de ejecutar un pipeline, verificar:

- [ ] Los datos RAW están en `datasets/`
- [ ] Cada paso (FE, TS, HT) tiene su carpeta en `exp/`
- [ ] Cada experimento tiene su archivo `.yml`
- [ ] Los `requires` apuntan a la carpeta correcta
- [ ] Los nombres de experimento son consistentes (`prxs_01a` en todos los pasos)
- [ ] Las rutas en `environment` son correctas
- [ ] Los archivos de output tienen nombres únicos

---

## 🚫 Errores Comunes

### ❌ Error 1: Rutas hardcodeadas
```yaml
# MAL
exp_dir: "C:/Users/Juan/proyecto/exp/01_FE"

# BIEN
exp_dir: "./exp/01_FE"
```

### ❌ Error 2: Nombres inconsistentes
```yaml
# MAL
01_FE/ → prxs_01a/
02_TS/ → prxs_v1/          # Nombre diferente
03_HT/ → prxs_experimento/ # Nombre diferente

# BIEN
01_FE/ → prxs_01a/
02_TS/ → prxs_01a/
03_HT/ → prxs_01a/
```

### ❌ Error 3: `requires` apuntando a versión incorrecta
```yaml
# MAL
# En 02_TS_prxs_01b.yml
requires: "./exp/01_FE/prxs_01a/"  # Versión antigua

# BIEN
requires: "./exp/01_FE/prxs_01b/"  # Versión correcta
```

### ❌ Error 4: Modificar datos en `datasets/`
```r
# MAL
data <- readRDS("datasets/prescripciones.rds")
data$nueva_col <- ...
saveRDS(data, "datasets/prescripciones.rds")  # ¡NO!

# BIEN
data <- readRDS("datasets/prescripciones.rds")
data$nueva_col <- ...
# Guardar en exp/01_FE/prxs_01a/
```

---

## 🎯 Ventajas de Esta Estructura

1. **Modularidad:** Cada paso es independiente
2. **Reproducibilidad:** Configuración explícita en `.yml`
3. **Versionado:** Fácil comparar experimentos (01a vs 01b)
4. **Rastreabilidad:** `requires` documenta dependencias
5. **Escalabilidad:** Agregar nuevos pasos es sencillo
6. **Colaboración:** Estructura clara para todo el equipo

---

## 📚 Referencias Rápidas

### Archivos de Input Típicos
- `datasets/*.rds` → Datos RAW
- `exp/01_FE/prxs_01a/*.csv.gz` → Features engineered
- `exp/02_TS/prxs_01a/*.csv.gz` → Splits temporales

### Archivos de Output Típicos
- `exp/03_HT/prxs_01a/BO_log.txt` → Resultados de BO
- `exp/lightGBM/KA*/KA*.txt` → Modelo final
- `exp/04_ZZ/predictions.csv` → Predicciones finales

---

## 💡 Tips Finales

1. **Usa versiones semánticas:** `01a`, `01b`, `02a` en lugar de `v1`, `v2`, `final`
2. **Documenta en `.yml`:** Usa el campo `description` para explicar cambios
3. **Mantén logs:** Cada paso debe generar logs informativos
4. **Automatiza:** Crea scripts `execute` que orquesten todo el pipeline
5. **Valida outputs:** Cada paso debe verificar que el output es correcto

---

## 🔗 Ejemplo Completo de Ejecución

```r
# 1. Feature Engineering
setwd("C:/proyecto_ml/")
source("exp/01_FE/01_FE_execute.R")
# Output: exp/01_FE/prxs_01a/prescripciones202112_fma6.csv.gz

# 2. Training Strategy
source("exp/02_TS/02_TS_prxs_01a.R")
# Output: exp/02_TS/prxs_01a/TS_train_strategy.csv.gz

# 3. Hyperparameter Tuning
source("exp/03_HT/03_HT_execute_prxs_01a.R")
# Output: exp/03_HT/prxs_01a/BO_log.txt

# 4. Predicción
source("exp/04_ZZ/04_prediction.R")
# Output: predictions.csv
```

---

**Última actualización:** 2025-11-01  
**Versión:** 1.0  
**Autor:** Pipeline ML Template
