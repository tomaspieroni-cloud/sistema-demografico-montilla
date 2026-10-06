# ============================================================
# POBLACIÓN JOVEN (15–29) – Montilla (2003–2022)
# Fuente única: INE (CSV quinquenal)
#
# Jóvenes = 15–19 + 20–24 + 25–29
# Total = fila "Todas las edades" (no se reconstruye sumando quinquenales)
#
# Guarda en PostgreSQL:
#   poblacion_joven_ine_2003_2022
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")
getwd()

library(tidyverse)
library(DBI)
library(RPostgres)

# ------------------------------------------------------------
# Leer CSV
# ------------------------------------------------------------
ruta_csv <- file.path(
  "Datos","Demograficos",
  "Población por sexo, municipios y edad (grupos quinquenales) Montilla 2003 - 2022.csv"
)
stopifnot(file.exists(ruta_csv))

padron_raw <- read_delim(
  ruta_csv,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

cat("\n--- CSV cargado (primeras 10 filas) ---\n")
print(head(padron_raw, 10))
cat("\n--- Columnas ---\n")
print(names(padron_raw))

padron_base <- padron_raw %>%
  transmute(
    grupo_edad  = `Edad (grupos quinquenales)`,
    municipio   = Municipios,
    sexo        = Sexo,
    periodo_txt = Periodo,
    poblacion   = as.numeric(Total)
  ) %>%
  mutate(
    # extrae el AÑO (2022) de "1 de enero de 2022"
    anio = as.integer(stringr::str_extract(as.character(periodo_txt), "\\d{4}"))
  ) %>%
  tidyr::fill(anio, .direction = "down") %>%
  mutate(
    grupo_edad = stringr::str_squish(grupo_edad),
    sexo       = stringr::str_squish(sexo)
  )

cat("\n--- Check anio (primeras 30) ---\n")
print(head(padron_base$anio, 30))

cat("\n--- Rango anio ---\n")
print(range(padron_base$anio, na.rm = TRUE))

# ------------------------------------------------------------
# Quedarnos con sexo Total y extraer edad_min
# ------------------------------------------------------------
padron_total_sexo <- padron_base %>%
  filter(sexo == "Total") %>%
  mutate(
    edad_min = as.numeric(str_extract(grupo_edad, "\\d+"))
  )

cat("\n--- padron_total_sexo (primeras 15 filas) ---\n")
print(head(padron_total_sexo, 15))

cat("\n--- Algunos grupos de edad detectados ---\n")
print(unique(padron_total_sexo$grupo_edad)[1:20])

# ------------------------------------------------------------
# Población joven (15–29): edad_min 15,20,25
# ------------------------------------------------------------
poblacion_joven <- padron_total_sexo %>%
  filter(edad_min %in% c(15, 20, 25)) %>%
  group_by(anio) %>%
  summarise(
    poblacion_joven = sum(poblacion, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(anio)

cat("\n--- poblacion_joven (primeras 10 filas) ---\n")
print(head(poblacion_joven, 10))

# ------------------------------------------------------------
# 5) Población total correcta:
# usar la fila "Todas las edades" (no reconstruir sumando quinquenales)
# ------------------------------------------------------------
poblacion_total <- padron_total_sexo %>%
  filter(str_to_lower(grupo_edad) == "todas las edades") %>%
  select(anio, poblacion_total = poblacion) %>%
  distinct(anio, poblacion_total) %>%
  arrange(anio)

cat("\n--- poblacion_total (primeras 10 filas) ---\n")
print(head(poblacion_total, 10))

cat("\n--- Promedio poblacion_total (debería rondar ~20k) ---\n")
print(mean(poblacion_total$poblacion_total, na.rm = TRUE))

# ------------------------------------------------------------
# Unión final + porcentaje
# ------------------------------------------------------------
poblacion_joven_final <- poblacion_joven %>%
  inner_join(poblacion_total, by = "anio") %>%
  mutate(
    porcentaje_joven = (poblacion_joven / poblacion_total) * 100,
    fuente = "INE"
  ) %>%
  arrange(anio)

cat("\n--- BASE FINAL poblacion_joven_final (primeras 10 filas) ---\n")
print(head(poblacion_joven_final, 10))

cat("\n--- Resumen rápido (checks) ---\n")
print(summary(poblacion_joven_final[, c("poblacion_joven","poblacion_total","porcentaje_joven")]))

# ------------------------------------------------------------
# Guardar en PostgreSQL
# ------------------------------------------------------------
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "montilla_db",
  host = "localhost",
  port = 5432,
  user = "montilla_user",
  password = "montilla_pass"
)

dbWriteTable(
  con,
  "poblacion_joven_ine_2003_2022",
  poblacion_joven_final,
  overwrite = TRUE
)

cat("\n--- Verificación en PostgreSQL (primeras 10) ---\n")
print(dbGetQuery(con, "
  SELECT *
  FROM poblacion_joven_ine_2003_2022
  ORDER BY anio
  LIMIT 10;
"))

dbDisconnect(con)





# ============================================================
# CENSO ANUAL INE (2021–2025) – Población joven (15–29)
# ============================================================

ruta_censo <- file.path(
  "Datos","Demograficos",
  "Censo anual de población 2021-2025 - Población por sexo, edad (grupos quinquenales).csv"
)
stopifnot(file.exists(ruta_censo))

censo_raw <- read_delim(
  ruta_censo,
  delim=";",
  locale = locale(decimal_mark=",", encoding="UTF-8"),
  trim_ws = TRUE
)

cat("\n--- Censo CSV cargado (primeras 10 filas) ---\n")
print(head(censo_raw, 10))
cat("\n--- Columnas Censo ---\n")
print(names(censo_raw))

# Limpieza mínima (idéntica lógica)
censo <- censo_raw %>%
  transmute(
    anio       = as.integer(Periodo),
    sexo       = Sexo,
    grupo_edad = Edad,
    poblacion  = as.numeric(Total)
  ) %>%
  filter(sexo == "Total") %>%
  mutate(
    edad_min = as.numeric(str_extract(grupo_edad, "\\d+"))
  )

cat("\n--- Rango años Censo ---\n")
print(range(censo$anio, na.rm=TRUE))

# Jóvenes 15–29
censo_joven <- censo %>%
  filter(edad_min %in% c(15,20,25)) %>%
  group_by(anio) %>%
  summarise(poblacion_joven = sum(poblacion, na.rm=TRUE), .groups="drop") %>%
  arrange(anio)

# Total anual (usar 'Todas las edades' si existe; si no existe, sumar quinquenales)
censo_total <- censo %>%
  filter(is.na(edad_min)) %>%
  transmute(anio, poblacion_total = poblacion) %>%
  distinct(anio, poblacion_total) %>%
  arrange(anio)

# Si por alguna razón no existiera "Todas las edades", cae en suma:
if (nrow(censo_total) == 0) {
  censo_total <- censo %>%
    filter(!is.na(edad_min)) %>%
    group_by(anio) %>%
    summarise(poblacion_total = sum(poblacion, na.rm=TRUE), .groups="drop") %>%
    arrange(anio)
}

censo_final <- censo_joven %>%
  inner_join(censo_total, by="anio") %>%
  mutate(
    porcentaje_joven = (poblacion_joven / poblacion_total) * 100,
    fuente = "INE_Censo"
  ) %>%
  arrange(anio)

cat("\n--- Censo jóvenes (primeras filas) ---\n")
print(head(censo_final, 10))

# Guardar en PostgreSQL
con <- dbConnect(
  RPostgres::Postgres(),
  dbname="montilla_db", host="localhost", port=5432,
  user="montilla_user", password="montilla_pass"
)

dbWriteTable(con, "poblacion_joven_ine_2021_2025", censo_final, overwrite = TRUE)

cat("\n--- Verificación Postgres (Censo 2021–2025) ---\n")
print(dbGetQuery(con, "
  SELECT * FROM poblacion_joven_ine_2021_2025
  ORDER BY anio;
"))

dbDisconnect(con)



# ============================================================
# UNIÓN 2A (stack): mostrar solape 2021–2022
# Salida DB: poblacion_joven_ine_stack
# ============================================================

con <- dbConnect(
  RPostgres::Postgres(),
  dbname="montilla_db", host="localhost", port=5432,
  user="montilla_user", password="montilla_pass"
)

padron_hist <- dbGetQuery(con, "
  SELECT anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente
  FROM poblacion_joven_ine_2003_2022
")

censo_rec <- dbGetQuery(con, "
  SELECT anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente
  FROM poblacion_joven_ine_2021_2025
")

stack <- bind_rows(padron_hist, censo_rec) %>%
  arrange(anio, fuente)

dbWriteTable(con, "poblacion_joven_ine_stack", stack, overwrite = TRUE)

cat("\n--- CHECK stack (años solapados 2021–2022) ---\n")
print(dbGetQuery(con, "
  SELECT * FROM poblacion_joven_ine_stack
  WHERE anio IN (2021, 2022)
  ORDER BY anio, fuente;
"))

dbDisconnect(con)



# ============================================================
# SERIE ÚNICA: Padrón <= 2022, Censo >= 2023
# Salida DB: poblacion_joven_ine_serie
# ============================================================

con <- dbConnect(
  RPostgres::Postgres(),
  dbname="montilla_db", host="localhost", port=5432,
  user="montilla_user", password="montilla_pass"
)

serie <- bind_rows(
  dbGetQuery(con, "
    SELECT * FROM poblacion_joven_ine_2003_2022 WHERE anio <= 2022
  "),
  dbGetQuery(con, "
    SELECT * FROM poblacion_joven_ine_2021_2025 WHERE anio >= 2023
  ")
) %>% arrange(anio)

dbWriteTable(con, "poblacion_joven_ine_serie", serie, overwrite = TRUE)

cat("\n--- CHECK serie (últimos años) ---\n")
print(dbGetQuery(con, "
  SELECT * FROM poblacion_joven_ine_serie
  ORDER BY anio DESC
  LIMIT 10;
"))


dbGetQuery(con, "SELECT COUNT(*) FROM poblacion_joven_ine_2003_2022;")
dbGetQuery(con, "SELECT COUNT(*) FROM poblacion_joven_ine_2021_2025;")
dbGetQuery(con, "SELECT * FROM poblacion_joven_ine_stack WHERE anio IN (2021, 2022) ORDER BY anio, fuente;")


dbDisconnect(con)




# ============================================================
# PIRÁMIDE – Bloque autocontenido (se ejecuta sin depender del resto del script)
# Se cargan los CSV de Padrón (2003–2022) y Censo (2021–2025),
# se construye población por año–sexo–edad quinquenal y se guarda en PostgreSQL.
# Salidas en PostgreSQL:
#   1) poblacion_edad_sexo_ine_padron_2003_2022
#   2) poblacion_edad_sexo_ine_censo_2021_2025
#   3) poblacion_edad_sexo_ine_comparativa
# ============================================================

# -------------------------------
# Librerías 
# -------------------------------
library(tidyverse)
library(DBI)
library(RPostgres)

# -------------------------------
# Rutas de archivos 
# -------------------------------
ruta_padron_csv <- file.path(
  "Datos","Demograficos",
  "Población por sexo, municipios y edad (grupos quinquenales) Montilla 2003 - 2022.csv"
)

ruta_censo_csv <- file.path(
  "Datos","Demograficos",
  "Censo anual de población 2021-2025 - Población por sexo, edad (grupos quinquenales).csv"
)

stopifnot(file.exists(ruta_padron_csv), file.exists(ruta_censo_csv))

# -------------------------------
# Lectura Padrón 2003–2022 (CSV con Periodo en texto)
# -------------------------------
padron_raw <- readr::read_delim(
  ruta_padron_csv,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE,
  show_col_types = FALSE
)

# Se normaliza el año desde 'Periodo' tipo "1 de enero de 2022" y se rellena hacia abajo
padron_base <- padron_raw %>%
  transmute(
    grupo_edad  = `Edad (grupos quinquenales)`,
    sexo        = Sexo,
    periodo_txt = Periodo,
    poblacion   = as.numeric(Total)
  ) %>%
  mutate(
    anio = as.integer(stringr::str_extract(as.character(periodo_txt), "\\d{4}"))
  ) %>%
  tidyr::fill(anio, .direction = "down") %>%
  mutate(
    grupo_edad = stringr::str_squish(grupo_edad),
    sexo       = stringr::str_squish(sexo)
  )

cat("\n--- PIRÁMIDE Padrón: rango de años detectado ---\n")
print(range(padron_base$anio, na.rm = TRUE))

# Se construye población por edad quinquenal y sexo (Hombres/Mujeres)
padron_edad_sexo <- padron_base %>%
  filter(sexo %in% c("Hombres", "Mujeres")) %>%
  filter(str_to_lower(grupo_edad) != "todas las edades") %>%
  mutate(
    edad_min = as.integer(str_extract(grupo_edad, "\\d+")),
    fuente = "INE_Padron"
  ) %>%
  transmute(
    anio, sexo, grupo_edad, edad_min, poblacion, fuente
  ) %>%
  arrange(anio, sexo, edad_min)

cat("\n--- PIRÁMIDE Padrón: preview ---\n")
print(head(padron_edad_sexo, 12))

# -------------------------------
# Lectura Censo 2021–2025 (CSV con columnas Periodo/Edad/Sexo/Total)
# -------------------------------
censo_raw <- readr::read_delim(
  ruta_censo_csv,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE,
  show_col_types = FALSE
)

censo_edad_sexo <- censo_raw %>%
  transmute(
    anio       = as.integer(Periodo),
    sexo       = stringr::str_squish(Sexo),
    grupo_edad = stringr::str_squish(Edad),
    poblacion  = as.numeric(Total)
  ) %>%
  filter(sexo %in% c("Hombres", "Mujeres")) %>%
  filter(!str_detect(str_to_lower(grupo_edad), "todas")) %>%
  mutate(
    edad_min = as.integer(str_extract(grupo_edad, "\\d+")),
    fuente = "INE_Censo"
  ) %>%
  transmute(
    anio, sexo, grupo_edad, edad_min, poblacion, fuente
  ) %>%
  arrange(anio, sexo, edad_min)

cat("\n--- PIRÁMIDE Censo: rango de años detectado ---\n")
print(range(censo_edad_sexo$anio, na.rm = TRUE))

cat("\n--- PIRÁMIDE Censo: preview ---\n")
print(head(censo_edad_sexo, 12))

# -------------------------------
# Tabla comparativa con solape (2021–2022)
# -------------------------------
edad_sexo_comparativa <- bind_rows(padron_edad_sexo, censo_edad_sexo) %>%
  arrange(anio, fuente, sexo, edad_min)

cat("\n--- CHECK solape 2021 (pirámide) ---\n")
print(edad_sexo_comparativa %>%
        filter(anio == 2021) %>%
        distinct(fuente) %>%
        arrange(fuente))

cat("\n--- CHECK solape 2022 (pirámide) ---\n")
print(edad_sexo_comparativa %>%
        filter(anio == 2022) %>%
        distinct(fuente) %>%
        arrange(fuente))

# -------------------------------
# Guardado en PostgreSQL
# -------------------------------
con <- dbConnect(
  RPostgres::Postgres(),
  dbname="montilla_db",
  host="localhost",
  port=5432,
  user="montilla_user",
  password="montilla_pass"
)

dbWriteTable(con, "poblacion_edad_sexo_ine_padron_2003_2022", padron_edad_sexo, overwrite = TRUE)
dbWriteTable(con, "poblacion_edad_sexo_ine_censo_2021_2025", censo_edad_sexo, overwrite = TRUE)
dbWriteTable(con, "poblacion_edad_sexo_ine_comparativa", edad_sexo_comparativa, overwrite = TRUE)

cat("\n--- Verificación Postgres (pirámide comparativa: muestra) ---\n")
print(dbGetQuery(con, "
  SELECT anio, fuente, sexo, grupo_edad, poblacion
  FROM poblacion_edad_sexo_ine_comparativa
  ORDER BY anio DESC, fuente, sexo, grupo_edad
  LIMIT 12;
"))

dbDisconnect(con)

cat("\n PIRÁMIDE: tablas creadas en PostgreSQL.\n")