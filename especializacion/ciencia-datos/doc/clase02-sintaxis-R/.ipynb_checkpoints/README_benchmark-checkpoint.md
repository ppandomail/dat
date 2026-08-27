# Benchmark: R Base vs Tidyverse vs data.table

**Curso:** Aplicaciones de Ciencia de Datos  
**Institución:** Universidad Nacional del Oeste (UNO)  
**Año:** 2025

---

## 📋 Descripción

Este conjunto de scripts permite generar datasets sintéticos y ejecutar benchmarks comparativos entre tres paradigmas de manipulación de datos en R:

- **R Base**: Funciones estándar de R
- **Tidyverse**: Colección de paquetes modernos (dplyr, readr, etc.)
- **data.table**: Paquete optimizado para alto rendimiento

---

## 📁 Archivos Incluidos

| Archivo | Descripción | Uso |
|---------|-------------|-----|
| `generar_dataset_benchmark.R` | Genera dataset sintético de tamaño configurable | Ejecutar primero |
| `demo_rapida_clase.R` | Demostración visual rápida (5-10 min) | Ideal para clase en vivo |
| `ejecutar_benchmark_completo.R` | Benchmark exhaustivo con 7 operaciones | Análisis detallado |

---

## 🚀 Inicio Rápido

### Paso 1: Instalar Paquetes (una sola vez)

```r
# Instalar paquetes necesarios
install.packages(c("data.table", "readr", "dplyr", "ggplot2"))
```

### Paso 2: Generar Dataset

```r
# Ejecutar script de generación
source("generar_dataset_benchmark.R")

# Esto creará un archivo CSV de ~80 MB con 1 millón de filas
# Puedes ajustar el tamaño editando la variable n_filas en el script
```

### Paso 3: Elegir tu Análisis

**Opción A: Demo Rápida (recomendado para clase)**
```r
source("demo_rapida_clase.R")
# Toma 5-10 minutos, ideal para demostración en vivo
```

**Opción B: Benchmark Completo**
```r
source("ejecutar_benchmark_completo.R")
# Toma 10-20 minutos, genera gráficos y tablas detalladas
```

---

## ⚙️ Configuración del Tamaño del Dataset

Edita el archivo `generar_dataset_benchmark.R` y cambia la línea:

```r
n_filas <- 1000000  # 1 millón de filas (~80 MB)
```

### Tamaños Recomendados

| Tamaño | Filas | Espacio en disco | Tiempo de generación | Uso recomendado |
|--------|-------|------------------|----------------------|-----------------|
| Pequeño | 500,000 | ~40 MB | 1-2 min | Demo rápida |
| Mediano | 1,000,000 | ~80 MB | 2-3 min | **Recomendado para clase** |
| Grande | 5,000,000 | ~400 MB | 5-10 min | Diferencias dramáticas |
| Muy grande | 10,000,000 | ~800 MB | 10-20 min | Solo para equipos potentes |

⚠️ **Nota:** Tamaños mayores a 5M requieren al menos 8GB de RAM.

---

## 📊 Operaciones Evaluadas en el Benchmark Completo

1. **Importación**: Leer archivo CSV completo
2. **Filtrado simple**: Seleccionar filas con una condición
3. **Filtrado complejo**: Múltiples condiciones AND
4. **Nueva columna**: Crear columna calculada
5. **Agregación simple**: Promedio por grupo
6. **Agregación compleja**: Múltiples estadísticas por múltiples grupos
7. **Ordenamiento**: Ordenar por columna descendente

---

## 📈 Resultados Esperados

### Con dataset de 1M de filas en PC estándar (i5, 8GB RAM):

| Operación | R Base | Tidyverse | data.table | Ganador |
|-----------|--------|-----------|------------|---------|
| Importación | ~12 seg | ~3.8 seg | **~0.8 seg** | data.table (15x) |
| Filtrado | ~0.5 seg | ~0.3 seg | **~0.1 seg** | data.table |
| Agregación | ~8 seg | ~4 seg | **~0.9 seg** | data.table (9x) |

🏆 **data.table** es el ganador consistente en todas las operaciones.

---

## 🎓 Uso en Clase

### Demo en Vivo (5-10 minutos)

1. Abrir RStudio
2. Ejecutar: `source("demo_rapida_clase.R")`
3. Mostrar la pantalla a los estudiantes
4. Observar las diferencias en tiempo real
5. Discutir implicaciones prácticas

### Puntos Clave para Destacar

✓ **Velocidad no es todo**: A veces la legibilidad importa más  
✓ **Contexto importa**: Datasets pequeños vs. grandes  
✓ **Memoria es clave**: data.table usa modificación por referencia  
✓ **Todas son válidas**: Cada enfoque tiene su lugar  

