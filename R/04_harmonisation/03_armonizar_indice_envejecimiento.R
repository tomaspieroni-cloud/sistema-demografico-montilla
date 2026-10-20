# ============================================================
# Armonización – Índice de envejecimiento (Montilla)
# continuidad IECA -> INE usando años solapados
# Regla final:
#   - IECA <= 2022
#   - INE ajustado >= 2023
# Salida DB: indice_envejecimiento_montilla_harmonizado
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))
library(DBI)
library(RPostgres)
library(dplyr)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "montilla_db"), host = Sys.getenv("DB_HOST", "localhost"), port = as.integer(Sys.getenv("DB_PORT", "5432")),
  user = Sys.getenv("DB_USER", "montilla_user"), password = Sys.getenv("DB_PASS")
)

# Traer ambas series
ieca <- dbGetQuery(con, "
  SELECT anio, indice_envejecimiento
  FROM indice_envejecimiento_ieca
")

ine <- dbGetQuery(con, "
  SELECT anio, indice_envejecimiento
  FROM indice_envejecimiento_ine
")

# Calcular desfase en años solapados (2021-2022)
solape <- ieca %>%
  inner_join(ine, by="anio", suffix=c("_ieca","_ine")) %>%
  filter(anio %in% c(2021, 2022))

print(solape)

offset <- mean(solape$indice_envejecimiento_ieca - solape$indice_envejecimiento_ine, na.rm = TRUE)
cat("\nOFFSET (IECA - INE) promedio 2021-2022 =", offset, "\n")

# Ajustar INE (solo desde 2023)
ine_ajustado <- ine %>%
  filter(anio >= 2023) %>%
  mutate(
    indice_envejecimiento = indice_envejecimiento + offset,
    fuente = "INE_ajustado"
  ) %>%
  select(anio, indice_envejecimiento, fuente)

# IECA final (hasta 2022)
ieca_final <- ieca %>%
  filter(anio <= 2022) %>%
  mutate(fuente = "IECA") %>%
  select(anio, indice_envejecimiento, fuente)

# Serie final armonizada
final <- bind_rows(ieca_final, ine_ajustado) %>%
  arrange(anio)

print(final)

# Guardar en PostgreSQL
dbWriteTable(con, "indice_envejecimiento_montilla_harmonizado", final, overwrite = TRUE)

# Verificación rápida
print(dbGetQuery(con, "
  SELECT * FROM indice_envejecimiento_montilla_harmonizado
  ORDER BY anio DESC
  LIMIT 15;
"))

dbDisconnect(con)