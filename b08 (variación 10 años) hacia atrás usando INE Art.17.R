# ============================================================
# Extender b08 (variación 10 años) hacia atrás usando INE Art.17
# CORRECCIÓN: calcula b08 usando anio-10 (join por año real),
# y opcionalmente interpola años faltantes en 1996–2002.
#
# Requiere:
# - PostgreSQL montilla_db accesible
# - Tabla Art.17 cargada en PostgreSQL (según Excel existe como fuente INE Art.17 1996–2025) [1](https://ugres-my.sharepoint.com/personal/e_tomaspieroni_ms_ugr_es/_layouts/15/Doc.aspx?sourcedoc=%7B738F62B0-2D40-41CE-BB62-E0068DE354FD%7D&file=Fuente%20de%20datos%20Montilla.xlsx&action=default&mobileredirect=true)
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")

library(DBI)
library(RPostgres)
library(dplyr)
library(stringr)
library(tibble)
library(readr)

# -------------------------------
# Conexión
# -------------------------------
con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "montilla_db",
  host     = "localhost",
  port     = 5432,
  user     = "montilla_user",
  password = "montilla_pass"
)
on.exit(dbDisconnect(con), add = TRUE)

cod_ine <- 14042
municipio_fijo <- "Montilla"

# -------------------------------
# 1) Serie base actual (2003–2025)
# -------------------------------
base_2003_2025 <- dbGetQuery(con, "
  SELECT anio, poblacion_total
  FROM poblacion_joven_ine_serie
  ORDER BY anio;
") %>%
  as_tibble() %>%
  mutate(
    anio = as.integer(anio),
    poblacion_total = as.numeric(poblacion_total)
  ) %>%
  filter(anio >= 2003)

stopifnot(nrow(base_2003_2025) > 0)

# -------------------------------
# 2) Detectar tabla Art.17 (robusto)
#    Nota: si querés, hardcodeá el nombre real:
#    tab_art17 <- "poblacion_montilla_sexo"
# -------------------------------
tablas <- dbGetQuery(con, "
  SELECT tablename
  FROM pg_tables
  WHERE schemaname='public'
  ORDER BY tablename;
")$tablename

es_tabla_art17 <- function(tbl) {
  cols <- dbGetQuery(con, paste0(
    "SELECT column_name
     FROM information_schema.columns
     WHERE table_schema='public' AND table_name='", tbl, "';"
  ))$column_name
  cols_low <- tolower(cols)
  
  col_anio <- cols[str_detect(cols_low, "^anio$|año|year")][1]
  col_sexo <- cols[str_detect(cols_low, "^sexo$|sex")][1]
  col_val  <- cols[str_detect(cols_low, "pobl|valor|total|dato")][1]
  
  if (any(str_detect(cols_low, "edad_media"))) return(FALSE)
  if (any(is.na(c(col_anio, col_sexo, col_val)))) return(FALSE)
  
  # Debe tener algo en 1996–2002 para hombres/mujeres
  q2 <- paste0(
    "SELECT COUNT(*) AS n ",
    "FROM ", tbl, " ",
    "WHERE CAST(\"", col_anio, "\" AS INT) BETWEEN 1996 AND 2002 ",
    "  AND LOWER(TRIM(CAST(\"", col_sexo, "\" AS TEXT))) IN ('hombres','mujeres');"
  )
  n <- tryCatch(dbGetQuery(con, q2)$n[1], error = function(e) 0)
  isTRUE(!is.na(n) && n > 0)
}

candidatas <- tablas[vapply(tablas, es_tabla_art17, logical(1))]
if (length(candidatas) == 0) {
  stop(
    "No encontré tabla Art.17 con datos 1996–2002 (anio+sexo+valor).\n",
    "Según el Excel, la fuente INE Art.17 1996–2025 existe, pero debe estar cargada en PostgreSQL para usarla. [1](https://ugres-my.sharepoint.com/personal/e_tomaspieroni_ms_ugr_es/_layouts/15/Doc.aspx?sourcedoc=%7B738F62B0-2D40-41CE-BB62-E0068DE354FD%7D&file=Fuente%20de%20datos%20Montilla.xlsx&action=default&mobileredirect=true)"
  )
}

cat("✅ Candidatas Art.17:\n")
print(candidatas)

tab_art17 <- candidatas[1]
cat("✅ Tabla Art.17 seleccionada:", tab_art17, "\n")

# -------------------------------
# 3) Leer Art.17 y detectar columnas
# -------------------------------
art17_raw <- dbGetQuery(con, paste0("SELECT * FROM ", tab_art17, ";")) %>% as_tibble()

col_anio <- names(art17_raw)[str_detect(tolower(names(art17_raw)), "^anio$|año|year")][1]
col_sexo <- names(art17_raw)[str_detect(tolower(names(art17_raw)), "^sexo$|sex")][1]
col_val  <- names(art17_raw)[str_detect(tolower(names(art17_raw)), "pobl|valor|total|dato")][1]

if (any(is.na(c(col_anio, col_sexo, col_val)))) {
  stop(paste0(
    "No pude detectar columnas anio/sexo/valor en ", tab_art17, ". Columnas: ",
    paste(names(art17_raw), collapse = ", ")
  ))
}

# -------------------------------
# 4) Construir población total Art.17 (1996–2002)
# -------------------------------
art17_1996_2002 <- art17_raw %>%
  transmute(
    anio  = suppressWarnings(as.integer(.data[[col_anio]])),
    sexo  = str_to_lower(str_squish(as.character(.data[[col_sexo]]))),
    valor = readr::parse_number(as.character(.data[[col_val]]),
                                locale = readr::locale(decimal_mark = ","))
  ) %>%
  filter(anio >= 1996 & anio <= 2002) %>%
  filter(sexo %in% c("hombres","mujeres")) %>%
  group_by(anio) %>%
  summarise(poblacion_total = sum(valor, na.rm = TRUE), .groups = "drop") %>%
  arrange(anio)

stopifnot(nrow(art17_1996_2002) > 0)

# -------------------------------
# 5) (Opcional recomendado) Rellenar años faltantes 1996–2002 por interpolación
#     Esto evita que un año faltante (ej. 1997) desplace el cálculo.
#     Si NO querés interpolar, poné interpolar <- FALSE
# -------------------------------
interpolar <- TRUE

if (interpolar) {
  yrs <- 1996:2002
  art17_1996_2002 <- tibble(anio = yrs) %>%
    left_join(art17_1996_2002, by = "anio") %>%
    arrange(anio)
  
  # interpolación lineal simple (solo dentro del rango 1996–2002)
  if (any(is.na(art17_1996_2002$poblacion_total))) {
    art17_1996_2002$poblacion_total <- approx(
      x = art17_1996_2002$anio[!is.na(art17_1996_2002$poblacion_total)],
      y = art17_1996_2002$poblacion_total[!is.na(art17_1996_2002$poblacion_total)],
      xout = art17_1996_2002$anio,
      rule = 2
    )$y
  }
}

cat("\n✅ Art.17 1996–2002 final (con interpolación=", interpolar, "):\n", sep = "")
print(art17_1996_2002)

# -------------------------------
# 6) Serie extendida: (1996–2002) + (2003–2025)
# -------------------------------
serie_ext <- bind_rows(
  art17_1996_2002,
  base_2003_2025
) %>%
  distinct(anio, .keep_all = TRUE) %>%
  arrange(anio)

# -------------------------------
# 7) Recalcular b08 usando anio-10 (NO lag por filas)
# -------------------------------
serie_ext_lag <- serie_ext %>%
  transmute(anio = anio + 10, poblacion_t10 = poblacion_total)

b08_ext <- serie_ext %>%
  left_join(serie_ext_lag, by = "anio") %>%
  mutate(valor = (poblacion_total / poblacion_t10 - 1) * 100) %>%
  transmute(
    cod_ine = cod_ine,
    municipio = municipio_fijo,
    anio,
    bloque = "Población",
    indicador_id = "b08",
    indicador_nombre = "Variación relativa de la población en diez años",
    unidad = "%",
    fuente = "INE_serie",
    valor = as.numeric(valor),
    valor_texto = ifelse(is.na(valor), "NA: cálculo requiere t-10 (no disponible)", NA_character_)
  ) %>%
  arrange(anio)

# -------------------------------
# 8) Actualizar montilla_indicadores_final_long (solo b08 INE_serie)
# -------------------------------
dbExecute(con, "
  DELETE FROM montilla_indicadores_final_long
  WHERE indicador_id='b08' AND fuente='INE_serie';
")

tmp_name <- "tmp_b08_ext"
dbWriteTable(con, tmp_name, b08_ext, overwrite = TRUE)

dbExecute(con, paste0("
  INSERT INTO montilla_indicadores_final_long
  (cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto)
  SELECT cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto
  FROM ", tmp_name, ";
"))

dbExecute(con, paste0("DROP TABLE ", tmp_name, ";"))

cat("\n✅ b08 extendido insertado en montilla_indicadores_final_long.\n")

# -------------------------------
# 9) Verificación rápida
# -------------------------------
print(dbGetQuery(con, "
  SELECT MIN(anio) AS primer_anio_con_valor, MAX(anio) AS ultimo
  FROM montilla_indicadores_final_long
  WHERE indicador_id='b08' AND fuente='INE_serie' AND valor IS NOT NULL;
"))

print(dbGetQuery(con, "
  SELECT anio, valor
  FROM montilla_indicadores_final_long
  WHERE indicador_id='b08' AND fuente='INE_serie'
    AND anio BETWEEN 2004 AND 2008
  ORDER BY anio;
"))