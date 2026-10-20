# ============================================================
# ETL – Tabla final única (long) – Montilla
# Salida: montilla_indicadores_final_long (PostgreSQL)
# Se replica SIMA "Territorio + Población" y se añade histórico desde DB.
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

library(DBI)
library(RPostgres)
library(dplyr)
library(tidyr)
library(stringr)
library(readxl)
library(tibble)
library(readr)

# -------------------------------
# Parámetros fijos de municipio
# -------------------------------
cod_ine <- 14042
municipio_fijo <- "Montilla"

# -------------------------------
# Conexión a PostgreSQL (estándar del proyecto)
# -------------------------------
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


# -------------------------------
# Dimensión de indicadores SIMA (Territorio + Población)
# (IDs como aparecen en la ficha SIMA: a01, b01..b17)
# -------------------------------
dim_indicador_sima <- tibble::tribble(
  ~indicador_id, ~bloque,      ~indicador_nombre,                                       ~unidad,         ~tipo,
  "a01",         "Territorio", "Extensión superficial",                                  "km2",           "num",
  "b01",         "Población",  "Población total",                                        "habitantes",    "num",
  "b02",         "Población",  "Población. Hombres",                                     "habitantes",    "num",
  "b03",         "Población",  "Población. Mujeres",                                     "habitantes",    "num",
  "b04",         "Población",  "Población en núcleos",                                   "habitantes",    "num",
  "b05",         "Población",  "Población en diseminados",                               "habitantes",    "num",
  "b17",         "Población",  "Edad media",                                             "años",          "num",
  "b06",         "Población",  "Porcentaje de población menor de 20 años",               "%",             "num",
  "b07",         "Población",  "Porcentaje de población mayor de 65 años",               "%",             "num",
  "b08",         "Población",  "Variación relativa de la población en diez años",        "%",             "num",
  "b09",         "Población",  "Número de extranjeros",                                  "personas",      "num",
  "b10",         "Población",  "Principal procedencia de los extranjeros residentes",    "texto",         "txt",
  "b11",         "Población",  "Porcentaje que representa respecto total de extranjeros","%",             "num",
  "b12",         "Población",  "Emigraciones",                                           "emigraciones",  "num",
  "b13",         "Población",  "Inmigraciones",                                          "inmigraciones", "num",
  "b14",         "Población",  "Nacimientos",                                            "nacimientos",   "num",
  "b15",         "Población",  "Defunciones",                                            "defunciones",   "num",
  "b16",         "Población",  "Matrimonios",                                            "matrimonios",   "num"
)

# -------------------------------
# Guardado del diccionario de indicadores SIMA en PostgreSQL
# -------------------------------
con <- conectar_pg()

dbWriteTable(con, "dim_indicador_sima", dim_indicador_sima, overwrite = TRUE)
dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_dim_ind_sima_id ON dim_indicador_sima(indicador_id);")
cat("\n m_indicador_sima guardada en PostgreSQL.\n")



# ============================================================
# PARTE 1 — SNAPSHOT SIMA (desde smex99.xls)
# ============================================================

ruta_xls <- file.path("Datos", "Raw", "sima_smex99_latest.xls")
stopifnot(file.exists(ruta_xls))

hojas <- readxl::excel_sheets(ruta_xls)
cat("\n--- Hojas detectadas en smex99.xls ---\n")
print(hojas)

