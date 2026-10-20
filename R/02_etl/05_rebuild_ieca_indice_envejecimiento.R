# ============================================================
# Rebuild controlado - indice de envejecimiento IECA
# Fuente:
# - Datos/Otros/indice de envejecimiento Montilla.txt
#
# Objetivo:
# - Reconstruir indice_envejecimiento_ieca con serie larga
# - Periodo esperado: 1996-2022, sin 1997
# - Corregir parseo numerico de valores con coma decimal
# - No modifica otras tablas
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
  library(dplyr)
  library(readr)
  library(stringr)
})

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "montilla_db"),
  host = Sys.getenv("DB_HOST", "localhost"),
  port = as.integer(Sys.getenv("DB_PORT", "5432")),
  user = Sys.getenv("DB_USER", "montilla_user"),
  password = Sys.getenv("DB_PASS")
)

on.exit(dbDisconnect(con), add = TRUE)

# ============================================================
# 1) Funcion segura para parsear numeros
# ============================================================

parse_valor_seguro <- function(x) {
  if (is.numeric(x)) {
    return(as.numeric(x))
  }
  
  x_chr <- as.character(x)
  
  x_chr <- stringr::str_replace_all(x_chr, "\\.", "")
  x_chr <- stringr::str_replace_all(x_chr, ",", ".")
  
  suppressWarnings(as.numeric(x_chr))
}

# ============================================================
# 2) Leer archivo fuente IECA como texto
# Se fuerza col_types = cols(.default = col_character())
# para evitar conversiones automaticas incorrectas
# ============================================================

ruta_ieca <- file.path(
  "Datos",
  "Otros",
  "indice de envejecimiento Montilla.txt"
)

if (!file.exists(ruta_ieca)) {
  stop("No se encontro el archivo: ", ruta_ieca)
}

ieca_raw <- read_delim(
  ruta_ieca,
  delim = ";",
  locale = locale(encoding = "UTF-8"),
  trim_ws = TRUE,
  col_types = cols(.default = col_character())
)

cat("\nColumnas detectadas:\n")
print(names(ieca_raw))

cat("\nPrimeras filas originales:\n")
print(head(ieca_raw, 10))

# ============================================================
# 3) Limpiar y normalizar
# ============================================================

indice_envejecimiento_ieca <- ieca_raw %>%
  transmute(
    municipio = as.character(`Lugar de residencia`),
    anio = as.integer(Anual),
    indicador = as.character(Edad),
    medida = as.character(Medida),
    indice_envejecimiento = parse_valor_seguro(Valor),
    fuente = "IECA"
  ) %>%
  filter(
    str_detect(str_to_lower(municipio), "montilla"),
    str_detect(str_to_lower(indicador), "envejecimiento"),
    !is.na(anio),
    !is.na(indice_envejecimiento)
  ) %>%
  arrange(anio)

if (nrow(indice_envejecimiento_ieca) == 0) {
  stop("La tabla indice_envejecimiento_ieca quedo vacia.")
}

# ============================================================
# 4) Control de valores razonables
# El indice de envejecimiento debe estar aproximadamente entre 0 y 300
# ============================================================

valores_fuera_de_rango <- indice_envejecimiento_ieca %>%
  filter(indice_envejecimiento < 0 | indice_envejecimiento > 300)

if (nrow(valores_fuera_de_rango) > 0) {
  cat("\nValores fuera de rango detectados:\n")
  print(valores_fuera_de_rango)
  stop("Hay valores fuera de rango. Revisar parseo antes de guardar.")
}

# ============================================================
# 5) Guardar en PostgreSQL
# ============================================================

dbWriteTable(
  con,
  "indice_envejecimiento_ieca",
  indice_envejecimiento_ieca,
  overwrite = TRUE
)

dbExecute(
  con,
  "CREATE INDEX IF NOT EXISTS idx_indice_envejecimiento_ieca_anio ON indice_envejecimiento_ieca(anio);"
)

# ============================================================
# 6) Verificaciones
# ============================================================

cat("\nResumen indice_envejecimiento_ieca:\n")

print(dbGetQuery(con, "
  SELECT 
    COUNT(*) AS filas,
    MIN(anio) AS primer_anio,
    MAX(anio) AS ultimo_anio
  FROM indice_envejecimiento_ieca;
"))

cat("\nAnios disponibles:\n")

print(dbGetQuery(con, "
  SELECT anio
  FROM indice_envejecimiento_ieca
  ORDER BY anio;
"))

cat("\nPrimeras filas finales:\n")

print(dbGetQuery(con, "
  SELECT anio, indice_envejecimiento, fuente
  FROM indice_envejecimiento_ieca
  ORDER BY anio
  LIMIT 10;
"))

cat("\nUltimas filas finales:\n")

print(dbGetQuery(con, "
  SELECT anio, indice_envejecimiento, fuente
  FROM indice_envejecimiento_ieca
  ORDER BY anio DESC
  LIMIT 10;
"))

cat("\nControl de rango final:\n")

print(dbGetQuery(con, "
  SELECT 
    MIN(indice_envejecimiento) AS minimo,
    MAX(indice_envejecimiento) AS maximo
  FROM indice_envejecimiento_ieca;
"))
cat("\nProceso terminado correctamente.\n")