suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
})

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "montilla_db"),
  host = Sys.getenv("DB_HOST", "localhost"),
  port = as.integer(Sys.getenv("DB_PORT", "5432")),
  user = Sys.getenv("DB_USER", "montilla_user"),
  password = Sys.getenv("DB_PASS")
)

on.exit(dbDisconnect(con), add = TRUE)

print(dbGetQuery(con, "SELECT COUNT(*) AS n FROM montilla_indicadores_migracion_fix;"))
print(dbGetQuery(con, "SELECT COUNT(*) AS n FROM montilla_indicadores_migracion_fix WHERE indicador_id IN ('b12','b13');"))
print(dbGetQuery(con, "SELECT MIN(anio) AS min_anio, MAX(anio) AS max_anio FROM montilla_indicadores_migracion_fix WHERE indicador_id IN ('b12','b13');"))
