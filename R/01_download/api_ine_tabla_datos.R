# ============================================================
# API INE – Tabla 69767 – Descarga + filtrado por Nombre
# La tabla Tempus3 devuelve series con columnas:
#   COD, Nombre, FK_Unidad, FK_Escala, Data
# El filtro se hace sobre Nombre (no hay MetaData en este endpoint).
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")

library(httr)
library(jsonlite)
library(dplyr)
library(stringr)
library(tidyr)

dir.create(file.path("Datos", "Raw"), showWarnings = FALSE, recursive = TRUE)

id_tabla <- "69767"

# ============================================================
# PARTE 1 – Descargar JSON completo
# ============================================================

url_json <- paste0("https://servicios.ine.es/wstempus/js/ES/DATOS_TABLA/", id_tabla)

cat("\n--- Descargando tabla", id_tabla, "---\n")
r_datos <- RETRY("GET", url_json, times = 5, pause_base = 1, timeout(120))
stop_for_status(r_datos)

datos_raw <- fromJSON(
  content(r_datos, "text", encoding = "UTF-8"),
  flatten = TRUE
)

cat("Registros totales:", nrow(datos_raw), "\n")
cat("Columnas:", paste(names(datos_raw), collapse = ", "), "\n")


# ============================================================
# PARTE 2 – Filtrar la serie de interés por Nombre
#
# Criterios:
#   - Municipio exacto: "Montilla"
#   - Sexo: "Ambos sexos"
#   - Tipo de saldo: "Saldo total"
#   - Tipo de dato: "Dato base"
# ============================================================

fila_objetivo <- datos_raw %>%
  filter(
    str_detect(Nombre, regex("^Montilla\\.\\s*Ambos sexos\\.\\s*Saldo total", ignore_case = TRUE))
  )

cat("\n--- Series coincidentes ---\n")
print(fila_objetivo[, c("COD", "Nombre", "FK_Unidad")])

stopifnot("No se encontró la serie Montilla/Ambos sexos/Saldo total" = nrow(fila_objetivo) >= 1)

# Si hay más de una fila (p.ej. "Dato base" y "Variación"), quedarse con "Dato base"
if (nrow(fila_objetivo) > 1) {
  fila_objetivo <- fila_objetivo %>%
    filter(str_detect(Nombre, regex("Dato base", ignore_case = TRUE)))
}

cat("\nSerie seleccionada:", fila_objetivo$COD[1], "-", fila_objetivo$Nombre[1], "\n")


# ============================================================
# PARTE 3 – Aplanar la columna Data (lista de observaciones)
#
# Cada elemento de Data es un data.frame con columnas:
#   Fecha, FK_TipoDato, T3_TipoDato, Valor, Secreto, T3_Periodo, Anyo, FK_Periodo
# ============================================================

obs <- fila_objetivo$Data[[1]]

cat("\n--- Estructura de las observaciones ---\n")
str(obs)

cat("\n--- Primeras observaciones ---\n")
print(head(obs, 10))


# ============================================================
# PARTE 4 – Construir tabla final y guardar CSV
# ============================================================

tabla_final <- obs %>%
  mutate(
    COD    = fila_objetivo$COD[1],
    Nombre = fila_objetivo$Nombre[1],
    Unidad = fila_objetivo$FK_Unidad[1],
    Fecha  = as.POSIXct(Fecha / 1000, origin = "1970-01-01", tz = "UTC")
  ) %>%
  select(COD, Nombre, Anyo, FK_Periodo, Fecha, Valor, Secreto, Unidad) %>%
  arrange(Anyo)

cat("\n--- Tabla final (preview) ---\n")
print(tabla_final)
cat("Total filas:", nrow(tabla_final), "\n")

out <- file.path("Datos", "Raw", "ine_69767_montilla_saldo_total.csv")
write.csv(tabla_final, out, row.names = FALSE, fileEncoding = "UTF-8")

cat("\n✓ CSV guardado en:", out, "\n")