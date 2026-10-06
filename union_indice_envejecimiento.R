# ============================================================
# Unión de series - Índice de Envejecimiento Montilla
# Fuentes:
#   - IECA: 1996–2022 (oficial)
#   - INE:  2021–2025 (calculado)
# Regla:
#   - IECA manda hasta 2022
#   - INE desde 2023
# ============================================================

# -------------------------------
# 0. Working directory
# -------------------------------
setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")
getwd()

# -------------------------------
# 1. Librerías
# -------------------------------
library(DBI)
library(RPostgres)
library(dplyr)

# -------------------------------
# 2. Conexión a PostgreSQL
# -------------------------------
con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "montilla_db",
  host     = "localhost",
  port     = 5432,
  user     = "montilla_user",
  password = "montilla_pass"
)

# -------------------------------
# 3. Cargar series desde la base
# -------------------------------

ieca <- dbGetQuery(
  con,
  "SELECT anio, indice_envejecimiento, fuente
   FROM indice_envejecimiento_ieca"
)

ine <- dbGetQuery(
  con,
  "SELECT anio, indice_envejecimiento, fuente
   FROM indice_envejecimiento_ine"
)

# Comprobaciones mínimas
summary(ieca$anio)
summary(ine$anio)

# -------------------------------
# 4. Aplicar regla de unión
# -------------------------------

ieca_final <- ieca %>%
  filter(anio <= 2022)

ine_final <- ine %>%
  filter(anio >= 2023)

indice_final <- bind_rows(
  ieca_final,
  ine_final
) %>%
  arrange(anio)

# Validación
print(indice_final)
summary(indice_final)

# -------------------------------
# 5. Guardar tabla final
# -------------------------------
dbWriteTable(
  con,
  name = "indice_envejecimiento_montilla",
  value = indice_final,
  overwrite = TRUE
)

# Verificación
dbListTables(con)

dbGetQuery(
  con,
  "SELECT * FROM indice_envejecimiento_montilla ORDER BY anio"
)

# -------------------------------
# 6. Cerrar conexión
# -------------------------------
dbDisconnect(con)