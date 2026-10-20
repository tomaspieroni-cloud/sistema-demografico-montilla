# ============================================================
# Cálculo INE – Índice de dependencia (2021–2025) desde quinquenales
# Salida DB: indice_dependencia_ine
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

library(tidyverse)
library(DBI)
library(RPostgres)

# --- Ruta al CSV INE quinquenal
ruta_ine <- file.path(
  "Datos","Demograficos",
  "Censo anual de población 2021-2025 - Población por sexo, edad (grupos quinquenales).csv"
)
stopifnot(file.exists(ruta_ine))

ine_raw <- read_delim(
  ruta_ine, delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

ine <- ine_raw %>%
  transmute(
    anio = as.integer(Periodo),
    sexo = Sexo,
    grupo_edad = Edad,
    poblacion = as.numeric(Total)
  ) %>%
  # Nos quedamos con el total (para comparar con IECA total)
  filter(sexo == "Total") %>%
  # Edad mínima numérica robusta (evita problemas de encoding)
  mutate(edad_min = as.numeric(str_extract(grupo_edad, "\\d+"))) %>%
  filter(!is.na(edad_min))  # excluye "Todas las edades"

# 0–14
p014 <- ine %>%
  filter(edad_min < 15) %>%
  group_by(anio) %>%
  summarise(p014 = sum(poblacion, na.rm = TRUE), .groups = "drop")

# 15–64
p1564 <- ine %>%
  filter(edad_min >= 15, edad_min < 65) %>%
  group_by(anio) %>%
  summarise(p1564 = sum(poblacion, na.rm = TRUE), .groups = "drop")

# 65+
p65 <- ine %>%
  filter(edad_min >= 65) %>%
  group_by(anio) %>%
  summarise(p65 = sum(poblacion, na.rm = TRUE), .groups = "drop")

# Índice dependencia total = (0–14 + 65+) / (15–64) * 100
dep_ine <- p014 %>%
  inner_join(p1564, by = "anio") %>%
  inner_join(p65, by = "anio") %>%
  mutate(
    indice_dependencia = ((p014 + p65) / p1564) * 100,
    fuente = "INE"
  ) %>%
  select(anio, indice_dependencia, fuente) %>%
  arrange(anio)

print(dep_ine)

# --- Guardar en PostgreSQL
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "montilla_db"), host = Sys.getenv("DB_HOST", "localhost"), port = as.integer(Sys.getenv("DB_PORT", "5432")),
  user = Sys.getenv("DB_USER", "montilla_user"), password = Sys.getenv("DB_PASS")
)

dbWriteTable(con, "indice_dependencia_ine", dep_ine, overwrite = TRUE)

dbGetQuery(con, "SELECT * FROM indice_dependencia_ine ORDER BY anio;")
dbDisconnect(con)