# Lee una hoja detectando la fila de encabezados reales (donde aparece CodMun)
leer_hoja_con_header <- function(sheet_name, max_filas_busqueda = 60) {
  
  raw <- readxl::read_xls(ruta_xls, sheet = sheet_name, col_names = FALSE)
  
  if (nrow(raw) == 0) return(NULL)
  
  n_busq <- min(max_filas_busqueda, nrow(raw))
  sub <- raw[1:n_busq, , drop = FALSE]
  
  # patrón robusto para cod mun
  patron_cod <- "cod\\s*mun|codmun|cod_mun|codigo\\s*mun|c[oó]digo\\s*mun"
  
  # busca fila donde aparece codmun
  sub_txt <- apply(sub, 2, function(x) tolower(as.character(x)))
  fila_header <- which(apply(sub_txt, 1, function(r) any(stringr::str_detect(r, patron_cod), na.rm = TRUE)))[1]
  if (is.na(fila_header)) return(NULL)
  
  header_vals <- as.character(raw[fila_header, ])
  header_vals <- stringr::str_squish(header_vals)
  
  # rellena headers vacíos
  vacios <- which(is.na(header_vals) | header_vals == "")
  if (length(vacios) > 0) header_vals[vacios] <- paste0("V", vacios)
  
  df <- raw[(fila_header + 1):nrow(raw), , drop = FALSE]
  names(df) <- header_vals
  
  # elimina columnas completamente vacías
  df <- df[, colSums(!is.na(df) & as.character(df) != "") > 0, drop = FALSE]
  
  # detecta col_cod
  col_cod <- names(df)[stringr::str_detect(tolower(names(df)), patron_cod)][1]
  if (is.na(col_cod)) return(NULL)
  
  # normaliza código
  cod_num <- suppressWarnings(as.integer(as.character(df[[col_cod]])))
  if (all(is.na(cod_num))) {
    cod_num <- suppressWarnings(as.integer(gsub("\\D", "", as.character(df[[col_cod]]))))
  }
  
  df$.__codmun_detectado__ <- cod_num
  attr(df, "col_cod") <- col_cod
  attr(df, "fila_header") <- fila_header
  df
}

# Busca la hoja correcta: la que contenga cod_ine=14042
df_xls <- NULL
hoja_ok <- NA_character_
col_cod <- NA_character_
fila_header <- NA_integer_

for (h in hojas) {
  tmp <- tryCatch(leer_hoja_con_header(h), error = function(e) NULL)
  if (!is.null(tmp)) {
    if (any(tmp$.__codmun_detectado__ == cod_ine, na.rm = TRUE)) {
      df_xls <- tmp
      hoja_ok <- h
      col_cod <- attr(tmp, "col_cod")
      fila_header <- attr(tmp, "fila_header")
      break
    }
  }
}

stopifnot(!is.null(df_xls))

cat("\n Hoja seleccionada:", hoja_ok, "\n")
cat(" Hoja header detectada:", fila_header, "\n")
cat(" Columna cod municipal detectada:", col_cod, "\n")

cat("\n--- Columnas detectadas (hoja de datos) ---\n")
print(names(df_xls))

# Filtra Montilla
sima_montilla <- df_xls %>%
  filter(.__codmun_detectado__ == cod_ine)

cat("\n--- Filas encontradas para Montilla ---\n")
print(nrow(sima_montilla))

# Detecta columna de nombre de municipio (si existe)
col_muni <- names(sima_montilla)[str_detect(tolower(names(sima_montilla)), "municip")][1]
municipio_xls <- if (!is.na(col_muni)) as.character(sima_montilla[[col_muni]][1]) else municipio_fijo

# Construye snapshot long robusto (sin hardcodear nombres exactos)
# --- Columnas "indicador" = las que contienen un año en el nombre (2019, 2024, 2025, etc.)
cols_indicadores <- names(sima_montilla)[stringr::str_detect(names(sima_montilla), "\\d{4}")]

# Seguridad: si no detecta columnas con año, se corta con mensaje claro
if (length(cols_indicadores) == 0) {
  stop("No se detectaron columnas de indicadores (con año \\d{4}) en sima_montilla. Revisar nombres de columnas del XLS.")
}

