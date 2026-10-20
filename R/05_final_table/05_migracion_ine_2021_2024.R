# ============================================================
# Rebuild controlado - extension INE EMCR 2021-2024 para b12/b13
# Objetivo:
# - Leer flujos INE EMCR descargados desde CSV
# - Construir inmigraciones y emigraciones totales para Montilla
# - Combinar:
#   2003-2021 IECA
#   2022-2024 INE
# - Actualizar migracion_rebuild
# - Recrear vista montilla_indicadores_migracion_fix
#
# No modifica montilla_indicadores_final_long
# No modifica crecimiento_natural_rebuild
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
  library(dplyr)
  library(readr)
  library(stringr)
  library(tibble)
  library(purrr)
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
# Funciones auxiliares
# ============================================================

leer_csv_ine <- function(ruta) {
  if (!file.exists(ruta)) {
    stop("No existe el archivo: ", ruta)
  }
  
  readr::read_delim(
    ruta,
    delim = ";",
    locale = readr::locale(
      encoding = "UTF-8",
      decimal_mark = ",",
      grouping_mark = "."
    ),
    trim_ws = TRUE,
    show_col_types = FALSE
  )
}

parse_total_ine <- function(x) {
  readr::parse_number(
    as.character(x),
    locale = readr::locale(
      decimal_mark = ",",
      grouping_mark = "."
    )
  )
}

