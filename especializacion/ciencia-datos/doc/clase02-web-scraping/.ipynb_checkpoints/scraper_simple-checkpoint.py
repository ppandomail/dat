#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Scraper simple para extraer datos de votaciones de la Cámara de Diputados de Argentina
desde https://votaciones.hcdn.gob.ar/

VERSIÓN ULTRA SIMPLIFICADA - SIN WEBDRIVER-MANAGER
Usa Selenium Manager incorporado en Selenium 4.6+

Requisitos:
- Python 3.8+
- Chrome instalado
- Selenium 4.6+ (que tiene Selenium Manager incorporado)

Instalación:
    pip install selenium python-dateutil

Uso:
    python scraper_simple.py
"""

import os
import csv
import time
import re
import datetime
from pathlib import Path
from dateutil.parser import parse
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import (
    TimeoutException, 
    NoSuchElementException, 
    StaleElementReferenceException, 
    ElementClickInterceptedException,
    WebDriverException
)
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys


class VotacionesHCDNScraper:
    """
    Clase para scrapear votaciones de la Cámara de Diputados de Argentina
    Versión ultra simplificada - usa Selenium Manager automático
    """
    def __init__(self, download_dir="./votaciones_csvs", headless=False):
        """
        Inicializa el scraper
        
        Args:
            download_dir (str): Directorio donde se guardarán los archivos CSV
            headless (bool): Si se debe ejecutar el navegador en modo headless
        """
        self.base_url = "https://votaciones.hcdn.gob.ar/"
        self.download_dir = Path(download_dir).resolve()
        self.download_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"📁 Directorio de descargas: {self.download_dir}")
        
        # Configurar opciones de Chrome
        chrome_options = Options()
        
        if headless:
            chrome_options.add_argument("--headless=new")
        
        # Opciones generales
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-popup-blocking")
        
        # Configurar descargas automáticas
        prefs = {
            "download.default_directory": str(self.download_dir),
            "download.prompt_for_download": False,
            "download.directory_upgrade": True,
            "safebrowsing.enabled": False,
            "profile.default_content_setting_values.automatic_downloads": 1,
            "browser.download.manager.showWhenStarting": False,
            "browser.helperApps.neverAsk.saveToDisk": "text/csv,application/csv,application/vnd.ms-excel,text/plain,text/comma-separated-values"
        }
        chrome_options.add_experimental_option("prefs", prefs)
        
        # Inicializar el driver - Selenium Manager se encarga de todo
        try:
            print("🔧 Inicializando Chrome con Selenium Manager...")
            self.driver = webdriver.Chrome(options=chrome_options)
            print("✅ Chrome inicializado correctamente")
            print(f"   ChromeDriver: {self.driver.capabilities.get('chrome', {}).get('chromedriverVersion', 'desconocido')}")
        except WebDriverException as e:
            print(f"❌ Error al inicializar Chrome: {e}")
            raise SystemExit("No se pudo inicializar Chrome")
        
        # Maximizar ventana
        self.driver.maximize_window()
        print("🖥️  Ventana del navegador maximizada")
        
        # Fecha límite para la extracción de datos
        self.fecha_limite = datetime.datetime(2022, 1, 1)
        
        # Para almacenar todos los datos de votaciones
        self.datos_votaciones = []
    
    def parse_date(self, date_str):
        """Parsea una fecha en formato DD/MM/YYYY HH:MM"""
        if not date_str or date_str.strip() == "":
            return None
            
        try:
            date_str = date_str.replace('\n', ' ').strip()
            
            if re.match(r"\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}", date_str):
                return datetime.datetime.strptime(date_str, '%d/%m/%Y %H:%M')
            elif re.match(r"\d{2}/\d{2}/\d{4}", date_str):
                return datetime.datetime.strptime(date_str, '%d/%m/%Y')
            else:
                return parse(date_str, dayfirst=True)
                
        except (ValueError, TypeError) as e:
            print(f"⚠️ Error al parsear fecha '{date_str}': {e}")
            return None
        
    def navegar_a_sitio(self):
        """Navega al sitio web de votaciones"""
        print(f"\n🌐 Navegando a {self.base_url}...")
        self.driver.get(self.base_url)
        
        try:
            WebDriverWait(self.driver, 20).until(
                EC.presence_of_element_located((By.ID, "container-actas"))
            )
            print("✅ Página principal cargada correctamente")
        except TimeoutException:
            print("⏱️ Tiempo de espera agotado")
            raise Exception("No se pudo cargar la página principal")
        
    def cargar_todas_votaciones(self):
        """Carga todas las votaciones hasta llegar a 2022"""
        print("\n📥 Cargando todas las votaciones desde 2022...")
        
        contador_clics = 0
        intentos_maximos = 100
        intentos_sin_cambios = 0
        filas_anteriores = 0
        
        try:
            WebDriverWait(self.driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "tbody#container-actas tr.row-acta"))
            )
            filas_iniciales = len(self.driver.find_elements(By.CSS_SELECTOR, "tbody#container-actas tr.row-acta"))
            print(f"📊 Filas iniciales: {filas_iniciales}")
            filas_anteriores = filas_iniciales
        except TimeoutException:
            print("❌ No se encontraron filas de votaciones")
            return
        
        while contador_clics < intentos_maximos:
            try:
                filas_votaciones = self.driver.find_elements(By.CSS_SELECTOR, "tbody#container-actas tr.row-acta")
                total_filas = len(filas_votaciones)
                
                if not filas_votaciones:
                    break
                
                if total_filas <= filas_anteriores and contador_clics > 0:
                    intentos_sin_cambios += 1
                    if intentos_sin_cambios >= 3:
                        print("🛑 3 intentos sin cambios. Finalizando carga.")
                        break
                else:
                    intentos_sin_cambios = 0
                    filas_anteriores = total_filas
                
                # Verificar fecha de la última fila
                try:
                    ultima_fila = filas_votaciones[-1]
                    fecha_celda = ultima_fila.find_element(By.CSS_SELECTOR, "td:first-child")
                    fecha_texto = fecha_celda.text.strip()
                    fecha_obj = self.parse_date(fecha_texto)
                    
                    if fecha_obj and fecha_obj < self.fecha_limite:
                        print(f"🎯 Fecha límite alcanzada: {fecha_obj.strftime('%d/%m/%Y')}")
                        break
                except:
                    pass
                
                # Buscar y hacer clic en "Ver más"
                try:
                    boton_ver_mas = None
                    botones = self.driver.find_elements(By.CSS_SELECTOR, "#showMoreResult, .btn-back-top")
                    
                    for boton in botones:
                        if boton.text.strip() == "Ver más":
                            boton_ver_mas = boton
                            break
                    
                    if not boton_ver_mas:
                        break
                    
                    self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", boton_ver_mas)
                    time.sleep(1)
                    
                    self.driver.execute_script("arguments[0].click();", boton_ver_mas)
                    contador_clics += 1
                    
                    if contador_clics % 10 == 0:
                        print(f"   Clics en 'Ver más': {contador_clics} | Filas: {total_filas}")
                    
                    time.sleep(3)
                    
                except:
                    break
                
            except (StaleElementReferenceException, TimeoutException):
                time.sleep(2)
                continue
                
        print(f"✅ Carga completada. Total de clics: {contador_clics} | Filas finales: {filas_anteriores}")

    def extraer_fecha_html(self, celda_fecha):
        """Extrae la fecha directamente del HTML de la celda"""
        try:
            html = celda_fecha.get_attribute('innerHTML')
            
            patron_fecha = r'(\d{2}/\d{2}/\d{4})'
            match_fecha = re.search(patron_fecha, html)
            
            patron_hora = r'<span class="text-muted">(\d{2}:\d{2})</span>'
            match_hora = re.search(patron_hora, html)
            
            if match_fecha:
                fecha = match_fecha.group(1)
                hora = match_hora.group(1) if match_hora else ""
                return f"{fecha} {hora}".strip()
            return ""
        except:
            return ""

    def extraer_datos_tabla_principal(self):
        """Extrae los datos de la tabla principal de votaciones"""
        print("\n📋 Extrayendo datos de la tabla principal...")
        
        try:
            WebDriverWait(self.driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "tbody#container-actas tr.row-acta"))
            )
        except TimeoutException:
            print("⏱️ Tiempo de espera agotado")
            return
        
        filas_votaciones = self.driver.find_elements(By.CSS_SELECTOR, "tbody#container-actas tr.row-acta")
        print(f"📊 Encontradas {len(filas_votaciones)} filas de votaciones")
        
        for i, fila in enumerate(filas_votaciones):
            try:
                script = """
                var fila = arguments[0];
                var celdas = fila.getElementsByTagName('td');
                var datos = {
                    fecha: celdas[0] ? celdas[0].innerText.trim() : '',
                    titulo: celdas[1] ? celdas[1].innerText.trim() : '',
                    tipo: celdas[2] ? celdas[2].innerText.trim() : '',
                    resultado: celdas[3] ? celdas[3].innerText.trim() : '',
                    enlaces: []
                };
                
                if (celdas[celdas.length-1]) {
                    var enlaces = celdas[celdas.length-1].getElementsByTagName('a');
                    for (var i = 0; i < enlaces.length; i++) {
                        datos.enlaces.push({
                            href: enlaces[i].getAttribute('href'),
                            onclick: enlaces[i].getAttribute('onclick'),
                            title: enlaces[i].getAttribute('title')
                        });
                    }
                }
                return datos;
                """
                
                datos_fila = self.driver.execute_script(script, fila)
                fecha_html = self.extraer_fecha_html(fila.find_element(By.CSS_SELECTOR, "td:first-child"))
                
                if not fecha_html:
                    continue
                
                fecha_obj = self.parse_date(fecha_html)
                if fecha_obj is None:
                    continue
                
                if fecha_obj >= self.fecha_limite and 2022 <= fecha_obj.year <= 2025:
                    titulo = datos_fila['titulo']
                    tipo = datos_fila['tipo'] or "No especificado"
                    resultado = datos_fila['resultado'] or "No especificado"
                    
                    # Extraer ID
                    id_votacion = "desconocido"
                    for enlace in datos_fila['enlaces']:
                        if enlace['title'] == "Ver detalle" and enlace['href'] and "/votacion/" in enlace['href']:
                            try:
                                id_votacion = re.search(r'/votacion/(\d+)', enlace['href']).group(1)
                                break
                            except:
                                pass
                    
                    datos_votacion = {
                        "fecha": fecha_html,
                        "titulo": titulo,
                        "tipo": tipo,
                        "resultado": resultado,
                        "id_votacion": id_votacion
                    }
                    
                    self.datos_votaciones.append(datos_votacion)
                    
                    if (i + 1) % 100 == 0:
                        print(f"   Procesadas {i + 1} filas...")
            
            except:
                continue
                
        print(f"✅ Extracción completada. {len(self.datos_votaciones)} votaciones obtenidas.")

    def guardar_datos_csv(self, nombre_archivo="votaciones_hcdn_main_2022-2025.csv"):
        """Guarda los datos extraídos en un archivo CSV"""
        if not self.datos_votaciones:
            print("⚠️ No hay datos para guardar")
            return
        
        ruta_archivo = self.download_dir / nombre_archivo
        print(f"\n💾 Guardando datos en {ruta_archivo}...")
        
        with open(ruta_archivo, 'w', newline='', encoding='utf-8') as archivo_csv:
            campos = ["fecha", "titulo", "tipo", "resultado", "id_votacion"]
            escritor = csv.DictWriter(archivo_csv, fieldnames=campos)
            escritor.writeheader()
            for votacion in self.datos_votaciones:
                escritor.writerow(votacion)
                
        print(f"✅ Datos guardados: {len(self.datos_votaciones)} votaciones")
        
    def esperar_descarga(self, timeout=15, min_bytes=500):
        """Espera a que se descargue un archivo .csv"""
        archivos_antes = set(f for f in self.download_dir.glob("*.csv"))
        tiempo_inicio = time.time()
        
        while time.time() - tiempo_inicio < timeout:
            time.sleep(1)
            archivos_actuales = set(f for f in self.download_dir.glob("*.csv"))
            nuevos = archivos_actuales - archivos_antes

            for archivo in nuevos:
                if archivo.exists() and archivo.stat().st_size >= min_bytes:
                    return archivo
            
            if time.time() - tiempo_inicio > 5:
                archivos_recientes = []
                for archivo in archivos_actuales:
                    if archivo.exists() and archivo.stat().st_size >= min_bytes:
                        mtime = archivo.stat().st_mtime
                        if time.time() - mtime < 30:
                            archivos_recientes.append((archivo, mtime))
                
                if archivos_recientes:
                    archivos_recientes.sort(key=lambda x: x[1], reverse=True)
                    return archivos_recientes[0][0]
            
        return None

    def descargar_csvs_individuales(self, limite=10):
        """Descarga los archivos CSV individuales para cada votación"""
        print(f"\n📥 Iniciando descarga de CSVs individuales (límite: {limite})...")
        
        if not self.datos_votaciones:
            print("⚠️ No hay votaciones para descargar")
            return
        
        votaciones_a_procesar = self.datos_votaciones[:limite] if limite else self.datos_votaciones
        votaciones_procesadas = 0
        descargadas_exitosamente = 0
        
        for votacion in votaciones_a_procesar:
            votaciones_procesadas += 1
            id_votacion = votacion["id_votacion"]
            fecha = votacion["fecha"].replace("/", "-").replace(":", "-").replace(" ", "_")
            
            if id_votacion == "desconocido":
                continue
            
            try:
                # Limpiar CSVs temporales
                for f in self.download_dir.glob("*.csv"):
                    if "votaciones_hcdn_main" not in f.name and not f.name.startswith("votacion_"):
                        try:
                            f.unlink()
                        except:
                            pass
                
                url_detalle = f"{self.base_url}votacion/{id_votacion}"
                url_anterior = self.driver.current_url
                
                self.driver.get(url_detalle)
                
                # Buscar enlace CSV
                enlace_csv = None
                selectors = [
                    "a[href='javascript:exportCSV()']",
                    "a[onclick*='exportCSV']",
                    "a.dt-button.buttons-csv",
                    "//a[contains(., 'CSV')]"
                ]
                
                for selector in selectors:
                    try:
                        if selector.startswith("//"):
                            elementos = self.driver.find_elements(By.XPATH, selector)
                        else:
                            elementos = self.driver.find_elements(By.CSS_SELECTOR, selector)
                        
                        if elementos:
                            enlace_csv = elementos[0]
                            break
                    except:
                        pass
                
                if not enlace_csv:
                    self.driver.get(url_anterior)
                    continue
                
                # Hacer clic
                try:
                    self.driver.execute_script("arguments[0].click();", enlace_csv)
                except:
                    enlace_csv.click()
                
                # Esperar descarga
                archivo_descargado = self.esperar_descarga(timeout=15)
                
                if archivo_descargado and archivo_descargado.exists():
                    archivo_destino = self.download_dir / f"votacion_{id_votacion}_{fecha}.csv"
                    
                    if archivo_destino.exists():
                        archivo_destino.unlink()
                    
                    archivo_descargado.rename(archivo_destino)
                    descargadas_exitosamente += 1
                    
                    if votaciones_procesadas % 5 == 0:
                        print(f"   Progreso: {votaciones_procesadas}/{len(votaciones_a_procesar)} | Exitosas: {descargadas_exitosamente}")
                
                self.driver.get(url_anterior)
                time.sleep(2)
                
            except Exception as e:
                self.driver.get(self.base_url)
                continue
        
        print(f"\n📊 Descargas: {descargadas_exitosamente}/{votaciones_procesadas} exitosas ({descargadas_exitosamente/votaciones_procesadas*100:.1f}%)")

    def cerrar(self):
        """Cierra el navegador"""
        if self.driver:
            self.driver.quit()
            print("\n🔒 Navegador cerrado")
            
    def ejecutar_scraping_completo(self, limite_descargas=10):
        """Ejecuta el proceso completo de scraping"""
        print("="*60)
        print("🚀 SCRAPER VOTACIONES HCDN")
        print("="*60)
        
        try:
            self.navegar_a_sitio()
            self.cargar_todas_votaciones()
            self.extraer_datos_tabla_principal()
            self.guardar_datos_csv()
            
            if limite_descargas and limite_descargas > 0:
                self.descargar_csvs_individuales(limite=limite_descargas)
            
            print("\n" + "="*60)
            print("✅ PROCESO COMPLETADO EXITOSAMENTE")
            print("="*60)
            
        except Exception as e:
            print(f"\n❌ ERROR: {e}")
            import traceback
            traceback.print_exc()
        finally:
            self.cerrar()


if __name__ == "__main__":
    # CONFIGURACIÓN
    HEADLESS = False          # True = sin ventana | False = con ventana
    LIMITE_DESCARGAS = 10     # None = todas | 10 = solo 10 | 0 = no descargar individuales
    
    print("\n🔧 CONFIGURACIÓN:")
    print(f"   Modo headless: {HEADLESS}")
    print(f"   Límite de descargas: {LIMITE_DESCARGAS if LIMITE_DESCARGAS else 'Sin límite'}")
    print()
    
    scraper = VotacionesHCDNScraper(
        download_dir="./votaciones_csvs",
        headless=HEADLESS
    )
    scraper.ejecutar_scraping_completo(limite_descargas=LIMITE_DESCARGAS)
