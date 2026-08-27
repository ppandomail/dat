# Documento R Markdown: Comparación de Paradigmas en R

**Curso:** Aplicaciones de Ciencia de Datos (07102)  
**Institución:** Universidad Nacional del Oeste  
**Año:** 2025

---

## 📄 Descripción

Este documento R Markdown (`comparacion_paradigmas_R.Rmd`) es un recurso pedagógico completo e interactivo que combina:

- ✅ **Explicaciones teóricas** detalladas
- ✅ **Código ejecutable** que se puede modificar
- ✅ **Benchmarks reales** con datos sintéticos
- ✅ **Gráficos interactivos** generados dinámicamente
- ✅ **Tablas comparativas** estilizadas
- ✅ **Ejemplos prácticos** paso a paso

Al renderizarse, produce un **documento HTML** autocontenido que puede:
- Compartirse con estudiantes
- Abrirse en cualquier navegador
- Imprimirse o exportarse a PDF
- Usarse como material de referencia

---

## 🚀 Inicio Rápido

### Opción 1: Renderizado Automático (Recomendado)

```r
# Desde R o RStudio, ejecuta:
source("renderizar_documento.R")
```

Este script:
1. ✓ Verifica e instala paquetes automáticamente
2. ✓ Renderiza el documento a HTML
3. ✓ Muestra información del proceso
4. ✓ Ofrece abrir el resultado automáticamente

**Tiempo estimado:** 5-10 minutos

### Opción 2: Renderizado Manual

```r
# Instalar paquetes (una sola vez)
install.packages(c("rmarkdown", "knitr", "data.table", "dplyr", 
                   "readr", "ggplot2", "tidyr", "microbenchmark", 
                   "kableExtra"))

# Renderizar
library(rmarkdown)
render("comparacion_paradigmas_R.Rmd")
```

### Opción 3: Desde RStudio

1. Abre `comparacion_paradigmas_R.Rmd` en RStudio
2. Haz clic en el botón **"Knit"** (o Ctrl/Cmd + Shift + K)
3. Espera a que se genere el HTML
4. Se abrirá automáticamente en el visor

---

## 📦 Requisitos

### Software Necesario

- **R:** Versión 4.0 o superior
- **RStudio:** Recomendado (no obligatorio)
- **Navegador web:** Para ver el HTML

### Paquetes de R

```r
# Se instalan automáticamente al ejecutar renderizar_documento.R
# O manualmente:
install.packages(c(
  "rmarkdown",      # Renderizado de documentos
  "knitr",          # Procesamiento de código
  "data.table",     # Manipulación de datos eficiente
  "dplyr",          # Tidyverse - manipulación
  "readr",          # Tidyverse - importación
  "ggplot2",        # Gráficos
  "tidyr",          # Tidyverse - reestructuración
  "microbenchmark", # Benchmarks precisos
  "kableExtra"      # Tablas HTML estilizadas
))
```

### Hardware Recomendado

- **RAM:** 8 GB mínimo (el documento genera un dataset de 1M filas)
- **Espacio:** ~100 MB libres en disco
- **Procesador:** Cualquier CPU moderna (i3 o superior)

---

## 📚 Contenido del Documento

### Secciones Principales

1. **Introducción**
   - Contexto de los tres paradigmas
   - Objetivos de aprendizaje
   - Preparación del ambiente

2. **Generación de Dataset**
   - Dataset sintético de 1M filas
   - Datos realistas de ventas
   - Estadísticas descriptivas

3. **Comparación Sintáctica**
   - Importación de datos
   - Selección de columnas
   - Filtrado de filas
   - Creación de columnas
   - Agregaciones

4. **Benchmark de Rendimiento**
   - Importación
   - Filtrado
   - Agregación
   - Creación de columnas
   - Visualizaciones

5. **Análisis de Casos de Uso**
   - Tabla comparativa completa
   - Recomendaciones por escenario
   - Mejores prácticas

6. **Conclusiones**
   - Hallazgos clave
   - Guías prácticas
   - Recursos adicionales

---

## 🎨 Características del HTML Generado

### Diseño y Estilo

- ✅ **Tabla de contenidos flotante** para navegación fácil
- ✅ **Tema Cosmo** moderno y profesional
- ✅ **Resaltado de sintaxis Tango** para código
- ✅ **Cajas de información** coloreadas (info, warning, success)
- ✅ **Tablas estilizadas** con Bootstrap
- ✅ **Gráficos de alta resolución**
- ✅ **Código plegable** (se puede ocultar/mostrar)

### Funcionalidades

- 🔍 **Búsqueda en tabla de contenidos**
- 📱 **Diseño responsive** (funciona en móviles)
- 💾 **Todo en un archivo** (autocontenido, no requiere internet)
- 🖨️ **Imprimible** o exportable a PDF desde navegador
- 📊 **Gráficos interactivos** (hover para detalles)

---

## 🔧 Personalización

### Modificar el Contenido

