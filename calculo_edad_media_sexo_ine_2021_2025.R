# ============================================================
# Cálculo INE – Edad media por sexo (estimada) 2021–2025
# usando quinquenales (punto medio)
# Salida DB: edad_media_sexo_ine
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")

library(tidyverse)
library(DBI)
library(RPostgres)

ruta_ine <- file.path(
  "Datos","Demograficos",
  "Censo anual de población 2021-2025 - Población por sexo, edad (grupos quinquenales).csv"
)
stopifnot(file.exists(ruta_ine))

ine_raw <- read_delim(
  ruta_ine, delim=";",
  locale = locale(decimal_mark=",", encoding="UTF-8"),
  trim_ws = TRUE
)

ine <- ine_raw %>%
  transmute(
    anio = as.integer(Periodo),
    sexo = Sexo,
    grupo_edad = Edad,
    poblacion = as.numeric(Total)
  )

# Extraer números del texto de edad de forma robusta
# - "De 20 a 24 ..." -> c(20,24)
# - "100 y más ..."  -> c(100)
nums <- stringr::str_extract_all(ine$grupo_edad, "\\d+")
ine$edad_min <- purrr::map_dbl(nums, ~ if (length(.x) >= 1) as.numeric(.x[1]) else NA_real_)
ine$edad_max <- purrr::map_dbl(nums, ~ if (length(.x) >= 2) as.numeric(.x[2]) else NA_real_)

# Quitamos "Todas las edades"
ine <- ine %>% filter(!is.na(edad_min))

# Punto medio
ine <- ine %>%
  mutate(
    edad_mid = if_else(!is.na(edad_max),
                       (edad_min + edad_max) / 2,
                       edad_min + 2.5)  # 100+ -> 102.5
  )

edad_media_ine <- ine %>%
  group_by(anio, sexo) %>%
  summarise(
    edad_media = sum(edad_mid * poblacion, na.rm = TRUE) / sum(poblacion, na.rm = TRUE),
    fuente = "INE",
    .groups = "drop"
  ) %>%
  arrange(anio, sexo)

print(edad_media_ine)

# Guardar en PostgreSQL
con <- dbConnect(
  RPostgres::Postgres(),
  dbname="montilla_db", host="localhost", port=5432,
  user="montilla_user", password="montilla_pass"
)

dbWriteTable(con, "edad_media_sexo_ine", edad_media_ine, overwrite = TRUE)

dbGetQuery(con, "SELECT * FROM edad_media_sexo_ine ORDER BY anio, sexo;")
dbDisconnect(con)