# ============================================================
# ETL IECA – Índice de dependencia (Montilla)
# Fuente: IECA/SIMA
# Formato: TXT separado por ;
# Salida: tabla PostgreSQL indice_dependencia_ieca
# ============================================================

# Working directory (ajustado a tu proyecto)
setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")
getwd()

# Librerías
library(tidyverse)
library(DBI)
library(RPostgres)

#Ruta archivo (relativa, reproducible)
ruta_dep <- file.path("Datos", "Otros", "Indice de dependencia Montilla.txt")
if (!file.exists(ruta_dep)) stop("No existe: ", ruta_dep)

#Leer TXT separado por ;
dep_raw <- read_delim(
  ruta_dep,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

glimpse(dep_raw)
names(dep_raw)



#Estandarizar (lo mínimo: año + valor)
# Crear columna 'tipo' a partir de la columna que exista (Edad o Medida)
dep <- dep_raw %>%
  mutate(
    tipo = case_when(
      "Edad" %in% names(dep_raw)   ~ Edad,
      "Medida" %in% names(dep_raw) ~ Medida,
      TRUE ~ "desconocido"
    )
  ) %>%
  select(
    anio = Anual,
    tipo,
    indice_dependencia = Valor
  ) %>%
  mutate(
    anio = as.integer(anio),
    indice_dependencia = as.numeric(indice_dependencia),
    fuente = "IECA"
  ) %>%
  arrange(anio, tipo)



#Guardar en PostgreSQL
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "montilla_db",
  host = "localhost",
  port = 5432,
  user = "montilla_user",
  password = "montilla_pass"
)

dbWriteTable(con, "indice_dependencia_ieca", dep, overwrite = TRUE)

dbGetQuery(con, "SELECT * FROM indice_dependencia_ieca ORDER BY anio LIMIT 10;")
dbDisconnect(con)



dbGetQuery(con, "SELECT DISTINCT tipo FROM indice_dependencia_ieca;")
