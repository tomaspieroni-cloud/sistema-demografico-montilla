




# ============================================================
# Inspeccion de fuentes para nacimientos y defunciones
# No modifica ninguna tabla
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

cat("\nArchivos en Datos/Demograficos:\n")
print(list.files("Datos/Demograficos", full.names = TRUE))

cat("\nArchivos en Datos que contienen registro, defuncion, nacimiento o civil:\n")
print(list.files(
  "Datos",
  pattern = "registro|defunc|nacim|civil",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = TRUE
))

ruta_nacimientos <- file.path(
  "Datos",
  "Demograficos",
  "Nacimientos por sexo del recién nacido en Montilla.txt"
)

cat("\nExiste archivo de nacimientos:\n")
print(file.exists(ruta_nacimientos))

if (file.exists(ruta_nacimientos)) {
  cat("\nPrimeras lineas del archivo de nacimientos:\n")
  print(readLines(ruta_nacimientos, n = 10, warn = FALSE, encoding = "UTF-8"))
}

cat("\nBuscar referencias a defunciones y nacimientos en scripts:\n")
scripts <- list.files("Scripts", pattern = "\\.R$", full.names = TRUE)

for (s in scripts) {
  lineas <- readLines(s, warn = FALSE, encoding = "UTF-8")
  hits <- grep("defunc|nacim|saldo_natural|b14|b15", lineas, ignore.case = TRUE, value = TRUE)
  if (length(hits) > 0) {
    cat("\nArchivo:", s, "\n")
    print(head(hits, 30))
  }
}










# ============================================================
# Rebuild controlado - crecimiento natural Montilla
# Reconstruye:
# - nacimientos_montilla
# - defunciones_montilla
# - crecimiento_natural_rebuild
# - vista montilla_indicadores_migracion_fix
#
# No modifica montilla_indicadores_final_long
# No modifica migracion_rebuild
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

detectar_columna <- function(df, patrones) {
  nms <- names(df)
  nms_low <- str_to_lower(nms)
  idx <- which(Reduce(`|`, lapply(patrones, function(p) str_detect(nms_low, p))))
  if (length(idx) == 0) return(NA_character_)
  nms[idx[1]]
}