---

## 💾 Archivos Generados

Después de ejecutar los scripts, encontrarás:

```
📁 Carpeta de trabajo
├── 📄 datos_benchmark_1.0M.csv          # Dataset generado
├── 📄 benchmark_resultados.csv          # Tabla de tiempos
├── 📊 benchmark_comparacion.png         # Gráfico comparativo
└── 📝 README.md                         # Este archivo
```

---

## 🔧 Troubleshooting

### Error: "No se puede asignar vector de tamaño X MB"

**Problema:** No hay suficiente memoria RAM  
**Solución:** Reduce `n_filas` en `generar_dataset_benchmark.R`

### Error: "paquete 'X' no está disponible"

**Problema:** Paquete no instalado  
**Solución:** 
```r
install.packages("nombre_del_paquete")
```

### El script es muy lento

**Problema:** Dataset demasiado grande para tu equipo  
**Solución:** Usa un dataset más pequeño (500K filas)

---

## 📚 Recursos Adicionales

### Documentación Oficial

- **data.table**: https://rdatatable.gitlab.io/data.table
- **Tidyverse**: https://www.tidyverse.org
- **R Base**: Escribe `?read.csv` en la consola de R

### Tutoriales Recomendados

1. **data.table**: 
   ```r
   vignette("datatable-intro")
   vignette("datatable-keys-fast-subset")
   ```

2. **Tidyverse**:
   - R for Data Science: https://r4ds.hadley.nz

### Cheat Sheets

- data.table: https://github.com/rstudio/cheatsheets/blob/main/datatable.pdf
- dplyr: https://github.com/rstudio/cheatsheets/blob/main/data-transformation.pdf

---

## 🎯 Objetivos Pedagógicos

Este material está diseñado para que los estudiantes:

1. ✓ Comprendan las diferencias entre paradigmas de R
2. ✓ Aprendan cuándo usar cada enfoque
3. ✓ Desarrollen intuición sobre rendimiento
4. ✓ Tomen decisiones informadas en proyectos reales

---

## 👥 Para Estudiantes

### Experimentos Sugeridos

1. **Varía el tamaño**: Prueba con 100K, 1M, 5M filas
2. **Mide tu equipo**: ¿Cómo se comporta en tu computadora?
3. **Operaciones reales**: Usa tus propios datos
4. **Combina métodos**: Importa con fread, analiza con dplyr

### Preguntas para Reflexionar

- ¿Cuándo vale la pena aprender data.table?
- ¿La velocidad siempre es lo más importante?
- ¿Cómo afecta el tamaño de datos a la elección?
- ¿Qué pasa con la reproducibilidad del código?

---

## 📝 Notas del Instructor

### Adaptaciones Sugeridas

- **Grupos principiantes**: Usar solo demo_rapida_clase.R
- **Grupos avanzados**: Pedir que modifiquen los scripts
- **Trabajo práctico**: Hacer benchmark con datos propios

### Tiempo Estimado de Clase

| Actividad | Tiempo |
|-----------|--------|
| Introducción teórica | 15 min |
| Demo en vivo | 10 min |
| Discusión | 10 min |
| **Total** | **35 min** |

---

## 🤝 Contribuciones

¿Encontraste un bug o tienes una sugerencia? 

Este material es parte del curso **Aplicaciones de Ciencia de Datos** en la Universidad Nacional del Oeste.

---

## 📄 Licencia

Uso educativo libre para estudiantes y docentes.

---

## 📧 Contacto

**Curso:** Aplicaciones de Ciencia de Datos (07102)  
**Institución:** Universidad Nacional del Oeste  
**Año:** 2025

---

## ✅ Checklist de Uso

Antes de la clase:

- [ ] Paquetes instalados (data.table, readr, dplyr, ggplot2)
- [ ] Dataset generado (ejecutar generar_dataset_benchmark.R)
- [ ] Demo probada (ejecutar demo_rapida_clase.R)
- [ ] RStudio configurado en modo presentación (Zoom In)
- [ ] Proyector/pantalla funcionando

Durante la clase:

- [ ] Explicar contexto y objetivo
- [ ] Ejecutar demo en vivo
- [ ] Mostrar diferencias visualmente
- [ ] Abrir discusión con estudiantes
- [ ] Responder preguntas

Después de la clase:

- [ ] Compartir scripts con estudiantes
- [ ] Sugerir experimentos para casa
- [ ] Disponibilidad para consultas

---

**¡Listo para usar! 🚀**

_Última actualización: 2025 - Universidad Nacional del Oeste_
