# ============================================================
# Rebuild controlado - b08 variacion 10 anos
# Fuente base:
# - Art.17 INE 1996-2025 por sexo desde JSON local
# - b01 2003-2025 desde montilla_indicadores_final_long
#
# Objetivo:
# - Recalcular b08 usando poblacion_t / poblacion_t-10
# - Conseguir primer valor valido en 2006
# - Actualizar solo b08 en montilla_indicadores_final_long
# - La vista montilla_indicadores_migracion_fix lo tomara automaticamente
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
  library(jsonlite)
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
# 1) Leer archivo Art.17
# ============================================================

ruta_art17 <- file.path(
  "Datos",
  "Demograficos",
  "población en aplicación de la Ley de Bases del Régimen Local por sexo.json"
)

if (!file.exists(ruta_art17)) {
  stop("No se encontro el archivo Art.17: ", ruta_art17)
}

art17_json <- jsonlite::fromJSON(ruta_art17, flatten = TRUE)

if (!is.data.frame(art17_json)) {
  stop("El objeto Art.17 no se cargo como data.frame.")
}

if (!all(c("Nombre", "Data") %in% names(art17_json))) {
  stop("El JSON Art.17 no contiene las columnas esperadas Nombre y Data.")
}

cat("\nSeries disponibles en Art.17:\n")
print(art17_json$Nombre)

# ============================================================
# 2) Extraer serie total Art.17 usando columnas reales Anyo y Valor
# ============================================================

idx_total <- which(
  str_detect(str_to_lower(art17_json$Nombre), "montilla") &
    str_detect(str_to_lower(art17_json$Nombre), "total") &
    str_detect(str_to_lower(art17_json$Nombre), "habitantes")
)[1]

if (is.na(idx_total)) {
  stop("No se encontro la serie total de Montilla en Art.17.")
}

data_total <- art17_json$Data[[idx_total]]

if (!all(c("Anyo", "Valor") %in% names(data_total))) {
  stop(
    "La serie total Art.17 no contiene columnas Anyo y Valor. Columnas encontradas: ",
    paste(names(data_total), collapse = ", ")
  )
}

art17_total <- data_total %>%
  transmute(
    anio = as.integer(Anyo),
    poblacion_total = as.numeric(Valor),
    fuente_base = "INE_Art17"
  ) %>%
  filter(!is.na(anio), !is.na(poblacion_total)) %>%
  arrange(anio)

cat("\nResumen Art.17 total:\n")
print(art17_total %>%
        summarise(
          filas = n(),
          primer_anio = min(anio),
          ultimo_anio = max(anio)
        ))

cat("\nArt.17 total 1996-2002:\n")
print(art17_total %>% filter(anio >= 1996, anio <= 2002))

# ============================================================
# 3) Leer b01 actual 2003-2025 desde tabla final
# ============================================================