Edita el archivo `.Rmd` y busca estas secciones:

```yaml
---
title: "Tu Título Aquí"              # Cambiar título
author: "Tu Nombre"                  # Cambiar autor
date: "`r Sys.Date()`"              # Fecha automática
---
```

### Cambiar Tamaño del Dataset

En el chunk `generar-dataset`:

```r
n_filas <- 1000000  # Cambiar a 500000 para más rápido
                    # o 5000000 para benchmarks más dramáticos
```

### Ajustar Tema Visual

En el YAML header:

```yaml
output:
  html_document:
    theme: cosmo  # Opciones: default, cerulean, journal, 
                  # flatly, darkly, readable, spacelab, 
                  # united, cosmo, lumen, paper, sandstone
```

### Modificar Gráficos

Los gráficos se pueden personalizar en sus respectivos chunks:

```r
# Busca chunks con:
# ```{r nombre-del-grafico}
# ... código de ggplot2 ...
# ```
```

---

## 🎓 Uso Pedagógico

### Para Docentes

**Antes de Clase:**
1. Renderiza el documento con tiempo de anticipación
2. Revísalo completamente navegando por las secciones
3. Identifica puntos clave para enfatizar
4. Prepara preguntas de reflexión

**Durante la Clase:**
- Proyecta el HTML en pantalla completa
- Usa la tabla de contenidos para saltar entre secciones
- Enfatiza los gráficos de benchmark (son muy visuales)
- Muestra ejemplos de código en vivo si hay tiempo
- Permite que los estudiantes sigan en sus computadoras

**Después de Clase:**
- Comparte el HTML con los estudiantes (email o campus virtual)
- Sugiere que exploren el código fuente (.Rmd)
- Propón ejercicios: "Modifica X y observa Y"
- Disponible para consultas sobre el material

### Para Estudiantes

**Formas de Usar este Material:**

1. **Lectura pasiva:** 
   - Abre el HTML y lee como un libro
   - Revisa los ejemplos de código
   - Estudia los benchmarks

2. **Experimentación activa:**
   - Abre el .Rmd en RStudio
   - Ejecuta los chunks individualmente (Ctrl/Cmd + Enter)
   - Modifica valores y observa cambios
   - Re-renderiza y compara resultados

3. **Referencia rápida:**
   - Busca en la tabla de contenidos
   - Copia ejemplos de código para tus proyectos
   - Consulta las tablas comparativas

**Ejercicios Sugeridos:**

1. Cambia `n_filas` a 100,000 y observa cómo cambian los benchmarks
2. Agrega una nueva operación de benchmark (ej: ordenamiento)
3. Crea tus propias secciones con ejemplos adicionales
4. Modifica los gráficos (colores, etiquetas, tipo)
5. Exporta a PDF y compara el resultado

---

## 📊 Archivos Generados

Después de renderizar, encontrarás:

```
📁 Tu directorio de trabajo
├── 📄 comparacion_paradigmas_R.Rmd          # Código fuente (editable)
├── 🌐 comparacion_paradigmas_R.html         # Documento final (compartible)
└── 📁 comparacion_paradigmas_R_files/       # Carpeta de recursos
    ├── figure-html/                         # Gráficos generados
    └── libs/                                # Librerías JavaScript/CSS
