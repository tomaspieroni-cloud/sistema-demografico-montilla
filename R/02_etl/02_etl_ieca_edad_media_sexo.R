# ============================================================
# ETL IECA – Edad media por sexo (Montilla)
# Fuente: IECA/SIMA
# Formato: TXT separado por ;
# Salida: tabla PostgreSQL edad_media_sexo_ieca
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")
getwd()

library(tidyverse)
library(DBI)
library(RPostgres)

ruta_edad <- file.path("Datos", "Demograficos", "Edad media de la población Montilla por sexo (Padrón).txt")
if (!file.exists(ruta_edad)) stop("No existe: ", ruta_edad)

edad_raw <- read_delim(
  ruta_edad,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

glimpse(edad_raw)
names(edad_raw)

# Normalmente IECA trae columnas tipo: Sexo / Anual / Valor (y a veces “Lugar de residencia”)
edad <- edad_raw %>%
  select(
    anio = Anual,
    sexo = Sexo,
    edad_media_txt = Valor
  ) %>%
  mutate(
    anio = as.integer(anio),
    edad_media = readr::parse_number(
      dplyr::na_if(edad_media_txt, "-"),
      locale = readr::locale(decimal_mark = ",")
    ),
    fuente = "IECA"
  ) %>%
  select(anio, sexo, edad_media, fuente) %>%
  arrange(anio, sexo)

print(edad)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "montilla_db",
  host = "localhost",
  port = 5432,
  user = "montilla_user",
  password = "montilla_pass"
)

dbWriteTable(con, "edad_media_sexo_ieca", edad, overwrite = TRUE)

dbGetQuery(con, "SELECT * FROM edad_media_sexo_ieca ORDER BY anio, sexo LIMIT 10;")
dbDisconnect(con)