extraer_montilla_exterior <- function(ruta, nombre_valor) {
  df <- leer_csv_ine(ruta)
  
  cols_necesarias <- c("Municipios", "Sexo", "Periodo", "Total")
  faltan <- setdiff(cols_necesarias, names(df))
  
  if (length(faltan) > 0) {
    stop("Faltan columnas en ", ruta, ": ", paste(faltan, collapse = ", "))
  }
  
  df %>%
    filter(
      str_detect(as.character(Municipios), "14042"),
      Sexo == "Ambos sexos"
    ) %>%
    transmute(
      anio = as.integer(Periodo),
      !!nombre_valor := parse_total_ine(Total)
    ) %>%
    filter(!is.na(anio)) %>%
    group_by(anio) %>%
    summarise(
      across(all_of(nombre_valor), ~ sum(.x, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(anio)
}

extraer_montilla_intermunicipal <- function(ruta, nombre_valor) {
  df <- leer_csv_ine(ruta)
  
  cols_necesarias <- c("Municipios", "Nacionalidad", "Sexo", "Periodo", "Total")
  faltan <- setdiff(cols_necesarias, names(df))
  
  if (length(faltan) > 0) {
    stop("Faltan columnas en ", ruta, ": ", paste(faltan, collapse = ", "))
  }
  
  df %>%
    filter(
      str_detect(as.character(Municipios), "14042"),
      Nacionalidad == "Total",
      Sexo == "Ambos sexos"
    ) %>%
    transmute(
      anio = as.integer(Periodo),
      !!nombre_valor := parse_total_ine(Total)
    ) %>%
    filter(!is.na(anio)) %>%
    group_by(anio) %>%
    summarise(
      across(all_of(nombre_valor), ~ sum(.x, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(anio)
}

drop_objeto_si_existe <- function(con, nombre_objeto) {
  sql <- sprintf("
DO $$
DECLARE
  objeto_tipo char;
BEGIN
  SELECT c.relkind
  INTO objeto_tipo
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname = '%s';

  IF objeto_tipo = 'v' THEN
    EXECUTE 'DROP VIEW public.%s CASCADE';
  ELSIF objeto_tipo = 'r' THEN
    EXECUTE 'DROP TABLE public.%s CASCADE';
  ELSIF objeto_tipo = 'm' THEN
    EXECUTE 'DROP MATERIALIZED VIEW public.%s CASCADE';
  END IF;
END $$;
", nombre_objeto, nombre_objeto, nombre_objeto, nombre_objeto)
  
  dbExecute(con, sql)
}

# ============================================================
# 1) Rutas de archivos INE EMCR
# ============================================================

ruta_inm_ext <- file.path(
  "Datos", "Raw", "INE_EMCR",
  "ine_69696_inmigracion_exterior.csv"
)

ruta_emi_ext <- file.path(
  "Datos", "Raw", "INE_EMCR",
  "ine_69711_emigracion_exterior.csv"
)

ruta_inm_int <- file.path(
  "Datos", "Raw", "INE_EMCR",
  "ine_69743_inmigracion_intermunicipal.csv"
)

ruta_emi_int <- file.path(
  "Datos", "Raw", "INE_EMCR",
  "ine_69745_emigracion_intermunicipal.csv"
)

# ============================================================
# 2) Extraer Montilla
# ============================================================

inm_ext <- extraer_montilla_exterior(ruta_inm_ext, "inmigracion_exterior")
emi_ext <- extraer_montilla_exterior(ruta_emi_ext, "emigracion_exterior")
inm_int <- extraer_montilla_intermunicipal(ruta_inm_int, "inmigracion_intermunicipal")
emi_int <- extraer_montilla_intermunicipal(ruta_emi_int, "emigracion_intermunicipal")

cat("\nInmigracion exterior Montilla:\n")
print(inm_ext)

cat("\nEmigracion exterior Montilla:\n")
print(emi_ext)

cat("\nInmigracion intermunicipal Montilla:\n")
print(inm_int)

cat("\nEmigracion intermunicipal Montilla:\n")
print(emi_int)

# ============================================================
# 3) Construir total INE 2021-2024
# ============================================================

migracion_ine_2021_2024_total <- list(inm_ext, emi_ext, inm_int, emi_int) %>%
  reduce(full_join, by = "anio") %>%
  mutate(
    inmigracion_exterior = coalesce(inmigracion_exterior, 0),
    emigracion_exterior = coalesce(emigracion_exterior, 0),
    inmigracion_intermunicipal = coalesce(inmigracion_intermunicipal, 0),
    emigracion_intermunicipal = coalesce(emigracion_intermunicipal, 0),
    inmigraciones = inmigracion_exterior + inmigracion_intermunicipal,
    emigraciones = emigracion_exterior + emigracion_intermunicipal,
    saldo_migratorio_calculado = inmigraciones - emigraciones,
    fuente = "INE_EMCR"
  ) %>%
  arrange(anio)

dbWriteTable(
  con,
  "migracion_ine_2021_2024_total",
  migracion_ine_2021_2024_total,
  overwrite = TRUE
)

cat("\nTabla migracion_ine_2021_2024_total:\n")
print(migracion_ine_2021_2024_total)

# ============================================================
# 4) Validar saldo calculado contra saldo_migratorio_ine_2021_2024
# ============================================================

if (dbExistsTable(con, "saldo_migratorio_ine_2021_2024")) {
  saldo_ine <- dbGetQuery(con, "
    SELECT anio, saldo_migratorio
    FROM saldo_migratorio_ine_2021_2024
    ORDER BY anio;
  ") %>%
    as_tibble() %>%
    mutate(
      anio = as.integer(anio),
      saldo_migratorio = as.numeric(saldo_migratorio)
    )
  
  check_saldo <- migracion_ine_2021_2024_total %>%
    left_join(saldo_ine, by = "anio") %>%
    mutate(
      diferencia = saldo_migratorio_calculado - saldo_migratorio
    ) %>%
    select(
      anio,
      inmigraciones,
      emigraciones,
      saldo_migratorio_calculado,
      saldo_migratorio,
      diferencia
    )
  
  cat("\nValidacion contra saldo INE oficial:\n")
  print(check_saldo)
} else {
  cat("\nNo existe saldo_migratorio_ine_2021_2024 para validar.\n")
}

# ============================================================
# 5) Reconstruir migracion_rebuild
# 2003-2021 IECA
# 2022-2024 INE EMCR
# ============================================================

suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
  library(dplyr)
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

# Comprobar que el objeto migracion_rebuild_nueva existe en memoria
if (!exists("migracion_rebuild_nueva")) {
  stop("No existe el objeto migracion_rebuild_nueva en memoria. En ese caso hay que correr de nuevo el script hasta antes de dbWriteTable.")
}

# Eliminar vista dependiente
dbExecute(con, "
  DROP VIEW IF EXISTS montilla_indicadores_migracion_fix CASCADE;
")

# Sobrescribir tabla migracion_rebuild
dbWriteTable(
  con,
  "migracion_rebuild",
  migracion_rebuild_nueva,
  overwrite = TRUE
)

# Recrear vista final
dbExecute(con, "
  CREATE VIEW montilla_indicadores_migracion_fix AS
  SELECT
    cod_ine,
    municipio,
    anio,
    bloque,
    indicador_id,
    indicador_nombre,
    unidad,
    fuente,
    valor,
    valor_texto
  FROM montilla_indicadores_final_long
  WHERE indicador_id NOT IN ('b12','b13','b14','b15','saldo_natural')

  UNION ALL

  SELECT
    cod_ine,
    municipio,
    anio,
    bloque,
    indicador_id,
    indicador_nombre,
    unidad,
    fuente,
    valor,
    valor_texto
  FROM migracion_rebuild

  UNION ALL

  SELECT
    cod_ine,
    municipio,
    anio,
    bloque,
    indicador_id,
    indicador_nombre,
    unidad,
    fuente,
    valor,
    valor_texto
  FROM crecimiento_natural_rebuild;
")

cat("\nVerificacion final b12/b13:\n")

print(dbGetQuery(con, "
  SELECT
    indicador_id,
    indicador_nombre,
    COUNT(*) AS filas,
    MIN(anio) AS primer_anio,
    MAX(anio) AS ultimo_anio
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN ('b12','b13')
  GROUP BY indicador_id, indicador_nombre
  ORDER BY indicador_id;
"))

cat("\nDetalle b12/b13 2020-2024:\n")

print(dbGetQuery(con, "
  SELECT anio, indicador_id, indicador_nombre, fuente, valor
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN ('b12','b13')
    AND anio BETWEEN 2020 AND 2024
  ORDER BY anio, indicador_id;
"))

cat("\nDuplicados b12/b13 por anio:\n")

print(dbGetQuery(con, "
  SELECT indicador_id, anio, COUNT(*) AS n
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN ('b12','b13')
  GROUP BY indicador_id, anio
  HAVING COUNT(*) > 1
  ORDER BY indicador_id, anio;
"))

cat("\nReparacion terminada correctamente.\n")

# ============================================================
# 6) Recrear vista final
# ============================================================

drop_objeto_si_existe(con, "montilla_indicadores_migracion_fix")

dbExecute(con, "
  CREATE VIEW montilla_indicadores_migracion_fix AS
  SELECT
    cod_ine,
    municipio,
    anio,
    bloque,
    indicador_id,
    indicador_nombre,
    unidad,
    fuente,
    valor,
    valor_texto
  FROM montilla_indicadores_final_long
  WHERE indicador_id NOT IN ('b12','b13','b14','b15','saldo_natural')

  UNION ALL

  SELECT
    cod_ine,
    municipio,
    anio,
    bloque,
    indicador_id,
    indicador_nombre,
    unidad,
    fuente,
    valor,
    valor_texto
  FROM migracion_rebuild

  UNION ALL

  SELECT
    cod_ine,
    municipio,
    anio,
    bloque,
    indicador_id,
    indicador_nombre,
    unidad,
    fuente,
    valor,
    valor_texto
  FROM crecimiento_natural_rebuild;
")

# ============================================================
# 7) Verificacion final
# ============================================================

cat("\nVerificacion final b12/b13:\n")
print(dbGetQuery(con, "
  SELECT
    indicador_id,
    indicador_nombre,
    COUNT(*) AS filas,
    MIN(anio) AS primer_anio,
    MAX(anio) AS ultimo_anio
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN ('b12','b13')
  GROUP BY indicador_id, indicador_nombre
  ORDER BY indicador_id;
"))

cat("\nDetalle b12/b13 2020-2024:\n")
print(dbGetQuery(con, "
  SELECT anio, indicador_id, indicador_nombre, fuente, valor
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN ('b12','b13')
    AND anio BETWEEN 2020 AND 2024
  ORDER BY anio, indicador_id;
"))

cat("\nDuplicados b12/b13 por anio:\n")
print(dbGetQuery(con, "
  SELECT indicador_id, anio, COUNT(*) AS n
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN ('b12','b13')
  GROUP BY indicador_id, anio
  HAVING COUNT(*) > 1
  ORDER BY indicador_id, anio;
"))

cat("\nProceso terminado correctamente.\n")