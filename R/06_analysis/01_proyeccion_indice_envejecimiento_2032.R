# ============================================================
# Predicción (hasta 2032) – Índice de envejecimiento (Montilla)
# Guarda resultados en PostgreSQL: indice_envejecimiento_forecast_2032
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

library(DBI)
library(RPostgres)
library(dplyr)
library(tibble)
library(forecast)

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

con <- conectar_pg()
on.exit(DBI::dbDisconnect(con), add = TRUE)

# -------------------------------
# Cargar series
# -------------------------------
ieca <- DBI::dbGetQuery(con, "
  SELECT anio, indice_envejecimiento AS valor
  FROM indice_envejecimiento_ieca
  WHERE indice_envejecimiento IS NOT NULL
  ORDER BY anio;
") %>% as_tibble() %>% mutate(fuente = "IECA")

ine <- DBI::dbGetQuery(con, "
  SELECT anio, indice_envejecimiento AS valor
  FROM indice_envejecimiento_ine
  WHERE indice_envejecimiento IS NOT NULL
  ORDER BY anio;
") %>% as_tibble() %>% mutate(fuente = "INE")

# -------------------------------
# Elegir serie única para modelar
# -------------------------------
score_serie <- function(df) {
  yrs <- sort(unique(df$anio))
  if (length(yrs) < 5) return(list(score = -Inf, n = length(yrs), gaps = Inf))
  gaps <- sum(diff(yrs) != 1)
  list(score = length(yrs) - 2 * gaps, n = length(yrs), gaps = gaps)
}

s_ieca <- score_serie(ieca)
s_ine  <- score_serie(ine)

if (s_ieca$score > s_ine$score) {
  modelo_df <- ieca
  contraste_df <- ine
  fuente_modelo <- "IECA"
} else {
  modelo_df <- ine
  contraste_df <- ieca
  fuente_modelo <- "INE"
}

cat("\n Fuente elegida para modelar:", fuente_modelo,
    "| n=", ifelse(fuente_modelo == "INE", s_ine$n, s_ieca$n),
    "| gaps=", ifelse(fuente_modelo == "INE", s_ine$gaps, s_ieca$gaps), "\n")

# -------------------------------
# Construir serie anual completa
# -------------------------------
yrs_full <- seq(min(modelo_df$anio), max(modelo_df$anio), by = 1)

serie_full <- tibble(anio = yrs_full) %>%
  left_join(modelo_df %>% select(anio, valor), by = "anio") %>%
  arrange(anio)

if (any(is.na(serie_full$valor))) {
  cat("\n hay años faltantes en la serie de modelado. Se interpola linealmente.\n")
  serie_full$valor <- forecast::na.interp(serie_full$valor)
}

ts_y <- ts(serie_full$valor, start = min(serie_full$anio), frequency = 1)

# -------------------------------
# 4) Modelo ARIMA + forecast hasta 2032
# -------------------------------
fit <- forecast::auto.arima(ts_y)

anio_fin <- 2032
h <- anio_fin - max(serie_full$anio)
if (h <= 0) stop("anio_fin debe ser mayor al último año observado en la serie de modelado.")

fc <- forecast::forecast(fit, h = h, level = c(80, 95))

# -------------------------------
# Preparar salida (observado + predicho)
# -------------------------------
obs_out <- tibble(
  anio = serie_full$anio,
  fuente_modelo = fuente_modelo,
  metodo = "auto.arima",
  tipo = "observado",
  valor = as.numeric(ts_y),
  lo80 = NA_real_, hi80 = NA_real_,
  lo95 = NA_real_, hi95 = NA_real_
)

pred_years <- (max(serie_full$anio) + 1):(max(serie_full$anio) + h)

pred_out <- tibble(
  anio = pred_years,
  fuente_modelo = fuente_modelo,
  metodo = "auto.arima",
  tipo = "predicho",
  valor = as.numeric(fc$mean),
  lo80 = as.numeric(fc$lower[, "80%"]),
  hi80 = as.numeric(fc$upper[, "80%"]),
  lo95 = as.numeric(fc$lower[, "95%"]),
  hi95 = as.numeric(fc$upper[, "95%"])
)

out <- bind_rows(obs_out, pred_out)

# -------------------------------
# Guardar en PostgreSQL
# -------------------------------
DBI::dbWriteTable(con, "indice_envejecimiento_forecast_2032", out, overwrite = TRUE)

DBI::dbExecute(con, "
  CREATE INDEX IF NOT EXISTS idx_ie_forecast_2032
  ON indice_envejecimiento_forecast_2032 (anio, tipo, fuente_modelo);
")

cat("\n tabla creada: indice_envejecimiento_forecast_2032\n")

# -------------------------------
# Mostrar predicción (últimos años) en consola
# -------------------------------
print(
  DBI::dbGetQuery(con, "
    SELECT *
    FROM indice_envejecimiento_forecast_2032
    WHERE tipo='predicho'
    ORDER BY anio;
  ")
)