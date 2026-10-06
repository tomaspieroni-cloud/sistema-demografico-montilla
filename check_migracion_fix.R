suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
})

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "montilla_db",
  host = "localhost",
  port = 5432,
  user = "montilla_user",
  password = "montilla_pass"
)

on.exit(dbDisconnect(con), add = TRUE)

print(dbGetQuery(con, "SELECT COUNT(*) AS n FROM montilla_indicadores_migracion_fix;"))
print(dbGetQuery(con, "SELECT COUNT(*) AS n FROM montilla_indicadores_migracion_fix WHERE indicador_id IN ('b12','b13');"))
print(dbGetQuery(con, "SELECT MIN(anio) AS min_anio, MAX(anio) AS max_anio FROM montilla_indicadores_migracion_fix WHERE indicador_id IN ('b12','b13');"))
