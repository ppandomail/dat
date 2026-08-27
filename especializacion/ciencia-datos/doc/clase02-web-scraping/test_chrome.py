#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Prueba ultra rápida - Solo verifica que Chrome se abra correctamente
"""

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

def prueba_chrome():
    """
    Prueba que:
    1. Chrome se puede abrir
    2. Puede navegar a votaciones.hcdn.gob.ar
    3. Puede encontrar la tabla de votaciones
    """
    print("="*60)
    print("🧪 PRUEBA RÁPIDA DE CHROME")
    print("="*60)
    
    try:
        print("\n1️⃣ Abriendo Chrome...")
        chrome_options = Options()
        # chrome_options.add_argument("--headless=new")  # Descomenta para modo headless
        
        driver = webdriver.Chrome(options=chrome_options)
        print("   ✅ Chrome abierto correctamente")
        
        # Obtener versión de ChromeDriver
        caps = driver.capabilities
        chrome_version = caps.get('browserVersion', 'desconocido')
        driver_version = caps.get('chrome', {}).get('chromedriverVersion', 'desconocido')
        
        print(f"   📌 Chrome: {chrome_version}")
        print(f"   📌 ChromeDriver: {driver_version.split()[0] if driver_version != 'desconocido' else 'desconocido'}")
        
        print("\n2️⃣ Navegando a votaciones.hcdn.gob.ar...")
        driver.get("https://votaciones.hcdn.gob.ar/")
        print("   ✅ Página cargada")
        
        print("\n3️⃣ Buscando tabla de votaciones...")
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "container-actas"))
        )
        print("   ✅ Tabla de votaciones encontrada")
        
        print("\n4️⃣ Contando filas de votaciones...")
        filas = driver.find_elements(By.CSS_SELECTOR, "tbody#container-actas tr.row-acta")
        print(f"   ✅ Encontradas {len(filas)} votaciones visibles")
        
        if filas:
            print("\n5️⃣ Leyendo primera votación...")
            primera_fila = filas[0]
            celdas = primera_fila.find_elements(By.TAG_NAME, "td")
            
            if len(celdas) >= 4:
                fecha = celdas[0].text.strip()
                titulo = celdas[1].text.strip()[:50]  # Primeros 50 caracteres
                tipo = celdas[2].text.strip()
                resultado = celdas[3].text.strip()
                
                print(f"   📅 Fecha: {fecha}")
                print(f"   📝 Título: {titulo}...")
                print(f"   🏷️ Tipo: {tipo}")
                print(f"   ✔️ Resultado: {resultado}")
        
        print("\n⏱️ Esperando 3 segundos antes de cerrar...")
        time.sleep(3)
        
        print("\n6️⃣ Cerrando navegador...")
        driver.quit()
        print("   ✅ Navegador cerrado")
        
        print("\n" + "="*60)
        print("✅ TODAS LAS PRUEBAS PASARON CORRECTAMENTE")
        print("="*60)
        print("\n🎉 ¡Tu configuración está lista!")
        print("   Podés ejecutar el scraper completo con:")
        print("   python scraper_simple.py")
        
        return True
        
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        print("\n💡 Posibles soluciones:")
        print("   1. Verificá que Chrome esté instalado")
        print("   2. Instalá las dependencias: pip install selenium python-dateutil")
        print("   3. Verificá tu conexión a internet")
        
        try:
            driver.quit()
        except:
            pass
        
        return False

if __name__ == "__main__":
    prueba_chrome()
