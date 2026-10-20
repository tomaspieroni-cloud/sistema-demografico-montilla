# ============================================================
# Unión – Índice de dependencia (Montilla)
# Regla: IECA <= 2022 (GLOBAL), INE >= 2023
# Salida DB: indice_dependencia_montilla
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")

library(DBI)
library(RPostgres)
library(dplyr)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname="montilla_db", host="localhost", port=5432,
  user="montilla_user", password="montilla_pass"
)

ieca <- dbGetQuery(con, "SELECT * FROM indice_dependencia_ieca;")
ine  <- dbGetQuery(con, "SELECT * FROM indice_dependencia_ine;")

#quedarnos SOLO con la dependencia TOTAL (global)
ieca_global <- ieca %>%
  filter(tipo == "Índice de dependencia global") %>%
  select(anio, indice_dependencia, fuente)

# aplicar regla de unión
ieca_final <- ieca_global %>% filter(anio <= 2022)
ine_final  <- ine %>% filter(anio >= 2023) %>% select(anio, indice_dependencia, fuente)

dep_final <- bind_rows(ieca_final, ine_final) %>% arrange(anio)

# guardar tabla final
dbWriteTable(con, "indice_dependencia_montilla", dep_final, overwrite = TRUE)

# verificación
dbGetQuery(con, "SELECT * FROM indice_dependencia_montilla ORDER BY anio;")

dbDisconnect(con)