snapshot_sima <- sima_montilla %>%
  # Se preservan solo las columnas necesarias para pivotear (indicadores)
  dplyr::select(dplyr::all_of(cols_indicadores)) %>%
  tidyr::pivot_longer(
    cols = dplyr::everything(),
    names_to = "indicador_col",
    values_to = "valor_raw",
    values_transform = list(valor_raw = as.character)  # fuerza tipo y evita errores por mezcla
  ) %>%
  mutate(
    indicador_col = stringr::str_squish(indicador_col),
    anio = suppressWarnings(as.integer(stringr::str_extract(indicador_col, "\\d{4}"))),
    indicador_id = case_when(
      str_detect(indicador_col, "^Extensión superficial") ~ "a01",
      str_detect(indicador_col, "^Población total") ~ "b01",
      str_detect(indicador_col, "^Población\\.?\\s*Hombres") ~ "b02",
      str_detect(indicador_col, "^Población\\.?\\s*Mujeres") ~ "b03",
      str_detect(indicador_col, "^Población en núcleos") ~ "b04",
      str_detect(indicador_col, "^Población en diseminados") ~ "b05",
      str_detect(indicador_col, "^Edad media") ~ "b17",
      str_detect(indicador_col, "^Porcentaje de población menor de 20 años") ~ "b06",
      str_detect(indicador_col, "^Porcentaje de población mayor de 65 años") ~ "b07",
      str_detect(indicador_col, "^Variación relativa de la población en diez años") ~ "b08",
      str_detect(indicador_col, "^Número de extranjeros") ~ "b09",
      str_detect(indicador_col, "^Principal procedencia de los extranjeros residentes") ~ "b10",
      str_detect(indicador_col, "^Porcentaje que representa respecto total de extranjeros") ~ "b11",
      str_detect(indicador_col, "^Emigraciones") ~ "b12",
      str_detect(indicador_col, "^Inmigraciones") ~ "b13",
      str_detect(indicador_col, "^Nacimientos") ~ "b14",
      str_detect(indicador_col, "^Defunciones") ~ "b15",
      str_detect(indicador_col, "^Matrimonios") ~ "b16",
      TRUE ~ NA_character_
    ),
    cod_ine = cod_ine,
    municipio = municipio_xls,
    fuente = "SIMA",
    valor_num = suppressWarnings(as.numeric(gsub(",", ".", valor_raw))),
    valor_texto = ifelse(is.na(valor_num), valor_raw, NA_character_),
    valor = ifelse(!is.na(valor_num), valor_num, NA_real_)
  ) %>%
  filter(!is.na(indicador_id)) %>%
  left_join(dim_indicador_sima, by = "indicador_id") %>%
  select(cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto) %>%
  arrange(indicador_id, anio)

cat("\n--- Snapshot SIMA (preview) ---\n")
print(snapshot_sima)





# ============================================================
# PARTE 2 — HISTÓRICO (desde PostgreSQL) + DERIVADOS
# Incluye b02/b03 históricos (Hombres/Mujeres) desde base edad-sexo
# ============================================================

con <- conectar_pg()

