# 🔧 Instalación con Entorno Virtual

## ✨ Por qué usar un entorno virtual

- ✅ Aisla las dependencias del proyecto
- ✅ Evita conflictos con otros proyectos Python
- ✅ Facilita la reproducibilidad
- ✅ Buena práctica profesional

---

## 🚀 Instalación Completa (Paso a Paso)

### 📍 Paso 1: Navegar a la carpeta del proyecto

```bash
cd [TU_CARPETA_DE_PROYECTO]
```

---

### 📦 Paso 2: Crear el entorno virtual

**Opción A - Con `venv` (viene con Python):**
```bash
python -m venv venv
```

**Opción B - Con `virtualenv` (si lo tenés instalado):**
```bash
virtualenv venv
```

Esto crea una carpeta `venv/` en tu proyecto con Python aislado.

---

### ⚡ Paso 3: Activar el entorno virtual

**En Windows (PowerShell):**
```powershell
.\venv\Scripts\Activate.ps1
```

**En Windows (CMD):**
```cmd
venv\Scripts\activate.bat
```

**En Windows (Git Bash):**
```bash
source venv/Scripts/activate
```

**💡 Sabrás que está activado cuando veas `(venv)` al inicio de tu terminal:**
```
(venv) C:\ruta\a\tu\proyecto>
```

---

### 📥 Paso 4: Instalar dependencias

**Para la versión SIMPLE (recomendada):**
```bash
pip install -r requirements_simple.txt
```

---

### ✅ Paso 5: Verificar instalación

```bash
pip list
```

Deberías ver algo como:
```
Package         Version
--------------- --------
python-dateutil 2.8.2
selenium        4.15.2
...
```

---

### 🧪 Paso 6: Probar que funciona

```bash
python test_chrome.py
```

---

### 🎯 Paso 7: Ejecutar el scraper

```bash
python scraper_simple.py
```

---

## 🔄 Comandos Útiles

### Desactivar el entorno virtual
```bash
deactivate
```

### Reactivar el entorno virtual (cuando vuelvas)
```powershell
.\venv\Scripts\Activate.ps1
```

### Ver paquetes instalados
```bash
pip list
```

### Actualizar pip (opcional pero recomendado)
```bash
python -m pip install --upgrade pip
```

### Guardar dependencias actuales (si agregás más paquetes)
```bash
pip freeze > requirements.txt
```

---

## 📋 Resumen de Comandos (Copy-Paste Completo)

### Primera vez (setup completo):

```powershell
# 1. Ir a la carpeta
cd C:\ruta\a\tu\proyecto

# 2. Crear entorno virtual
python -m venv venv

# 3. Activar entorno virtual
.\venv\Scripts\Activate.ps1

# 4. Actualizar pip (opcional)
python -m pip install --upgrade pip

# 5. Instalar dependencias
pip install -r requirements_simple.txt

# 6. Verificar instalación
pip list

# 7. Probar
python test_chrome.py

# 8. Ejecutar scraper
python scraper_simple.py
```

---

### Cuando vuelvas otro día:

```powershell
# 1. Ir a la carpeta
cd [TU_CARPETA_DE_PROYECTO]

# 2. Activar entorno virtual
.\venv\Scripts\Activate.ps1

# 3. Trabajar normalmente
python scraper_simple.py

# 4. Cuando termines
deactivate
```

---

## 🎓 Para tus Estudiantes

### Plantilla de Instrucciones para la Clase

```markdown
# Setup del Proyecto - Scraper HCDN

## Requisitos Previos
- Python 3.8 o superior instalado
- Google Chrome instalado
- Terminal (PowerShell, CMD, o Git Bash)

## Pasos de Instalación

1. Abrir terminal y navegar a la carpeta del proyecto
2. Crear entorno virtual: `python -m venv venv`
3. Activar entorno: `.\venv\Scripts\Activate.ps1`
4. Instalar dependencias: `pip install -r requirements_simple.txt`
5. Probar instalación: `python test_chrome.py`

## Ejecutar el Scraper
```bash
python scraper_simple.py
```

## Desactivar al Terminar
```bash
deactivate
```
```

---

## 🐛 Solución de Problemas

### Error: "Execution Policy" (PowerShell)

Si al activar obtenés un error de políticas de ejecución:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Luego intentá activar de nuevo:
```powershell
.\venv\Scripts\Activate.ps1
```

---

### Error: "python: command not found"

Usá `py` en lugar de `python`:
```bash
py -m venv venv
```

---

### El prompt no muestra (venv)

Es posible que esté activado igual. Verificá con:
```bash
where python
```

Debería mostrar una ruta dentro de `venv\Scripts\`.

---

### Quiero usar un nombre diferente para el entorno

```bash
# En lugar de 'venv', usá el nombre que quieras
python -m venv mi_entorno

# Activar
.\mi_entorno\Scripts\Activate.ps1
```

---

## 📁 Estructura Final del Proyecto

```
01_scraper/
├── venv/                          ← Entorno virtual (NO subir a Git)
│   ├── Scripts/
│   ├── Lib/
│   └── ...
├── scraper_simple.py             ← Script principal
├── requirements_simple.txt       ← Dependencias
├── test_chrome.py                ← Prueba rápida
├── test_scraper.py               ← Prueba del scraper
├── README_SIMPLE.md              ← Documentación
└── votaciones_csvs/              ← Datos generados (se crea al ejecutar)
    ├── votaciones_hcdn_main_2022-2025.csv
    └── ...
```

---

## 📝 .gitignore Recomendado

Si usás Git, agregá esto a tu `.gitignore`:

```gitignore
# Entorno virtual
venv/
env/
ENV/

# Datos generados
votaciones_csvs/

# Cache de Python
__pycache__/
*.pyc
*.pyo

# Otros
.DS_Store
*.log
```

---

## 💡 Consejo Pro

Para no tener que activar manualmente cada vez, podés crear un script de inicio:

**`start_project.ps1`:**
```powershell
# Activar entorno virtual y abrir VSCode
.\venv\Scripts\Activate.ps1
code .
```

Luego solo ejecutás:
```powershell
.\start_project.ps1
```

---

## ✅ Checklist de Verificación

Después de la instalación, verificá:

- [ ] El prompt muestra `(venv)` al inicio
- [ ] `pip list` muestra `selenium` y `python-dateutil`
- [ ] `python test_chrome.py` abre Chrome y muestra info
- [ ] La carpeta `venv/` existe en tu proyecto
- [ ] Podés desactivar con `deactivate` y el `(venv)` desaparece

---

**¡Listo! Tu entorno virtual está configurado y el proyecto está aislado correctamente.** 🎉
