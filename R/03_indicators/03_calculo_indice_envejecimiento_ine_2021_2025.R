# ============================================================
# ETL INE - Índice de Envejecimiento (cálculo propio)
# Fuente: INE - Censo anual de población
# Periodo: 2021–2025
# Formato: CSV separado por ;
# ============================================================

# -------------------------------
# 0. Working directory
# -------------------------------
# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))
getwd()

# -------------------------------
# 1. Librerías
# -------------------------------
library(tidyverse)
library(DBI)
library(RPostgres)

# -------------------------------
# 2. Ruta al CSV INE
# -------------------------------
ruta_ine <- file.path(
  "Datos",
  "Demograficos",
  "Censo anual de población 2021-2025 - Población por sexo, edad (grupos quinquenales).csv"
)

if (!file.exists(ruta_ine)) {
  stop("❌ No se encuentra el archivo INE: ", ruta_ine)
}

# -------------------------------
# 3. Lectura del CSV (INE)
# -------------------------------
ine_raw <- read_delim(
  ruta_ine,
  delim = ";",
  locale = locale(
    decimal_mark = ",",
    encoding = "UTF-8"
  ),
  trim_ws = TRUE
)

# Inspección obligatoria
glimpse(ine_raw)
names(ine_raw)

# -------------------------------
# 4. Limpieza mínima
# -------------------------------

ine_clean <- ine_raw %>%
  select(
    anio       = Periodo,
    sexo       = Sexo,
    grupo_edad = Edad,
    poblacion  = Total
  ) %>%
  mutate(
    anio = as.integer(anio),
    poblacion = as.numeric(poblacion)
  )

# Validación obligatoria
glimpse(ine_clean)
table(ine_clean$grupo_edad)
table(ine_clean$sexo)
table(ine_clean$anio)

# -------------------------------
# 4bis. Normalizar texto de edad (encoding)
# -------------------------------
library(stringi)

ine_clean <- ine_clean %>%
  mutate(
    grupo_edad_norm = stri_trans_general(grupo_edad, "Latin-ASCII")
  )

# Comprobación
table(ine_clean$grupo_edad_norm)



# -------------------------------
# 5. Agrupar edades para el índice (FORMA ROBUSTA)
# -------------------------------

ine_clean <- ine_clean %>%
  mutate(
    edad_min = as.numeric(str_extract(grupo_edad, "\\d+"))
  )

pob_014 <- ine_clean %>%
  filter(!is.na(edad_min), edad_min < 15) %>%
  group_by(anio) %>%
  summarise(
    pob_014 = sum(poblacion, na.rm = TRUE),
    .groups = "drop"
  )

pob_65_mas <- ine_clean %>%
  filter(!is.na(edad_min), edad_min >= 65) %>%
  group_by(anio) %>%
  summarise(
    pob_65 = sum(poblacion, na.rm = TRUE),
    .groups = "drop"
  )



# -------------------------------
# 6. Cálculo del índice
# -------------------------------

indice_ine <- pob_014 %>%
  inner_join(pob_65_mas, by = "anio") %>%
  mutate(
    indice_envejecimiento = (pob_65 / pob_014) * 100,
    fuente = "INE"
  ) %>%
  select(anio, indice_envejecimiento, fuente) %>%
  arrange(anio)

# Validación
glimpse(indice_ine)
summary(indice_ine)
print(indice_ine)



# -------------------------------
# 7. Guardar en PostgreSQL
# -------------------------------
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "montilla_db"),
  host = Sys.getenv("DB_HOST", "localhost"),
  port = as.integer(Sys.getenv("DB_PORT", "5432")),
  user = Sys.getenv("DB_USER", "montilla_user"),
  password = Sys.getenv("DB_PASS")
)

dbWriteTable(
  con,
  name = "indice_envejecimiento_ine",
  value = indice_ine,
  overwrite = TRUE
)

dbListTables(con)

dbGetQuery(
  con,
  "SELECT * FROM indice_envejecimiento_ine ORDER BY anio"
)

dbDisconnect(con)