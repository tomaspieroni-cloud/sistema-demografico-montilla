# ============================================================
# API IECA/SIMA – Descarga automatizada (fichas municipales)
# Se descarga el fichero oficial de datos de fichas:
#   https://www.juntadeandalucia.es/institutodeestadisticaycartografia/sima/datos/smex99.xls
# Se guarda en Datos/Raw con fecha (para trazabilidad) y un "latest".
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")

library(httr)

dir.create(file.path("Datos", "Raw"), showWarnings = FALSE, recursive = TRUE)

url_xls <- "https://www.juntadeandalucia.es/institutodeestadisticaycartografia/sima/datos/smex99.xls"

fecha <- format(Sys.Date(), "%Y%m%d")
out_versionado <- file.path("Datos", "Raw", paste0("sima_smex99_", fecha, ".xls"))
out_latest     <- file.path("Datos", "Raw", "sima_smex99_latest.xls")

cat("\n--- Descargando SIMA smex99.xls ---\n")
r <- RETRY("GET", url_xls, times = 5, pause_base = 1, timeout(120))
stop_for_status(r)

writeBin(content(r, "raw"), out_versionado)
file.copy(out_versionado, out_latest, overwrite = TRUE)

cat("\n descarga OK:\n- ", out_versionado, "\n- ", out_latest, "\n")