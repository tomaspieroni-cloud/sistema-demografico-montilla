# ============================================================
# Reparar montilla_indicadores_migracion_fix
# El objeto existente puede ser tabla o vista
# Se elimina de forma segura y se recrea como vista
# No modifica montilla_indicadores_final_long ni migracion_rebuild
# ============================================================

suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
})

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "montilla_db",
  host = "localhost",
  port = 5432,
  user = "montilla_user",
  password = "montilla_pass"
)

on.exit(dbDisconnect(con), add = TRUE)

# ------------------------------------------------------------
# 1) Verificar qué tipo de objeto existe actualmente
# ------------------------------------------------------------

cat("\nObjeto actual montilla_indicadores_migracion_fix:\n")

print(dbGetQuery(con, "
  SELECT 
    c.relname AS objeto,
    c.relkind AS tipo
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname = 'montilla_indicadores_migracion_fix';
"))

# ------------------------------------------------------------
# 2) Eliminar el objeto existente de forma segura
# relkind = 'r' tabla
# relkind = 'v' vista
# relkind = 'm' vista materializada
# ------------------------------------------------------------

dbExecute(con, "
DO $$
DECLARE
  objeto_tipo char;
BEGIN
  SELECT c.relkind
  INTO objeto_tipo
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname = 'montilla_indicadores_migracion_fix';

  IF objeto_tipo = 'v' THEN
    EXECUTE 'DROP VIEW public.montilla_indicadores_migracion_fix CASCADE';
  ELSIF objeto_tipo = 'r' THEN
    EXECUTE 'DROP TABLE public.montilla_indicadores_migracion_fix CASCADE';
  ELSIF objeto_tipo = 'm' THEN
    EXECUTE 'DROP MATERIALIZED VIEW public.montilla_indicadores_migracion_fix CASCADE';
  END IF;
END $$;
")

# ------------------------------------------------------------
# 3) Crear la vista corregida
# Usa montilla_indicadores_final_long como base
# Reemplaza b12 y b13 por la tabla migracion_rebuild
# ------------------------------------------------------------

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
  WHERE indicador_id NOT IN ('b12','b13')

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
  FROM migracion_rebuild;
")

# ------------------------------------------------------------
# 4) Verificar que ahora existe como vista
# ------------------------------------------------------------

cat("\nVerificacion del objeto creado:\n")

print(dbGetQuery(con, "
  SELECT 
    table_name,
    table_type
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name = 'montilla_indicadores_migracion_fix';
"))

# ------------------------------------------------------------
# 5) Verificar b12 y b13
# ------------------------------------------------------------

cat("\nVerificacion b12 y b13:\n")

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

# ------------------------------------------------------------
# 6) Verificar indicadores principales
# ------------------------------------------------------------

cat("\nVerificacion indicadores principales:\n")

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
    'densidad'
  )
  GROUP BY indicador_id, indicador_nombre
  ORDER BY indicador_id;
"))

cat("\nProceso terminado correctamente.\n")








# ============================================================
# Inspeccion de archivo Art.17 INE
# No modifica ninguna tabla
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")

suppressPackageStartupMessages({
  library(jsonlite)
  library(dplyr)
})

ruta_art17 <- file.path(
  "Datos",
  "Demograficos",
  "población en aplicación de la Ley de Bases del Régimen Local por sexo.json"
)

print(file.exists(ruta_art17))
print(file.info(ruta_art17)$size)

art17_json <- jsonlite::fromJSON(ruta_art17, flatten = TRUE)

cat("\nTipo de objeto cargado:\n")
print(class(art17_json))

cat("\nNombres principales del objeto:\n")
print(names(art17_json))

cat("\nEstructura resumida:\n")
str(art17_json, max.level = 2)