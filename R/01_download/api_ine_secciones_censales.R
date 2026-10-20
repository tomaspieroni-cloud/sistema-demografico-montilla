# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

library(httr)
library(sf)

dir.create(file.path("Datos","Geo"), showWarnings = FALSE, recursive = TRUE)

anio_secciones <- 2025   # recomiendo 2025 (estable). También existe 2024/2026. [2](https://ine.es/geoserver/ogc/features/v1/collections/WMS_INE_SECCIONES_G01:Secciones_2025)[3](https://ine.es/geoserver/ogc/features/v1/collections/WMS_INE_SECCIONES_G01:Secciones_2024)
cpro <- "14"             # Córdoba
cmun <- "042"            # Montilla dentro de provincia 14 → 14042
layer <- paste0("WMS_INE_SECCIONES_G01:Secciones_", anio_secciones)

# Endpoint WFS correcto del INE para secciones censales (workspace WMS_INE_SECCIONES_G01) [1](https://inspire-geoportal.ec.europa.eu/srv/api/records/spaINE_SeccionesCensales)[2](https://ine.es/geoserver/ogc/features/v1/collections/WMS_INE_SECCIONES_G01:Secciones_2025)
wfs <- "https://www.ine.es/geoserver/WMS_INE_SECCIONES_G01/wfs"

# Queryables incluyen CPRO y CMUN (y otros) en la colección Secciones_YYYY [4](https://ine.es/geoserver/ogc/features/v1/collections/WMS_INE_SECCIONES_G01:Secciones_2025/queryables?f=text%2Fhtml)
cql <- paste0("CPRO='", cpro, "' AND CMUN='", cmun, "'")

url_wfs <- paste0(
  wfs,
  "?service=WFS&version=2.0.0&request=GetFeature",
  "&typeNames=", URLencode(layer, reserved = TRUE),
  "&outputFormat=application/json",
  "&CQL_FILTER=", URLencode(cql, reserved = TRUE)
)

out_geojson <- file.path("Datos","Geo", paste0("secciones_montilla_", anio_secciones, ".geojson"))

cat("Descargando...\n", url_wfs, "\n")
r <- GET(url_wfs)
stop_for_status(r)
writeBin(content(r, "raw"), out_geojson)

cat(" Guardado:", out_geojson, "\n")

g <- st_read(out_geojson, quiet = TRUE)
cat("Nº secciones:", nrow(g), "\n")
cat("Columnas:\n")
print(names(g))