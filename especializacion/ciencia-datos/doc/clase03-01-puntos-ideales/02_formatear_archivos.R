rm(list = ls())
gc()

library(data.table)
library(pbapply)
library(tidyverse)
library(lubridate)

# Asumo que estoy parado en la carpeta de legislativas
carpeta_legislativas <- "C:/00_dev/00_playground/04_TEACH/UNO/2025/clases/clase_03/legislativas"
setwd(carpeta_legislativas)
setwd("./diputados/01_scraping/votaciones_csvs")
# Listo los archivos cuyo nombre comienza con un digito (en contraposicion a una letra)
archivos_sesiones <- list.files(pattern = "^votacion_\\d{4}")
# Importo los archivos, les agrego la info de la sesion y cambio los nombres de las columnas
sesiones <- pblapply(archivos_sesiones,function(archivo){
  numero_sesion <- str_extract(archivo,"votacion_\\d{4}")
  numero_sesion <- str_extract(numero_sesion,"\\d{4}")
  sesion <- fread(archivo)
  sesion$id_votacion <- as.integer(numero_sesion)
  setnames(sesion
           ,c("DIPUTADO","BLOQUE","PROVINCIA","¿CÓMO VOTÓ?")
           ,c("legislador","bloque","provincia","voto")
           )
  sesion
})
# Levanto la tabla escrapeada con informacion de cada sesion
archivo_info_sesiones <- list.files(pattern = "votaciones_hcdn_main")
info_sesiones <- fread(archivo_info_sesiones)

info_sesiones[,fecha_hora:=dmy_hm(fecha)]
info_sesiones[,yr:=year(fecha_hora)]

sesiones_dt <- rbindlist(sesiones)

sesiones_dt[info_sesiones,yr:=i.yr,on=.(id_votacion)]

# Legisladores
sesiones_dt[,legislador_norm:=stringi::stri_trans_general(tolower(legislador),"Latin-ASCII")]
setorder(sesiones_dt,legislador_norm)
sesiones_dt[,legislador_id:=.GRP,.(legislador_norm)]
sesiones_dt[,legislador_norm:=NULL]

# Bloques
sesiones_dt[,bloque_norm:=stringi::stri_trans_general(tolower(bloque),"Latin-ASCII")]
setorder(sesiones_dt,bloque_norm)
sesiones_dt[,bloque_id:=.GRP,.(bloque_norm)]
sesiones_dt[,bloque_norm:=NULL]

# Provincias
sesiones_dt[,provincia_norm:=stringi::stri_trans_general(tolower(provincia),"Latin-ASCII")]
setorder(sesiones_dt,provincia_norm)
sesiones_dt[,provincia_id:=.GRP,.(provincia_norm)]
sesiones_dt[,provincia_norm:=NULL]

# Guardo las tablas
setwd("../")
dir.create("sesiones",showWarnings = FALSE)
setwd("sesiones")
fwrite(info_sesiones,"info_sesiones_dt.csv")
fwrite(sesiones_dt,"sesiones_dt.csv.gz")

setwd(carpeta_legislativas)
