rm(list = ls())
gc()

library(data.table)
library(pbapply)
library(tidyverse)
library(lubridate)
library(pscl)

# Asumo que estoy parado en la carpeta de legislativas
carpeta_legislativas <- "C:/00_dev/00_playground/04_TEACH/UNO/2025/clases/clase_03/legislativas"
setwd(carpeta_legislativas)
setwd("./diputados/01_scraping/sesiones")
sesiones <- fread("sesiones_dt.csv.gz")

anios <- sort(unique(sesiones$yr))

sesiones <- sesiones[voto %in% c("AUSENTE","AFIRMATIVO","NEGATIVO","ABSTENCION")]

setorder(sesiones,yr,id_votacion)
sesiones[,id:=seq(1,nrow(sesiones))]

gc()

##########################
idps <- lapply(anios,function(x){
  
  votos_anio <- sesiones[yr==x]
  nvotos_periodo <- dim(votos_anio)[1]
  legis.names <- unique(votos_anio$legislador)
  nlegis <- length(legis.names) # Cantidad de legisladores
  legis.partidos <- unique(votos_anio[,.(bloque=last(bloque)),legislador])$bloque
  actas.names <- unique(votos_anio[,.(id_votacion)])$id_votacion # Ids de las actas votadas
  nactas <- length(actas.names) # Cantidad de actas votadas
  niveles <- unique(votos_anio[,voto]) # Variantes de voto ("AFIRMATIVO", "NEGATIVO", etc.)
  niveles <- sort(niveles)
  
  notInLegis <- match('AUSENTE', niveles)
  yea <- match('AFIRMATIVO', niveles)
  nay <- match('NEGATIVO', niveles)
  abstencion <- match('ABSTENCION', niveles)
  
  # Genero matriz vacia con dimension nlegis x nactas
  data <- matrix(, nlegis, nactas)
  
  # Matriz con votos por legislador y acta con valores numericos de acuerdo al 'nivel'
  for (n in 1:nvotos_periodo) {
    nombre <- legis.names == votos_anio[n, legislador]
    acta <- actas.names == votos_anio[n, id_votacion]
    nivel <- match(votos_anio[n, voto], niveles)
    data[nombre, acta] <- nivel
  }
  
  legis.data <- data.frame(party=legis.partidos) # Convierto la tabla con partidos x legislador en formato dataframe de R
  row.names(legis.data) <- legis.names # Asigno los nombres de los legisladores como etiquetas de fila
  desc <- paste('Votos de diputados', x) # Etiqueta descriptiva para el periodo
  # La funcion a continuacion, es especifica de pscl y es esencial para el calculo
  # Se utilizan todos los valores que fueron calculados previamente
  rData <- rollcall(data, yea=yea, nay=nay, missing=abstencion,
                    notInLegis=notInLegis, legis.names=legis.names, vote.names=actas.names,
                    legis.data=legis.data, vote.data=NULL, desc=desc, source=NULL)
  
  # El algoritmo de ideal points en si, en este caso, con valores normalizados
  fitted <- ideal(rData, normalize=T,impute = T)
  outcome <- fitted$xbar # Extraigo el vector de puntos ideales
  
  outcome <- cbind(outcome,anio=x) # Le pego la columna que indica el periodo
  
  outcome <- as.data.frame(outcome) # Lo transformo al formato dataframe de R
  names(outcome) <- c("idp","anio") # Agrego nombres de columna
  outcome <- add_rownames(outcome,"nombre") # Extraigo las etiquetas de fila y las transformo en nueva columna con el nombre de cada legislador
  outcome <- as.data.table(outcome)
})

idps <- rbindlist(idps)

setwd(carpeta_legislativas)

setwd("./diputados/02_puntos ideales")
dir.create("idps",showWarnings = FALSE)
setwd("idps")

fwrite(idps,"idps.csv")

# rm(list = setdiff(ls(),c("idps","anios")))

distancias <- pblapply(anios,function(a){
  idps_anio <- idps[anio==a]
  comb_idps_anio <- as.data.table(expand.grid(nombre1=idps_anio$nombre,nombre2=idps_anio$nombre))
  comb_idps_anio <- comb_idps_anio[idps_anio,on=c("nombre1"="nombre")]
  setnames(comb_idps_anio,"idp","idp_desde")
  comb_idps_anio <- comb_idps_anio[idps_anio[,!"anio"],on=c("nombre2"="nombre")]
  setnames(comb_idps_anio,"idp","idp_hasta")
  comb_idps_anio[,distancia:=abs(idp_desde-idp_hasta)]
})

distancias <- rbindlist(distancias)
distancias <- distancias[distancia>0]

fwrite(distancias,"distancias_idps.csv.gz")

gc()

idps %>% 
  arrange(anio, idp) %>% 
  group_by(anio) %>% 
  mutate(i=1,i=cumsum(i)) %>% 
  ungroup() %>% 
  ggplot(aes(i,y=idp,col=factor(anio))) +
  geom_line()

idps[,.N,by="anio"] %>% 
  ggplot(aes(anio,N)) +
  geom_point()

# sesiones_totales <- readRDS("sesiones_totales.rds")

setorder(sesiones,yr,id_votacion)
legisladores_bloque_provincia <- sesiones[,.(bloque=last(bloque),provincia=last(provincia)),.(legislador,yr)]

fwrite(legisladores_bloque_provincia,"legisladores_bloque_provincia.csv")
