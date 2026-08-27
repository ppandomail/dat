# 🚀 Scraper HCDN - Versión Ultra Simple

**La versión MÁS SIMPLE posible** - Solo 2 dependencias, usa tu ChromeDriver existente.

## ✨ Por qué esta versión es la mejor

✅ **Solo 2 dependencias**: `selenium` + `python-dateutil`  
✅ **Usa tu ChromeDriver**: El que ya tenés en `C:\Users\TU_USUARIO\.cache\selenium\`  
✅ **Un solo archivo**: Todo en `scraper_simple.py`  
✅ **Código limpio**: ~400 líneas bien comentadas  
✅ **Cero configuración**: Funciona directamente  

## 📋 Requisitos

1. **Python 3.8+** (ya lo tenés ✓)
2. **Chrome instalado** (ya lo tenés ✓)
3. **ChromeDriver** (ya lo tenés en `.cache\selenium\` ✓)

## 🚀 Instalación Express (2 pasos)

```bash
# 1. Instalar dependencias (solo 2 paquetes)
pip install -r requirements_simple.txt

# 2. Ejecutar
python scraper_simple.py
```

¡Eso es todo! No necesitás Docker, ni webdriver-manager, ni nada más.

## 💡 Cómo Funciona

### Ejecución por defecto

```bash
python scraper_simple.py
```

Esto hará:
1. ✅ Abrir Chrome (verás la ventana)
2. ✅ Ir a https://votaciones.hcdn.gob.ar/
3. ✅ Hacer clic en "Ver más" hasta llegar a 2022
4. ✅ Extraer todas las votaciones (fecha, título, tipo, resultado, ID)
5. ✅ Guardar CSV principal con todas las votaciones
6. ✅ Descargar 10 CSVs individuales (para no tardar mucho)

### Personalizar la ejecución

Editá estas líneas al final de `scraper_simple.py`:

```python
# CONFIGURACIÓN
HEADLESS = False          # True = sin ventana | False = con ventana
LIMITE_DESCARGAS = 10     # None = todas | 10 = solo 10 | 0 = no descargar
```

**Ejemplos prácticos:**

```python
# Solo quiero el CSV principal, sin descargas individuales (RÁPIDO)
HEADLESS = False
LIMITE_DESCARGAS = 0

# Quiero todo en background (PRODUCCIÓN)
HEADLESS = True
LIMITE_DESCARGAS = None

# Quiero probar con pocas descargas (TESTING)
HEADLESS = False
LIMITE_DESCARGAS = 5
```

## 📁 Archivos que genera

```
votaciones_csvs/
├── votaciones_hcdn_main_2022-2025.csv    # ← El archivo principal (SIEMPRE)
├── votacion_12345_25-09-2024_14-30.csv  # ← CSVs individuales (si configuraste descargas)
├── votacion_12346_24-09-2024_10-15.csv
└── ...
```

### CSV Principal

Contiene **todas las votaciones** en una tabla:

```csv
fecha,titulo,tipo,resultado,id_votacion
25/09/2024 14:30,Ley de Presupuesto 2025,Proyecto de Ley,Afirmativo,12345
24/09/2024 10:15,Modificación Código Penal,Proyecto de Ley,Negativo,12346
...
```

### CSVs Individuales

Cada uno contiene el **detalle completo** de una votación (diputado por diputado).

## ⏱️ Tiempos de Ejecución

| Operación | Tiempo |
|-----------|--------|
| Cargar todas las votaciones 2022-2025 | ~8 min |
| Extraer datos de tabla principal | ~30 seg |
| Guardar CSV principal | <1 seg |
| Descargar 10 CSVs individuales | ~3 min |
| **TOTAL (config por defecto)** | **~12 min** |

## 🎯 Casos de Uso

### 1. Solo quiero el CSV principal (RÁPIDO - 9 minutos)

```python
HEADLESS = True   # En background
LIMITE_DESCARGAS = 0  # Sin descargas individuales
```

### 2. Quiero ver qué pasa (DEBUG)

```python
HEADLESS = False  # Ver el navegador
LIMITE_DESCARGAS = 3  # Solo 3 para probar
```

### 3. Quiero TODO (COMPLETO - ~2 horas)

```python
HEADLESS = True   # En background
LIMITE_DESCARGAS = None  # TODAS las votaciones
```

## 🔧 Solución de Problemas

### Error: "ModuleNotFoundError: No module named 'selenium'"

```bash
pip install selenium python-dateutil
```

### Error: "Chrome driver not found"

No debería pasar porque Selenium 4.15+ usa **Selenium Manager** que ya tenés configurado.

Pero si pasa, verificá:

```python
# En Python
from selenium import webdriver
driver = webdriver.Chrome()
# Si abre Chrome → Todo bien ✓
```

### El script se cuelga

1. Verificá tu conexión a internet
2. Ejecutá con `HEADLESS = False` para ver qué pasa
3. Aumentá los tiempos de espera en el código (si tu internet es lento)

### No se descargan los CSVs individuales

1. Verificá que `votaciones_csvs/` tenga permisos de escritura
2. Probá con `LIMITE_DESCARGAS = 1` primero
3. Mirá el navegador (`HEADLESS = False`) para ver si hay algún error

## 🎓 Para tu Proyecto UNO

Este scraper es **perfecto** para:

- ✅ Enseñar web scraping a tus estudiantes
- ✅ Demostrar automatización con Selenium
- ✅ Mostrar manejo de datos públicos
- ✅ Análisis de votaciones legislativas
- ✅ Proyecto de ciencia de datos aplicada

### Ideas de ejercicios para estudiantes

1. **Básico**: Modificar el límite de descargas
2. **Intermedio**: Agregar filtrado por tipo de votación
3. **Avanzado**: Análisis de datos con pandas sobre los CSVs
4. **Proyecto**: Dashboard interactivo con los datos

## 📊 Comparación de Versiones

| Característica | Docker | **Simple** |
|---------------|--------|------------|
| Archivos | 7 | **2** |
| Dependencias | Docker+5 libs | **2 libs** |
| Setup | Complejo | **1 comando** |
| ChromeDriver | Incluido | **Ya lo tenés** |
| Mejor para | Servidores | **Educación** |

## 🤓 Detalles Técnicos

### ¿Cómo usa mi ChromeDriver?

Selenium 4.6+ incluye **Selenium Manager** que:
1. Detecta tu versión de Chrome
2. Busca ChromeDriver en `.cache/selenium/`
3. Si lo encuentra → lo usa
4. Si no → lo descarga automáticamente

Como vos ya lo tenés en `C:\Users\TU_USUARIO\.cache\selenium\chromedriver\win64\<VERSION_DRIVER>`, 
Selenium Manager lo detecta y usa automáticamente. **Cero configuración**.

### ¿Por qué esta versión es más simple?

Desde Selenium 4.6+, **Selenium Manager** gestiona automáticamente ChromeDriver, 
por lo que no se necesita ninguna herramienta externa adicional. Esta versión simple 
aprovecha esa capacidad nativa y reduce dependencias.

## 📝 Notas Finales

- El código tiene emojis para hacer más clara la salida en terminal
- Todos los mensajes son en español
- El código está **muy** comentado para uso educativo
- Funciona en Windows/Linux/Mac (usa `Path()` para rutas)

---

**¿Listo para empezar?**

```bash
pip install -r requirements_simple.txt
python scraper_simple.py
```

¡Disfrutá el scraping! 🚀