# Población total anual (serie única INE ya creada en el proyecto)
pob_total <- dbGetQuery(con, "
  SELECT anio, poblacion_total
  FROM poblacion_joven_ine_serie
  ORDER BY anio;
") %>%
  as_tibble() %>%
  mutate(
    anio = as.integer(anio),
    poblacion_total = as.numeric(poblacion_total)
  )

# Pirámide comparativa (edad quinquenal por sexo) para %<20 y %>65
piramide <- dbGetQuery(con, "
  SELECT anio, fuente, edad_min, poblacion
  FROM poblacion_edad_sexo_ine_comparativa
") %>%
  as_tibble() %>%
  mutate(
    fuente = str_squish(as.character(fuente)),
    anio = as.integer(anio),
    edad_min = as.integer(edad_min),
    poblacion = as.numeric(poblacion)
  )

# Serie única: Padrón <= 2022, Censo >= 2023
piramide_serie <- piramide %>%
  filter(
    (fuente == "INE_Padron" & anio <= 2022) |
      (fuente == "INE_Censo"  & anio >= 2023)
  )

cat("\n--- CHECK piramide_serie fuentes ---\n")
print(table(piramide_serie$fuente))
cat("\n--- CHECK piramide_serie rango años ---\n")
print(range(piramide_serie$anio, na.rm = TRUE))

# %<20 y %>65 (sumando ambos sexos)
por_edades <- piramide_serie %>%
  group_by(anio) %>%
  summarise(
    total   = sum(poblacion, na.rm = TRUE),
    menor20 = sum(poblacion[edad_min < 20], na.rm = TRUE),
    mayor65 = sum(poblacion[edad_min >= 65], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pct_menor20 = (menor20 / total) * 100,
    pct_mayor65 = (mayor65 / total) * 100
  )

# km2: se intenta tomar de snapshot_sima (a01). Si no está, fallback a la ficha (169.29)
km2 <- snapshot_sima %>% filter(indicador_id == "a01") %>% pull(valor) %>% .[1]
if (is.na(km2) || length(km2) == 0) {
  km2 <- 169.29
  cat("\n Km2 fallback = 169.29 (ficha SIMA) para densidad.\n")
}

# Derivados: densidad y variación 10 años
historico_base <- pob_total %>%
  left_join(por_edades %>% select(anio, pct_menor20, pct_mayor65), by = "anio") %>%
  arrange(anio) %>%
  mutate(
    densidad = poblacion_total / km2,
    var_10_anios = (poblacion_total / dplyr::lag(poblacion_total, 10) - 1) * 100
  )

# ------------------------------------------------------------
# b02/b03 históricos: suma por sexo desde base edad-sexo (serie única)
# ------------------------------------------------------------
piramide_sexo <- dbGetQuery(con, "
  SELECT anio, fuente, sexo, poblacion
  FROM poblacion_edad_sexo_ine_comparativa
") %>%
  as_tibble() %>%
  mutate(
    anio = as.integer(anio),
    fuente = str_squish(as.character(fuente)),
    sexo = str_squish(as.character(sexo)),
    poblacion = as.numeric(poblacion)
  ) %>%
  filter(
    (fuente == "INE_Padron" & anio <= 2022) |
      (fuente == "INE_Censo"  & anio >= 2023)
  ) %>%
  group_by(anio, sexo) %>%
  summarise(poblacion_sexo = sum(poblacion, na.rm = TRUE), .groups = "drop")

hist_b02_b03 <- piramide_sexo %>%
  filter(sexo %in% c("Hombres", "Mujeres")) %>%
  transmute(
    cod_ine,
    municipio = municipio_fijo,
    anio,
    bloque = "Población",
    indicador_id = ifelse(sexo == "Hombres", "b02", "b03"),
    indicador_nombre = ifelse(sexo == "Hombres", "Población. Hombres", "Población. Mujeres"),
    unidad = "habitantes",
    fuente = "INE_serie",
    valor = poblacion_sexo,
    valor_texto = NA_character_
  )

# ------------------------------------------------------------
# Construcción final del histórico (incluye b02/b03)
# ------------------------------------------------------------
historico_indicadores <- bind_rows(
  historico_base %>% transmute(cod_ine, municipio = municipio_fijo, anio, bloque="Población", indicador_id="b01",
                               indicador_nombre="Población total", unidad="habitantes", fuente="INE_serie",
                               valor=poblacion_total, valor_texto=NA_character_),
  hist_b02_b03,
  historico_base %>% transmute(cod_ine, municipio = municipio_fijo, anio, bloque="Población", indicador_id="b06",
                               indicador_nombre="Porcentaje de población menor de 20 años", unidad="%", fuente="INE_serie",
                               valor=pct_menor20, valor_texto=NA_character_),
  historico_base %>% transmute(cod_ine, municipio = municipio_fijo, anio, bloque="Población", indicador_id="b07",
                               indicador_nombre="Porcentaje de población mayor de 65 años", unidad="%", fuente="INE_serie",
                               valor=pct_mayor65, valor_texto=NA_character_),
  historico_base %>% transmute(cod_ine, municipio = municipio_fijo, anio, bloque="Población", indicador_id="b08",
                               indicador_nombre="Variación relativa de la población en diez años", unidad="%", fuente="INE_serie",
                               valor=var_10_anios, valor_texto=NA_character_),
  historico_base %>% transmute(cod_ine, municipio = municipio_fijo, anio, bloque="Territorio", indicador_id="densidad",
                               indicador_nombre="Densidad de población", unidad="hab/km2", fuente="Derivado",
                               valor=densidad, valor_texto=NA_character_)
)

cat("\n--- Histórico (preview) ---\n")
print(tail(historico_indicadores, 12))


# ============================================================
# PARTE 2.5 — DEFUNCIONES (IECA local) + SALDO NATURAL
# ============================================================
# Propósito:
#   Integrar defunciones desde dataset local IECA (Datos/Demograficos/ieca_export.txt)
#   Calcular indicador derivado: saldo_natural = nacimientos - defunciones
#   Ambos se agregan a la tabla final con indicadores b15 y saldo_natural.
#
# Entrada:
#   - Archivo local: Datos/Demograficos/ieca_export.txt (Andalucía por municipio)
#   - Archivo local: Datos/Demograficos/Nacimientos por sexo del recién nacido en Montilla.txt
#
# Salida PostgreSQL:
#   - Tabla: defunciones_montilla (anio INT, defunciones NUMERIC)
#   - Tablas insertadas en montilla_indicadores_final_long:
#       * indicador_id = 'b15', fuente = 'IECA' (Defunciones)
#       * indicador_id = 'saldo_natural', fuente = 'IECA' (Saldo vegetativo)
# ============================================================

# -------------------------------------------------------
# 2.5.1 — LECTURA DEL ARCHIVO IECA LOCAL
# -------------------------------------------------------
# Ruta al archivo exportado con data de todos los municipios de Andalucía
ruta_ieca_export <- file.path("Datos", "Demograficos", "ieca_export.txt")
stopifnot(file.exists(ruta_ieca_export))

# Detectar separador automáticamente (;, tabulación o coma)
# Se cuenta el separador más frecuente en la primera línea
primera_linea <- readLines(ruta_ieca_export, n = 1, warn = FALSE, encoding = "UTF-8")
conteo_sep <- c(
  ";" = stringr::str_count(primera_linea, fixed(";")),
  "\t" = stringr::str_count(primera_linea, fixed("\t")),
  "," = stringr::str_count(primera_linea, fixed(","))
)
sep_detectado <- names(conteo_sep)[which.max(conteo_sep)]

# Lectura del archivo con encoding UTF-8 y decimal_mark configurado
ieca_raw <- readr::read_delim(
  ruta_ieca_export,
  delim = sep_detectado,
  locale = readr::locale(encoding = "UTF-8", decimal_mark = ","),
  show_col_types = FALSE,
  trim_ws = TRUE
)

# -------------------------------------------------------
# 2.5.2 — DETECCIÓN DE COLUMNAS
# -------------------------------------------------------
# Detecta dinámicamente las columnas clave (independiente del nombre exacto)
col_muni <- names(ieca_raw)[str_detect(str_to_lower(names(ieca_raw)), "lugar|municip|resid")][1]
col_anio <- names(ieca_raw)[str_detect(str_to_lower(names(ieca_raw)), "anual|anio|año")][1]
col_medida <- names(ieca_raw)[str_detect(str_to_lower(names(ieca_raw)), "medida|indicador")][1]
col_valor <- names(ieca_raw)[str_detect(str_to_lower(names(ieca_raw)), "valor")][1]

# Validación: detiene el proceso si no se encuentran columnas clave
if (any(is.na(c(col_muni, col_anio, col_medida, col_valor)))) {
  stop("No se pudieron detectar columnas clave en ieca_export.txt (municipio/anio/medida/valor).")
}

# -------------------------------------------------------
# 2.5.3 — EXTRACCIÓN Y LIMPIEZA DE DEFUNCIONES MONTILLA
# -------------------------------------------------------
# Filtrado a:
#   - Municipio = Montilla (búsqueda case-insensitive)
#   - Medida = Defunciones
#   - Años válidos y valores numéricos
defunciones_montilla <- ieca_raw %>%
  transmute(
    municipio = as.character(.data[[col_muni]]),
    anio = suppressWarnings(as.integer(.data[[col_anio]])),
    medida = as.character(.data[[col_medida]]),
    defunciones = suppressWarnings(readr::parse_number(as.character(.data[[col_valor]]), locale = readr::locale(decimal_mark = ",")))
  ) %>%
  filter(
    str_detect(str_to_lower(municipio), "montilla"),
    str_detect(str_to_lower(medida), "defunc")
  ) %>%
  filter(!is.na(anio), !is.na(defunciones)) %>%
  group_by(anio) %>%
  summarise(defunciones = sum(defunciones, na.rm = TRUE), .groups = "drop") %>%
  arrange(anio)

# Persistencia: crea tabla defunciones_montilla en PostgreSQL
# Se usará luego en Shiny como fuente robusta de defunciones
dbWriteTable(con, "defunciones_montilla", defunciones_montilla, overwrite = TRUE)
dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_defunciones_montilla_anio ON defunciones_montilla(anio);")

cat("\n✓ defunciones_montilla cargada: ", nrow(defunciones_montilla), "registros (", 
    min(defunciones_montilla$anio), "-", max(defunciones_montilla$anio), ")\n")

# -------------------------------------------------------
# 2.5.4 — CONVERSIÓN A FORMATO LONG (b15 para tabla final)
# -------------------------------------------------------
# Adapta defunciones_montilla al esquema de montilla_indicadores_final_long
# Agrega constantes cod_ine y municipio_fijo al esquema
defunciones_ieca_long <- defunciones_montilla %>%
  transmute(
    cod_ine = !!cod_ine,
    municipio = !!municipio_fijo,
    anio,
    bloque = "Población",
    indicador_id = "b15",
    indicador_nombre = "Defunciones",
    unidad = "personas",
    fuente = "IECA",
    valor = as.numeric(defunciones),
    valor_texto = NA_character_
  )

# Conversión a formato long para nacimientos locales (b14)
# IMPORTANTE: Estos nacimientos complementan (no reemplazan) los del snapshot SIMA
# Solo se convierte si hay datos; si está vacío, retorna tibble vacío con schema correcto
# -------------------------------------------------------
# 2.5.5 — LECTURA DE NACIMIENTOS LOCAL (para saldo_natural)
# -------------------------------------------------------
ruta_nacimientos_local <- file.path("Datos", "Demograficos", "Nacimientos por sexo del recién nacido en Montilla.txt")

nacimientos_local <- if (file.exists(ruta_nacimientos_local)) {
  # Detectar separador en archivo de nacimientos
  primera_nac <- readLines(ruta_nacimientos_local, n = 1, warn = FALSE, encoding = "UTF-8")
  conteo_nac <- c(
    ";" = stringr::str_count(primera_nac, fixed(";")),
    "\t" = stringr::str_count(primera_nac, fixed("\t")),
    "," = stringr::str_count(primera_nac, fixed(","))
  )
  sep_nac <- names(conteo_nac)[which.max(conteo_nac)]

  nac_raw <- readr::read_delim(
    ruta_nacimientos_local,
    delim = sep_nac,
    locale = readr::locale(encoding = "UTF-8", decimal_mark = ","),
    show_col_types = FALSE,
    trim_ws = TRUE
  )

  # Detectar columnas del archivo de nacimientos
  col_nac_muni <- names(nac_raw)[str_detect(str_to_lower(names(nac_raw)), "lugar|municip|resid")][1]
  col_nac_anio <- names(nac_raw)[str_detect(str_to_lower(names(nac_raw)), "anual|anio|año")][1]
  col_nac_sexo <- names(nac_raw)[str_detect(str_to_lower(names(nac_raw)), "sexo")][1]
  col_nac_medida <- names(nac_raw)[str_detect(str_to_lower(names(nac_raw)), "medida|indicador")][1]
  col_nac_valor <- names(nac_raw)[str_detect(str_to_lower(names(nac_raw)), "valor")][1]

  if (any(is.na(c(col_nac_muni, col_nac_anio, col_nac_medida, col_nac_valor)))) {
    # Si columnas no encontradas, retorna tibble vacío (usa fallback después)
    tibble(anio = integer(), nacimientos = double())
  } else {
    resultado <- nac_raw %>%
      transmute(
        municipio = as.character(.data[[col_nac_muni]]),
        anio = suppressWarnings(as.integer(.data[[col_nac_anio]])),
        sexo = if (!is.na(col_nac_sexo)) as.character(.data[[col_nac_sexo]]) else NA_character_,
        medida = as.character(.data[[col_nac_medida]]),
        nacimientos = suppressWarnings(readr::parse_number(as.character(.data[[col_nac_valor]]), locale = readr::locale(decimal_mark = ",")))
      ) %>%
      filter(
        str_detect(str_to_lower(municipio), "montilla"),
        str_detect(str_to_lower(medida), "nacim")
      ) %>%
      # Solo valores "Ambos sexos" para evitar duplicados
      filter(is.na(sexo) | str_detect(str_to_lower(sexo), "ambos")) %>%
      filter(!is.na(anio), !is.na(nacimientos)) %>%
      group_by(anio) %>%
      summarise(nacimientos = sum(nacimientos, na.rm = TRUE), .groups = "drop") %>%
      arrange(anio)
    resultado
  }
} else {
  # Archivo no existe: retorna tibble vacío
  tibble(anio = integer(), nacimientos = double())
}

# -------------------------------------------------------
# 2.5.5b — CONVERSIÓN A FORMATO LONG (nacimientos b14)
# -------------------------------------------------------
# Convierte nacimientos_local al esquema de montilla_indicadores_final_long
nacimientos_ieca_long <- if (nrow(nacimientos_local) > 0) {
  nacimientos_local %>%
    transmute(
      cod_ine = !!cod_ine,
      municipio = !!municipio_fijo,
      anio,
      bloque = "Población",
      indicador_id = "b14",
      indicador_nombre = "Nacimientos",
      unidad = "personas",
      fuente = "IECA",
      valor = as.numeric(nacimientos),
      valor_texto = NA_character_
    )
} else {
  # Tibble vacío con schema correcto
  tibble(
    cod_ine = integer(),
    municipio = character(),
    anio = integer(),
    bloque = character(),
    indicador_id = character(),
    indicador_nombre = character(),
    unidad = character(),
    fuente = character(),
    valor = double(),
    valor_texto = character()
  )
}

# -------------------------------------------------------
# 2.5.6 — CONSTRUCCIÓN DE SALDO NATURAL (nacimientos - defunciones)
# -------------------------------------------------------
# Usa nacimientos_local si existen filas; si no, recurre a datos de snapshot_sima/histórico
nacimientos_base <- if (nrow(nacimientos_local) > 0) {
  nacimientos_local
} else {
  # Fallback: extrae b14 de los datos ya cargados
  bind_rows(snapshot_sima, historico_indicadores) %>%
    filter(indicador_id == "b14", !is.na(valor)) %>%
    group_by(anio) %>%
    summarise(nacimientos = max(valor, na.rm = TRUE), .groups = "drop")
}

# Calcula saldo: hace inner join entre nacimientos y defunciones
# Solo guarda años donde ambos indicadores existen
saldo_natural_long <- nacimientos_base %>%
  inner_join(defunciones_montilla, by = "anio") %>%
  transmute(
    cod_ine = !!cod_ine,
    municipio = !!municipio_fijo,
    anio,
    bloque = "Población",
    indicador_id = "saldo_natural",
    indicador_nombre = "Saldo vegetativo",
    unidad = "personas",
    fuente = "IECA",
    valor = as.numeric(nacimientos - defunciones),
    valor_texto = NA_character_
  )

cat("\n✓ saldo_natural calculado: ", nrow(saldo_natural_long), "años (", 
    min(saldo_natural_long$anio), "-", max(saldo_natural_long$anio), ")\n")





# ============================================================
# PARTE 3 — TABLA FINAL LONG (snapshot SIMA + histórico)
# ============================================================

tabla_final <- bind_rows(
  snapshot_sima,
  historico_indicadores,
  nacimientos_ieca_long,
  defunciones_ieca_long,
  saldo_natural_long
) %>%
  distinct(cod_ine, anio, indicador_id, fuente, .keep_all = TRUE) %>%
  arrange(indicador_id, anio, fuente)

tabla_final <- tabla_final %>%
  mutate(
    valor_texto = case_when(
      indicador_id == "b08" & fuente == "INE_serie" & is.na(valor) ~ "NA: cálculo requiere t-10 (no disponible)",
      TRUE ~ valor_texto
    )
  )

dbWriteTable(con, "montilla_indicadores_final_long", tabla_final, overwrite = TRUE)
dbExecute(con, "
  CREATE INDEX IF NOT EXISTS idx_montilla_final
  ON montilla_indicadores_final_long (cod_ine, anio, indicador_id, fuente);
")
cat("\n indice idx_montilla_final creado.\n")
cat("\n montilla_indicadores_final_long creada en PostgreSQL.\n")
print(dbGetQuery(con, "
  SELECT *
  FROM montilla_indicadores_final_long
  ORDER BY anio DESC, indicador_id, fuente
  LIMIT 25;
"))

dbDisconnect(con)


