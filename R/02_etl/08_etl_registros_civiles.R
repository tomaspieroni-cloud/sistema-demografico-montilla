# ============================================================
# ETL REGISTROS CIVILES – Montilla
# Fuentes:
#   - Datos/Registros civiles/Matrimonios Montilla.txt
#   - (Nacimientos y Defunciones deben agregarse si existen archivos)
# Salida PostgreSQL: registros_civiles_montilla
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

library(tidyverse)
library(DBI)
library(RPostgres)

# -----------------------------------------------
# Función de conexión a PostgreSQL
# -----------------------------------------------
conectar_pg <- function() {
  DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = Sys.getenv("DB_NAME", "montilla_db"),
    host = Sys.getenv("DB_HOST", "localhost"),
    port = as.integer(Sys.getenv("DB_PORT", "5432")),
    user = Sys.getenv("DB_USER", "montilla_user"),
    password = Sys.getenv("DB_PASS")
  )
}

# -----------------------------------------------
# 1) MATRIMONIOS
# -----------------------------------------------
ruta_mat <- file.path("Datos", "Registros civiles", "Matrimonios Montilla.txt")
stopifnot(file.exists(ruta_mat))

matrimonios_raw <- read_delim(
  ruta_mat,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

cat("\n--- Matrimonios raw ---\n")
print(head(matrimonios_raw, 10))

matrimonios <- matrimonios_raw %>%
  select(
    anio = Anual,
    indicador = Medida,
    valor = Valor
  ) %>%
  mutate(
    anio = as.integer(anio),
    valor = as.numeric(valor)
  ) %>%
  filter(!is.na(valor)) %>%
  arrange(anio)

cat("\nMatrimonios cargados: ", nrow(matrimonios), "registros\n")

# -----------------------------------------------
# 2) NACIMIENTOS (si existe archivo)
# -----------------------------------------------
ruta_nac <- file.path("Datos", "Demograficos", "Nacimientos por sexo del recién nacido en Montilla.txt")

nacimientos <- NULL
if (file.exists(ruta_nac)) {
  nacimientos_raw <- read_delim(
    ruta_nac,
    delim = ";",
    locale = locale(decimal_mark = ",", encoding = "UTF-8"),
    trim_ws = TRUE
  )
  
  nacimientos <- nacimientos_raw %>%
    select(
      anio = contains("Anual", ignore.case = TRUE),
      valor = contains("Valor", ignore.case = TRUE)
    ) %>%
    mutate(
      anio = as.integer(anio),
      valor = as.numeric(valor),
      indicador = "Nacimientos"
    ) %>%
    filter(!is.na(valor)) %>%
    select(anio, indicador, valor) %>%
    arrange(anio)
  
  cat("\nNacimientos cargados: ", nrow(nacimientos), "registros\n")
} else {
  cat("\n⚠ Archivo de nacimientos no encontrado:", ruta_nac, "\n")
}

# -----------------------------------------------
# 3) DEFUNCIONES (si existe archivo)
# -----------------------------------------------
ruta_def <- file.path("Datos", "Demograficos", "Defunciones por sexo en Montilla.txt")

defunciones <- NULL
if (file.exists(ruta_def)) {
  defunciones_raw <- read_delim(
    ruta_def,
    delim = ";",
    locale = locale(decimal_mark = ",", encoding = "UTF-8"),
    trim_ws = TRUE
  )
  
  defunciones <- defunciones_raw %>%
    select(
      anio = contains("Anual", ignore.case = TRUE),
      valor = contains("Valor", ignore.case = TRUE)
    ) %>%
    mutate(
      anio = as.integer(anio),
      valor = as.numeric(valor),
      indicador = "Defunciones"
    ) %>%
    filter(!is.na(valor)) %>%
    select(anio, indicador, valor) %>%
    arrange(anio)
  
  cat("\nDefunciones cargadas: ", nrow(defunciones), "registros\n")
} else {
  cat("\n⚠ Archivo de defunciones no encontrado:", ruta_def, "\n")
}

# -----------------------------------------------
# Unir todo (si existen datos)
# -----------------------------------------------
registros_civiles <- matrimonios

if (!is.null(nacimientos)) {
  registros_civiles <- bind_rows(registros_civiles, nacimientos)
}

if (!is.null(defunciones)) {
  registros_civiles <- bind_rows(registros_civiles, defunciones)
}

cat("\nTotal de registros a cargar:", nrow(registros_civiles), "\n")
print(head(registros_civiles, 15))

# -----------------------------------------------
# Carga a PostgreSQL
# -----------------------------------------------
con <- conectar_pg()

tryCatch({
  # Elimina tabla anterior
  dbExecute(con, "DROP TABLE IF EXISTS registros_civiles_montilla")
  
  # Crea tabla nueva
  dbWriteTable(con, "registros_civiles_montilla", registros_civiles, overwrite = TRUE)
  
  # Crea índices
  dbExecute(con, "CREATE INDEX idx_rc_anio ON registros_civiles_montilla(anio)")
  dbExecute(con, "CREATE INDEX idx_rc_indicador ON registros_civiles_montilla(indicador)")
  
  cat("\n✓ Tabla registros_civiles_montilla guardada en PostgreSQL\n")
  
  # Verifica
  verificacion <- dbGetQuery(con, "
    SELECT 
      indicador,
      COUNT(*) as registros,
      MIN(anio) as anio_min,
      MAX(anio) as anio_max
    FROM registros_civiles_montilla
    GROUP BY indicador
    ORDER BY indicador
  ")
  print(verificacion)
  
}, error = function(e) {
  cat("\n✗ Error al cargar datos:", conditionMessage(e), "\n")
}, finally = {
  dbDisconnect(con)
})
