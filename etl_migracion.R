# ============================================================
# ETL MIGRACIÓN – Montilla
# 1) IECA 2003–2021: Inmigraciones, Emigraciones, Saldo
# 2) IECA 2003–2021: Inmigraciones por sexo
# 3) INE 2021–2024: CSV (solo inspección por ahora)
# Salidas en PostgreSQL:
#   - migracion_ieca_2003_2021
#   - inmigracion_sexo_ieca_2003_2021
# ============================================================

# -------------------------------
# Función de conexión a PostgreSQL
# -------------------------------
conectar_pg <- function() {
  DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = "montilla_db",
    host = "localhost",
    port = 5432,
    user = "montilla_user",
    password = "montilla_pass"
  )
}

# -------------------------------
# Directorio del proyecto
# -------------------------------
setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")
getwd()


library(tidyverse)
library(DBI)
library(RPostgres)

# ============================================================
# PARTE A – IECA: Saldo migratorio (incluye inmi/emi/saldo)
# Archivo: "Saldo MIgratorio Montilla 2003-2021 total personas.txt"
# ============================================================

# RUTA
ruta_saldo <- file.path(
  "Datos","Migracion",
  "Saldo MIgratorio Montilla 2003-2021 total personas.txt"
)
stopifnot(file.exists(ruta_saldo))