parse_num <- function(x) {
  readr::parse_number(
    as.character(x),
    locale = readr::locale(decimal_mark = ",")
  )
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
# 1) Nacimientos Montilla
# ============================================================

ruta_nacimientos <- file.path(
  "Datos",
  "Demograficos",
  "Nacimientos por sexo del recién nacido en Montilla.txt"
)

if (!file.exists(ruta_nacimientos)) {
  stop("No se encontró el archivo de nacimientos: ", ruta_nacimientos)
}

nac_raw <- read_delim(
  ruta_nacimientos,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE,
  show_col_types = FALSE
)

col_nac_anio <- detectar_columna(nac_raw, c("^anual$", "^anio$", "^año$", "year"))
col_nac_sexo <- detectar_columna(nac_raw, c("^sexo$"))
col_nac_medida <- detectar_columna(nac_raw, c("^medida$"))
col_nac_valor <- detectar_columna(nac_raw, c("^valor$"))

if (any(is.na(c(col_nac_anio, col_nac_medida, col_nac_valor)))) {
  stop(
    "No se detectaron columnas necesarias en nacimientos. Columnas encontradas: ",
    paste(names(nac_raw), collapse = ", ")
  )
}

nac_tmp <- nac_raw %>%
  transmute(
    anio = as.integer(.data[[col_nac_anio]]),
    sexo = if (!is.na(col_nac_sexo)) as.character(.data[[col_nac_sexo]]) else NA_character_,
    medida = as.character(.data[[col_nac_medida]]),
    valor = parse_num(.data[[col_nac_valor]])
  ) %>%
  filter(
    !is.na(anio),
    !is.na(valor),
    str_detect(str_to_lower(medida), "nac")
  )

if (!all(is.na(nac_tmp$sexo))) {
  if (any(str_to_lower(str_squish(nac_tmp$sexo)) %in% c("ambos sexos", "total"))) {
    nac_tmp <- nac_tmp %>%
      filter(str_to_lower(str_squish(sexo)) %in% c("ambos sexos", "total"))
  }
}

nacimientos_montilla <- nac_tmp %>%
  group_by(anio) %>%
  summarise(nacimientos = sum(valor, na.rm = TRUE), .groups = "drop") %>%
  arrange(anio)

if (nrow(nacimientos_montilla) == 0) {
  stop("La tabla nacimientos_montilla quedó vacía.")
}

dbWriteTable(con, "nacimientos_montilla", nacimientos_montilla, overwrite = TRUE)
dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_nacimientos_montilla_anio ON nacimientos_montilla(anio);")

cat("\nNacimientos cargados:\n")
print(dbGetQuery(con, "
  SELECT COUNT(*) AS filas, MIN(anio) AS primer_anio, MAX(anio) AS ultimo_anio
  FROM nacimientos_montilla;
"))

# ============================================================
# 2) Defunciones Montilla
# ============================================================

ruta_defunciones <- file.path(
  "Datos",
  "Demograficos",
  "ieca_export.txt"
)

if (!file.exists(ruta_defunciones)) {
  stop("No se encontró el archivo de defunciones IECA: ", ruta_defunciones)
}

def_raw <- read_delim(
  ruta_defunciones,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE,
  show_col_types = FALSE
)

col_def_anio <- detectar_columna(def_raw, c("^anual$", "^anio$", "^año$", "year"))
col_def_sexo <- detectar_columna(def_raw, c("^sexo$"))
col_def_medida <- detectar_columna(def_raw, c("^medida$"))
col_def_valor <- detectar_columna(def_raw, c("^valor$"))
col_def_lugar <- detectar_columna(def_raw, c("lugar", "municip", "resid"))

if (any(is.na(c(col_def_anio, col_def_medida, col_def_valor)))) {
  stop(
    "No se detectaron columnas necesarias en defunciones. Columnas encontradas: ",
    paste(names(def_raw), collapse = ", ")
  )
}

def_tmp <- def_raw %>%
  transmute(
    anio = as.integer(.data[[col_def_anio]]),
    lugar = if (!is.na(col_def_lugar)) as.character(.data[[col_def_lugar]]) else NA_character_,
    sexo = if (!is.na(col_def_sexo)) as.character(.data[[col_def_sexo]]) else NA_character_,
    medida = as.character(.data[[col_def_medida]]),
    valor = parse_num(.data[[col_def_valor]])
  ) %>%
  filter(
    !is.na(anio),
    !is.na(valor),
    str_detect(str_to_lower(medida), "defunc")
  )

if (!all(is.na(def_tmp$lugar))) {
  if (any(str_detect(str_to_lower(def_tmp$lugar), "montilla"))) {
    def_tmp <- def_tmp %>%
      filter(str_detect(str_to_lower(lugar), "montilla"))
  }
}

if (!all(is.na(def_tmp$sexo))) {
  if (any(str_to_lower(str_squish(def_tmp$sexo)) %in% c("ambos sexos", "total"))) {
    def_tmp <- def_tmp %>%
      filter(str_to_lower(str_squish(sexo)) %in% c("ambos sexos", "total"))
  }
}

defunciones_montilla <- def_tmp %>%
  group_by(anio) %>%
  summarise(defunciones = sum(valor, na.rm = TRUE), .groups = "drop") %>%
  arrange(anio)

if (nrow(defunciones_montilla) == 0) {
  stop("La tabla defunciones_montilla quedó vacía.")
}

dbWriteTable(con, "defunciones_montilla", defunciones_montilla, overwrite = TRUE)
dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_defunciones_montilla_anio ON defunciones_montilla(anio);")

cat("\nDefunciones cargadas:\n")
print(dbGetQuery(con, "
  SELECT COUNT(*) AS filas, MIN(anio) AS primer_anio, MAX(anio) AS ultimo_anio
  FROM defunciones_montilla;
"))

# ============================================================
# 3) Crear crecimiento_natural_rebuild en formato long
# ============================================================

saldo_natural <- nacimientos_montilla %>%
  inner_join(defunciones_montilla, by = "anio") %>%
  mutate(saldo_natural = nacimientos - defunciones) %>%
  arrange(anio)

if (nrow(saldo_natural) == 0) {
  stop("No hay años comunes entre nacimientos y defunciones.")
}

crecimiento_natural_rebuild <- bind_rows(
  nacimientos_montilla %>%
    transmute(
      cod_ine = 14042L,
      municipio = "Montilla",
      anio,
      bloque = "Población",
      indicador_id = "b14",
      indicador_nombre = "Nacimientos",
      unidad = "personas",
      fuente = "IECA",
      valor = as.numeric(nacimientos),
      valor_texto = NA_character_
    ),
  defunciones_montilla %>%
    transmute(
      cod_ine = 14042L,
      municipio = "Montilla",
      anio,
      bloque = "Población",
      indicador_id = "b15",
      indicador_nombre = "Defunciones",
      unidad = "personas",
      fuente = "IECA",
      valor = as.numeric(defunciones),
      valor_texto = NA_character_
    ),
  saldo_natural %>%
    transmute(
      cod_ine = 14042L,
      municipio = "Montilla",
      anio,
      bloque = "Población",
      indicador_id = "saldo_natural",
      indicador_nombre = "Saldo vegetativo",
      unidad = "personas",
      fuente = "IECA",
      valor = as.numeric(saldo_natural),
      valor_texto = NA_character_
    )
)

dbWriteTable(con, "crecimiento_natural_rebuild", crecimiento_natural_rebuild, overwrite = TRUE)

cat("\nCrecimiento natural reconstruido:\n")
print(dbGetQuery(con, "
  SELECT indicador_id, indicador_nombre, COUNT(*) AS filas, MIN(anio) AS primer_anio, MAX(anio) AS ultimo_anio
  FROM crecimiento_natural_rebuild
  GROUP BY indicador_id, indicador_nombre
  ORDER BY indicador_id;
"))

# ============================================================
# 4) Recrear vista final corregida
# Integra:
# - montilla_indicadores_final_long sin b12, b13, b14, b15, saldo_natural
# - migracion_rebuild para b12 y b13
# - crecimiento_natural_rebuild para b14, b15 y saldo_natural
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

cat("\nVista final recreada:\n")
print(dbGetQuery(con, "
  SELECT table_name, table_type
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name = 'montilla_indicadores_migracion_fix';
"))

cat("\nVerificacion final de indicadores principales:\n")
print(dbGetQuery(con, "
  SELECT 
    indicador_id,
    indicador_nombre,
    COUNT(*) AS filas,
    MIN(anio) AS primer_anio,
    MAX(anio) AS ultimo_anio
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN (
    'b01','b06','b07','b08',
    'b12','b13','b14','b15',
    'saldo_natural','densidad'
  )
  GROUP BY indicador_id, indicador_nombre
  ORDER BY indicador_id;
"))

cat("\nProceso terminado correctamente.\n")