```

**Importante:** Para compartir el documento:
- Opción 1: Solo el HTML (funciona si no hay recursos externos)
- Opción 2: HTML + carpeta `_files` (recomendado para gráficos pesados)
- Opción 3: Subir a RPubs o GitHub Pages (público online)

---

## 🐛 Troubleshooting

### Error: "No se puede asignar vector de tamaño X MB"

**Problema:** Memoria RAM insuficiente  
**Solución:** Reduce `n_filas` en el documento:

```r
n_filas <- 500000  # En lugar de 1000000
```

### Error: "Paquete 'X' no está disponible"

**Problema:** Paquete faltante  
**Solución:** Instala manualmente:

```r
install.packages("nombre_del_paquete")
```

### El renderizado es muy lento

**Problema:** Dataset grande + benchmarks toman tiempo  
**Soluciones:**
1. Reduce `n_filas` a 500,000
2. Reduce `times = 20` a `times = 5` en benchmarks
3. Cierra otras aplicaciones para liberar RAM

### Error: "pandoc: command not found"

**Problema:** RStudio no encuentra Pandoc  
**Solución:** Instala RStudio (incluye Pandoc) o instala Pandoc separadamente

### Los gráficos no se ven bien

**Problema:** Resolución o tamaño incorrecto  
**Solución:** Ajusta en el chunk setup:

```r
knitr::opts_chunk$set(
  fig.width = 12,   # Aumentar ancho
  fig.height = 8    # Aumentar altura
)
```

---

## 🔗 Integración con Otros Materiales

Este documento R Markdown complementa:

| Material | Cuándo Usar | Relación |
|----------|-------------|----------|
| `Manejo_Datos_R_*.pptx` | Presentación en clase | Visión general, este doc tiene detalles |
| `ejecutar_benchmark_completo.R` | Análisis independiente | Similar pero sin narrativa |
| `demo_rapida_clase.R` | Demo en vivo | Versión simplificada del benchmark aquí |
| `generar_dataset_benchmark.R` | Generar datos propios | Mismo dataset que este doc genera |

**Flujo Recomendado:**
1. **Clase 1:** Presentación PowerPoint (conceptos)
2. **Clase 2:** Demo rápida en vivo (ver diferencias)
3. **Tarea:** Leer este documento HTML
4. **Clase 3:** Discusión basada en el documento
5. **Proyecto:** Aplicar a datos propios usando los scripts

---

## 📖 Cómo Citar

Si usas este material en tu investigación o enseñanza:

```
Material de Curso: Comparación de Paradigmas en R
Aplicaciones de Ciencia de Datos (07102)
Universidad Nacional del Oeste
2025
```

---

## 🤝 Contribuciones

### Mejoras Sugeridas

Si encuentras errores o tienes sugerencias:

1. Documenta el problema o mejora
2. Si es un error, incluye el mensaje de error completo
3. Si es una mejora, explica el beneficio pedagógico
4. Contacta al docente del curso

### Ideas de Extensión

Posibles adiciones al documento:

- [ ] Sección sobre joins (merge, left_join, etc.)
- [ ] Comparación de visualización de datos
- [ ] Ejemplos con datos reales (no sintéticos)
- [ ] Sección sobre paralelización
- [ ] Integración con bases de datos (SQL)
- [ ] Manejo de datos tipo "long" vs "wide"

---

## ⚡ Tips Avanzados

### Renderizar a Múltiples Formatos

```r
# HTML (default)
render("comparacion_paradigmas_R.Rmd", output_format = "html_document")

# PDF (requiere LaTeX instalado)
render("comparacion_paradigmas_R.Rmd", output_format = "pdf_document")

# Word
render("comparacion_paradigmas_R.Rmd", output_format = "word_document")
```

### Publicar Online

```r
# Opción 1: RPubs (gratis, público)
library(rsconnect)
rpubsUpload("Comparación R", "comparacion_paradigmas_R.html")

# Opción 2: GitHub Pages
# 1. Sube el HTML a un repo de GitHub
# 2. Activa GitHub Pages en Settings
# 3. Accede vía: username.github.io/repo/archivo.html
```

### Automatizar Actualización

Crea un script que regenere el documento periódicamente:

```r
# actualizar_documento.R
source("renderizar_documento.R")

# Agendar con cron (Linux/Mac) o Task Scheduler (Windows)
# para ejecutar semanalmente y mantener datos actualizados
```

---

## 📋 Checklist de Uso

### Primera Vez

- [ ] Paquetes de R instalados
- [ ] Documento renderizado exitosamente
- [ ] HTML se abre correctamente en navegador
- [ ] Todos los gráficos se ven bien
- [ ] Tablas formateadas correctamente

### Antes de Compartir con Estudiantes

- [ ] Información del curso actualizada (año, docente, etc.)
- [ ] Todos los enlaces funcionan
- [ ] Ejemplos relevantes al contexto del curso
- [ ] Nivel de dificultad apropiado
- [ ] Instrucciones claras para uso

### Para Modificaciones

- [ ] Backup del .Rmd original
- [ ] Cambios documentados
- [ ] Código probado antes de renderizar
- [ ] Sin errores de knitting
- [ ] Resultado visual revisado

---

## 📞 Soporte

### Para Estudiantes

**Preguntas sobre contenido:**
- Contacta al docente durante horario de consulta
- Usa el foro del campus virtual
- Revisa la sección de conclusiones del documento

**Problemas técnicos:**
- Revisa la sección Troubleshooting de este README
- Consulta la documentación de los paquetes
- Busca en Stack Overflow: [r] + [rmarkdown]

### Para Docentes

**Adaptaciones al curso:**
- Modifica el YAML header para personalizar
- Ajusta ejemplos al contexto local
- Contacta al autor original para dudas

---

## 📜 Licencia

Este material es de uso educativo libre para:
- ✅ Estudiantes de la UNO
- ✅ Docentes en contexto académico
- ✅ Modificación con atribución

---

## 🎯 Objetivos Cumplidos

Al usar este documento, tus estudiantes podrán:

✅ Entender las diferencias fundamentales entre paradigmas  
✅ Escribir código en R base, Tidyverse y data.table  
✅ Tomar decisiones informadas sobre qué herramienta usar  
✅ Optimizar código para rendimiento  
✅ Evaluar trade-offs entre legibilidad y velocidad  
✅ Aplicar mejores prácticas en proyectos reales  

---

**¡Éxito con tu enseñanza! 🚀**

_Universidad Nacional del Oeste - Aplicaciones de Ciencia de Datos - 2025_