b01_actual <- dbGetQuery(con, "
  SELECT anio, MAX(valor) AS poblacion_total
  FROM montilla_indicadores_final_long
  WHERE indicador_id = 'b01'
    AND valor IS NOT NULL
  GROUP BY anio
  ORDER BY anio;
") %>%
  as_tibble() %>%
  mutate(
    anio = as.integer(anio),
    poblacion_total = as.numeric(poblacion_total),
    fuente_base = "INE_serie_b01"
  )

if (nrow(b01_actual) == 0) {
  stop("No hay b01 en montilla_indicadores_final_long.")
}

cat("\nResumen b01 actual:\n")
print(b01_actual %>%
        summarise(
          filas = n(),
          primer_anio = min(anio),
          ultimo_anio = max(anio)
        ))

cat("\nb01 actual 2003-2008:\n")
print(b01_actual %>% filter(anio >= 2003, anio <= 2008))

# ============================================================
# 4) Construir serie base 1996-2025
# Se usa Art.17 para 1996-2002 y b01 para 2003-2025
# Si falta algun anio entre 1996 y 2002, se interpola linealmente
# ============================================================

base_1996_2002 <- art17_total %>%
  filter(anio >= 1996, anio <= 2002) %>%
  select(anio, poblacion_total, fuente_base)

if (nrow(base_1996_2002) == 0) {
  stop("Art.17 no contiene datos 1996-2002.")
}

base_1996_2002 <- tibble(anio = 1996:2002) %>%
  left_join(base_1996_2002, by = "anio") %>%
  arrange(anio)

if (any(is.na(base_1996_2002$poblacion_total))) {
  base_1996_2002$poblacion_total <- approx(
    x = base_1996_2002$anio[!is.na(base_1996_2002$poblacion_total)],
    y = base_1996_2002$poblacion_total[!is.na(base_1996_2002$poblacion_total)],
    xout = base_1996_2002$anio,
    rule = 2
  )$y
  
  base_1996_2002$fuente_base[is.na(base_1996_2002$fuente_base)] <- "INE_Art17_interpolado"
}

cat("\nBase Art.17 1996-2002 final:\n")
print(base_1996_2002)

serie_poblacion <- bind_rows(
  base_1996_2002,
  b01_actual %>% filter(anio >= 2003)
) %>%
  arrange(anio) %>%
  distinct(anio, .keep_all = TRUE)

cat("\nSerie base para b08:\n")
print(serie_poblacion %>%
        summarise(
          filas = n(),
          primer_anio = min(anio),
          ultimo_anio = max(anio)
        ))

cat("\nAnios faltantes entre 1996 y 2025:\n")
faltantes <- setdiff(1996:2025, serie_poblacion$anio)
print(faltantes)

if (length(faltantes) > 0) {
  stop("Faltan anios en la serie base. Revisar antes de calcular b08.")
}

# ============================================================
# 5) Recalcular b08 por anio real t-10
# ============================================================

serie_lag <- serie_poblacion %>%
  transmute(
    anio = anio + 10,
    poblacion_t10 = poblacion_total
  )

b08_rebuild <- serie_poblacion %>%
  left_join(serie_lag, by = "anio") %>%
  filter(anio >= 2003, anio <= 2025) %>%
  mutate(
    valor = (poblacion_total / poblacion_t10 - 1) * 100
  ) %>%
  transmute(
    cod_ine = 14042L,
    municipio = "Montilla",
    anio = as.integer(anio),
    bloque = "Población",
    indicador_id = "b08",
    indicador_nombre = "Variación relativa de la población en diez años",
    unidad = "%",
    fuente = "INE_serie",
    valor = as.numeric(valor),
    valor_texto = ifelse(
      is.na(valor),
      "NA: cálculo requiere t-10 (no disponible)",
      NA_character_
    )
  ) %>%
  arrange(anio)

cat("\nPreview b08 recalculado 2003-2010:\n")
print(b08_rebuild %>% filter(anio >= 2003, anio <= 2010))

cat("\nPrimer anio con valor en b08 recalculado:\n")
print(b08_rebuild %>%
        summarise(
          primer_anio_con_valor = min(anio[!is.na(valor)]),
          ultimo_anio_con_valor = max(anio[!is.na(valor)]),
          filas = n()
        ))

# ============================================================
# 6) Actualizar solo b08 en montilla_indicadores_final_long
# ============================================================

dbExecute(con, "
  DELETE FROM montilla_indicadores_final_long
  WHERE indicador_id = 'b08';
")

dbWriteTable(con, "tmp_b08_rebuild", b08_rebuild, overwrite = TRUE)

dbExecute(con, "
  INSERT INTO montilla_indicadores_final_long (
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
  )
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
  FROM tmp_b08_rebuild;
")

dbExecute(con, "DROP TABLE tmp_b08_rebuild;")

# ============================================================
# 7) Verificacion final en tabla final y vista corregida
# ============================================================

cat("\nVerificacion b08 en montilla_indicadores_final_long:\n")
print(dbGetQuery(con, "
  SELECT
    MIN(anio) FILTER (WHERE valor IS NOT NULL) AS primer_anio_con_valor,
    MAX(anio) FILTER (WHERE valor IS NOT NULL) AS ultimo_anio_con_valor,
    COUNT(*) AS filas
  FROM montilla_indicadores_final_long
  WHERE indicador_id = 'b08';
"))

cat("\nDetalle b08 2004-2008 en vista final:\n")
print(dbGetQuery(con, "
  SELECT anio, valor, valor_texto
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id = 'b08'
    AND anio BETWEEN 2004 AND 2008
  ORDER BY anio;
"))

cat("\nDuplicados b08 por anio:\n")
print(dbGetQuery(con, "
  SELECT anio, COUNT(*) AS n
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id = 'b08'
  GROUP BY anio
  HAVING COUNT(*) > 1
  ORDER BY anio;
"))

cat("\nVerificacion indicadores principales tras recalcular b08:\n")
print(dbGetQuery(con, "
  SELECT 
    indicador_id,
    indicador_nombre,
    COUNT(*) AS filas,
    MIN(anio) AS primer_anio,
    MAX(anio) AS ultimo_anio,
    MIN(anio) FILTER (WHERE valor IS NOT NULL) AS primer_anio_con_valor
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN (
    'b01','b06','b07','b08',
    'b12','b13','b14','b15',
    'saldo_natural','densidad'
  )
  GROUP BY indicador_id, indicador_nombre
  ORDER BY indicador_id;
"))

cat("\nProceso b08 terminado correctamente.\n")