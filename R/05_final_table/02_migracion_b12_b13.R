# ============================================================
# Fix migracion b12/b13 - crear tabla y vista seguras
# No modifica montilla_indicadores_final_long
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
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

# 1) Crear tabla nueva (si no existe)
DBI::dbExecute(con, "
  CREATE TABLE IF NOT EXISTS migracion_rebuild (
    cod_ine          INTEGER,
    municipio        TEXT,
    anio             INTEGER,
    bloque           TEXT,
    indicador_id     TEXT,
    indicador_nombre TEXT,
    unidad           TEXT,
    fuente           TEXT,
    valor            NUMERIC,
    valor_texto      TEXT
  );
")

# 2) Indice unico para evitar duplicados
DBI::dbExecute(con, "
  CREATE UNIQUE INDEX IF NOT EXISTS ux_migracion_rebuild
    ON migracion_rebuild (cod_ine, indicador_id, anio);
")

# 3) Insert seguro desde migracion_ieca_2003_2021
DBI::dbExecute(con, "
  WITH base AS (
    SELECT anio, inmigraciones, emigraciones, fuente
    FROM migracion_ieca_2003_2021
  ),
  long AS (
    SELECT anio, 'b12'::text AS indicador_id, emigraciones  AS valor, fuente FROM base
    UNION ALL
    SELECT anio, 'b13'::text AS indicador_id, inmigraciones AS valor, fuente FROM base
  ),
  meta AS (
    SELECT indicador_id, indicador_nombre, unidad
    FROM dim_indicador_sima
    WHERE indicador_id IN ('b12','b13')
  )
  INSERT INTO migracion_rebuild (
    cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto
  )
  SELECT
    14042 AS cod_ine,
    'Montilla' AS municipio,
    l.anio,
        'Población' AS bloque,
    l.indicador_id,
    COALESCE(m.indicador_nombre,
             CASE WHEN l.indicador_id='b12' THEN 'Emigraciones' ELSE 'Inmigraciones' END),
    COALESCE(m.unidad,
             CASE WHEN l.indicador_id='b12' THEN 'emigraciones' ELSE 'inmigraciones' END),
    COALESCE(l.fuente, 'IECA') AS fuente,
    l.valor,
    NULL::text AS valor_texto
  FROM long l
  LEFT JOIN meta m USING (indicador_id)
  WHERE l.valor IS NOT NULL
  ON CONFLICT (cod_ine, indicador_id, anio) DO NOTHING;
")

# 4) Normalizar etiqueta de bloque (compatibilidad con tabla final)
DBI::dbExecute(con, "
  UPDATE migracion_rebuild
  SET bloque = 'Población'
  WHERE bloque = 'Poblacion';
")

# 5) Crear o reemplazar vista final
DBI::dbExecute(con, "
  CREATE OR REPLACE VIEW montilla_indicadores_migracion_fix AS
  SELECT
    cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto
  FROM montilla_indicadores_final_long
  WHERE indicador_id NOT IN ('b12','b13')
  UNION ALL
  SELECT
    cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto
  FROM migracion_rebuild;
")

# 6) Verificaciones rapidas
cat("\n-- Duplicados en migracion_rebuild (debe ser 0) --\n")
print(DBI::dbGetQuery(con, "
  SELECT indicador_id, anio, COUNT(*) AS n
  FROM migracion_rebuild
  GROUP BY indicador_id, anio
  HAVING COUNT(*) > 1
  ORDER BY indicador_id, anio;
"))

cat("\n-- Conteo por indicador --\n")
print(DBI::dbGetQuery(con, "
  SELECT indicador_id, COUNT(*) AS n
  FROM migracion_rebuild
  GROUP BY indicador_id
  ORDER BY indicador_id;
"))

cat("\n-- Preview vista b12/b13 --\n")
print(DBI::dbGetQuery(con, "
  SELECT *
  FROM montilla_indicadores_migracion_fix
  WHERE indicador_id IN ('b12','b13')
  ORDER BY anio, indicador_id
  LIMIT 10;
"))

cat("\nListo: tabla migracion_rebuild y vista montilla_indicadores_migracion_fix creadas.\n")