# LECTURA (TXT separado por ;)
saldo_raw <- read_delim(
  ruta_saldo,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

# LIMPIEZA a formato "largo"
saldo_long <- saldo_raw %>%
  select(
    anio   = Anual,
    medida = Medida,
    valor  = Valor
  ) %>%
  mutate(
    anio = as.integer(anio),
    valor = as.numeric(valor)
  )

# PASAR a formato "ancho" (una fila por año)
migr_ieca <- saldo_long %>%
  mutate(medida = case_when(
    medida == "Inmigraciones"    ~ "inmigraciones",
    medida == "Emigraciones"     ~ "emigraciones",
    medida == "Saldo migratorio" ~ "saldo_migratorio",
    TRUE ~ medida
  )) %>%
  pivot_wider(names_from = medida, values_from = valor) %>%
  mutate(fuente = "IECA") %>%
  arrange(anio)

print(head(migr_ieca, 10))

# ============================================================
# PARTE B – IECA: Inmigraciones por sexo
# Archivo: "Inmigraciones por sexo en Montilla.txt"
# ============================================================

ruta_inmi <- file.path("Datos","Migracion","Inmigraciones por sexo en Montilla.txt")
stopifnot(file.exists(ruta_inmi))

inmi_raw <- read_delim(
  ruta_inmi,
  delim=";",
  locale=locale(decimal_mark=",", encoding="UTF-8"),
  trim_ws=TRUE
)

inmi <- inmi_raw %>%
  select(
    anio = Anual,
    sexo = Sexo,
    inmigraciones = Valor
  ) %>%
  mutate(
    anio = as.integer(anio),
    inmigraciones = as.numeric(inmigraciones),
    sexo = ifelse(sexo == "Ambos sexos", "Total", sexo),
    fuente = "IECA"
  ) %>%
  arrange(anio, sexo)

print(head(inmi, 12))

# ============================================================
# PARTE C – Guardado en PostgreSQL
# ============================================================

# FUNCIÓN de conexión
conectar_pg <- function() {
  dbConnect(
    RPostgres::Postgres(),
    dbname="montilla_db",
    host="localhost",
    port=5432,
    user="montilla_user",
    password="montilla_pass"
  )
}

# Intentar conectar y guardar
con <- tryCatch(
  conectar_pg(),
  error = function(e) {
    message("\n ErrOR conectando a PostgreSQL.\n",
            "Causa típica: Docker/PostgreSQL no están corriendo.\n",
            "Solución rápida:\n",
            "  1) Abrí Docker Desktop\n",
            "  2) En Ubuntu: cd .../docker && docker compose up -d\n",
            "  3) Reintentar el script\n\n",
            "Detalle del error: ", e$message)
    return(NULL)
  }
)

if (!is.null(con)) {
  
  # Guardar tablas
  dbWriteTable(con, "migracion_ieca_2003_2021", migr_ieca, overwrite = TRUE)
  dbWriteTable(con, "inmigracion_sexo_ieca_2003_2021", inmi, overwrite = TRUE)
  
  # Verificación rápida
  print(dbGetQuery(con, "SELECT * FROM migracion_ieca_2003_2021 ORDER BY anio DESC LIMIT 5;"))
  print(dbGetQuery(con, "SELECT * FROM inmigracion_sexo_ieca_2003_2021 ORDER BY anio DESC, sexo LIMIT 6;"))
  
  dbDisconnect(con)
  message("\n IECA migración cargado en PostgreSQL.\n")
}




# ============================================================
# PARTE D – INE: saldo 2021–2024 (desde archivo descargado por API)
# Se utiliza el CSV generado por api_ine_descargas.R:
#   Datos/Raw/ine_69767_montilla_saldo_total.csv
# El archivo ya viene filtrado a:
#   - Montilla
#   - Ambos sexos
#   - Saldo total
#   - Dato base
# Se normaliza a la estructura estándar del proyecto:
#   anio, saldo_migratorio, fuente
# Se guarda en PostgreSQL: saldo_migratorio_ine_2021_2024
# ============================================================

ruta_api_saldo <- file.path("Datos", "Raw", "ine_69767_montilla_saldo_total.csv")
stopifnot(file.exists(ruta_api_saldo))

ine_api_raw <- read.csv(ruta_api_saldo, fileEncoding = "UTF-8", stringsAsFactors = FALSE)

cat("\n--- INE API (raw): primeras filas ---\n")
print(head(ine_api_raw, 10))
cat("\n--- INE API (raw): columnas ---\n")
print(names(ine_api_raw))

# Se construye la tabla estándar para el proyecto
ine_saldo_total <- ine_api_raw %>%
  transmute(
    anio = as.integer(Anyo),
    saldo_migratorio = as.numeric(Valor),
    fuente = "INE"
  ) %>%
  arrange(anio)

cat("\n--- INE saldo total (normalizado): preview ---\n")
print(ine_saldo_total)

# Se guarda en PostgreSQL
con <- conectar_pg()
dbWriteTable(con, "saldo_migratorio_ine_2021_2024", ine_saldo_total, overwrite = TRUE)

cat("\n--- Verificación Postgres (saldo_migratorio_ine_2021_2024) ---\n")
print(dbGetQuery(con, "SELECT * FROM saldo_migratorio_ine_2021_2024 ORDER BY anio;"))

dbDisconnect(con)

cat("\n INE saldo 2021–2024 cargado desde API.\n")




# ============================================================
# PARTE E - Tabla comparativa de saldo migratorio (IECA + INE) con solape 2021
# Se construye una serie que conserva ambas fuentes en el año solapado
# para permitir comparación metodológica.
# Salida en PostgreSQL:
#   - saldo_migratorio_comparativa
# ============================================================

# Se construye el saldo IECA (una fila por año)
ieca_saldo <- migr_ieca %>%
  select(anio, saldo_migratorio) %>%
  mutate(fuente = "IECA") %>%
  arrange(anio)

# El saldo INE ya está en ine_saldo_total (una fila por año)
# Se asegura orden
ine_saldo <- ine_saldo_total %>%
  select(anio, saldo_migratorio, fuente) %>%
  arrange(anio)

# Serie comparativa con solape (2021 aparece dos veces)
saldo_comparativa <- bind_rows(ieca_saldo, ine_saldo) %>%
  arrange(anio, fuente)

cat("\n--- CHECK saldo comparativa (solape 2021) ---\n")
print(saldo_comparativa %>% filter(anio == 2021) %>% arrange(fuente))

# Guardado en PostgreSQL
con <- conectar_pg()

dbWriteTable(
  con,
  "saldo_migratorio_comparativa",
  saldo_comparativa,
  overwrite = TRUE
)

cat("\n--- Verificación Postgres (saldo_migratorio_comparativa, últimos 10) ---\n")
print(dbGetQuery(con, "
  SELECT *
  FROM saldo_migratorio_comparativa
  ORDER BY anio DESC, fuente
  LIMIT 10;
"))

dbDisconnect(con)


#Nota: El INE dejó de publicar la Estadística de Variaciones Residenciales (EVR) 
#y la sustituyó por la Estadística de Migraciones y Cambios de Residencia (EMCR) 
#desde 2021, precisamente por un cambio de paradigma ligado a los censos basados 
#en registros. Además, el INE indica explícitamente que 2021 es común a ambas 
#series y que existen diferencias entre ellas.
#La nueva metodología se basa en un cambio de paradigma: censos anuales basados 
#en registros administrativos, combinados con la historia padronal para reconstruir 
#trayectorias migratorias 


# ============================================================
# PARTE F – Tasa de saldo migratorio por 1.000 habitantes
# Se calcula la tasa usando como denominador la población total INE
# (tabla de jóvenes ya calculada en el proyecto).
# Se guarda en PostgreSQL:
#   - tasa_saldo_migratorio_comparativa
# ============================================================

con <- conectar_pg()

# Se lee la serie comparativa de saldo (IECA+INE con solape 2021)
saldo_comp <- dbGetQuery(con, "
  SELECT anio, saldo_migratorio, fuente
  FROM saldo_migratorio_comparativa
")

# Se lee la población total anual desde la serie INE consolidada de jóvenes
# (si existe 'poblacion_joven_ine_serie', se usa por consistencia temporal)
pob_total <- dbGetQuery(con, "
  SELECT anio, poblacion_total
  FROM poblacion_joven_ine_serie
")

# Se calcula la tasa por 1.000
tasa_comp <- saldo_comp %>%
  inner_join(pob_total, by = "anio") %>%
  mutate(
    tasa_saldo_1000 = (saldo_migratorio / poblacion_total) * 1000
  ) %>%
  arrange(anio, fuente)

cat("\n--- CHECK tasa_saldo_1000 (últimos 10) ---\n")
print(tail(tasa_comp, 10))

cat("\n--- CHECK solape 2021 (tasa) ---\n")
print(tasa_comp %>% filter(anio == 2021) %>% arrange(fuente))

# Se guarda en PostgreSQL
dbWriteTable(con, "tasa_saldo_migratorio_comparativa", tasa_comp, overwrite = TRUE)

cat("\n--- Verificación Postgres (tasa_saldo_migratorio_comparativa, últimos 10) ---\n")
print(dbGetQuery(con, "
  SELECT *
  FROM tasa_saldo_migratorio_comparativa
  ORDER BY anio DESC, fuente
  LIMIT 10;
"))

dbDisconnect(con)

cat("\n tasa_saldo_migratorio_comparativa creada.\n")



# ============================================================
# PARTE G – Indicadores de atracción (jóvenes + migración) en una sola tabla
# Se construye una tabla final unificada para visualización.
# Se conserva el solape por fuente para evitar empalmes artificiales.
# Salida en PostgreSQL:
#   - atraccion_indicadores_comparativa
# ============================================================

con <- conectar_pg()

# Se lee la tasa de saldo migratorio (ya calculada)
tasa <- dbGetQuery(con, "
  SELECT anio, fuente, saldo_migratorio, poblacion_total, tasa_saldo_1000
  FROM tasa_saldo_migratorio_comparativa
")

# Se lee el porcentaje de jóvenes desde la serie única INE (más estable para % jóvenes)
# Si se prefiere la tabla comparativa (padrón vs censo), se puede cambiar por esa.
joven <- dbGetQuery(con, "
  SELECT anio, porcentaje_joven
  FROM poblacion_joven_ine_serie
")

# Se une por año (la fuente se conserva desde 'tasa')
atraccion <- tasa %>%
  left_join(joven, by = "anio") %>%
  arrange(anio, fuente)

cat('\n--- CHECK atraccion (últimos 12) ---\n')
print(tail(atraccion, 12))

cat('\n--- CHECK solape 2021 (atracción) ---\n')
print(atraccion %>% dplyr::filter(anio == 2021) %>% arrange(fuente))

dbWriteTable(con, "atraccion_indicadores_comparativa", atraccion, overwrite = TRUE)

cat('\n--- Verificación Postgres (atraccion_indicadores_comparativa, últimos 10) ---\n')
print(dbGetQuery(con, "
  SELECT *
  FROM atraccion_indicadores_comparativa
  ORDER BY anio DESC, fuente
  LIMIT 10;
"))

dbDisconnect(con)

cat('\n atraccion_indicadores_comparativa creada.\n')
``