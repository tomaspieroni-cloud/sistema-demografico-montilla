# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))
getwd()

# ============================================================
# ETL IECA - Índice de Envejecimiento
# Municipio: Montilla
# Fuente: SIMA / IECA
# Serie: 1996–2022 (sin 1997)
# Archivo: Documento de texto (.txt)
# ============================================================

# -------------------------------
# 1. Librerías
# -------------------------------
library(tidyverse)
library(DBI)
library(RPostgres)

# -------------------------------
# 2. Ruta al archivo (relativa)
# -------------------------------
base_path <- "Datos"
ruta_ieca <- file.path(
  base_path,
  "Otros",
  "indice de envejecimiento Montilla.txt"
)

# -------------------------------
# 3. Comprobación de existencia
# -------------------------------
if (!file.exists(ruta_ieca)) {
  stop("❌ El archivo no se encuentra en la ruta indicada: ", ruta_ieca)
}

# -------------------------------
# 4. Lectura del archivo IECA
#    (formato habitual SIMA: ; y coma decimal)
# -------------------------------
ieca_raw <- read_delim(
  ruta_ieca,
  delim = ";",
  locale = locale(
    decimal_mark = ",",
    encoding = "UTF-8"
  ),
  trim_ws = TRUE
)

# Inspección inicial
glimpse(ieca_raw)
names(ieca_raw)

# -------------------------------
# 5. Limpieza y estandarización
# -------------------------------

indice_ieca <- ieca_raw %>%
  select(
    anio = Anual,
    indice_envejecimiento = Valor
  ) %>%
  mutate(
    anio = as.integer(anio),
    indice_envejecimiento = as.numeric(indice_envejecimiento),
    fuente = "IECA"
  ) %>%
  arrange(anio)

# Validación
glimpse(indice_ieca)
summary(indice_ieca)
print(indice_ieca)


# -------------------------------
# 6. Conexión a PostgreSQL
# -------------------------------
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "montilla_db"),
  host = Sys.getenv("DB_HOST", "localhost"),
  port = as.integer(Sys.getenv("DB_PORT", "5432")),
  user = Sys.getenv("DB_USER", "montilla_user"),
  password = Sys.getenv("DB_PASS")
)

# -------------------------------
# 7. Escritura en PostgreSQL
# -------------------------------
dbWriteTable(
  con,
  name = "indice_envejecimiento_ieca",
  value = indice_ieca,
  overwrite = TRUE
)

# -------------------------------
# 8. Verificación
# -------------------------------
dbListTables(con)

dbGetQuery(
  con,
  "SELECT * FROM indice_envejecimiento_ieca ORDER BY anio LIMIT 10"
)

# -------------------------------
# 9. Cierre de conexión
# -------------------------------
dbDisconnect(con)
