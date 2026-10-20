# ============================================================
# ETL PARO REGISTRADO – Montilla
# Fuente: Datos/Empleo/Paro registrado por sexo Montilla.txt
# Salida PostgreSQL: paro_registrado_montilla_sexo
# ============================================================

# Folder that contains the downloaded raw data (see README: "Running the pipeline")
setwd(Sys.getenv("MONTILLA_DATA_DIR", "."))

library(tidyverse)
library(DBI)
library(RPostgres)

# -----------------------------------------------
# Función de conexión a PostgreSQL
# -----------------------------------------------
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

# -----------------------------------------------
# Lectura del archivo
# -----------------------------------------------
ruta_paro <- file.path("Datos", "Empleo", "Paro registrado por sexo Montilla.txt")
stopifnot(file.exists(ruta_paro))

paro_raw <- read_delim(
  ruta_paro,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

cat("\n--- Primeras filas de paro_raw ---\n")
print(head(paro_raw, 10))
cat("\nEstructura:\n")
print(glimpse(paro_raw))

# -----------------------------------------------
# Limpieza y transformación
# -----------------------------------------------
paro_clean <- paro_raw %>%
  select(
    anio = Anual,
    sexo = Sexo,
    valor = Valor
  ) %>%
  mutate(
    anio = as.integer(anio),
    valor = as.numeric(valor),
    sexo = str_trim(sexo),
    paro_registrado = valor
  ) %>%
  select(anio, sexo, paro_registrado) %>%
  arrange(anio, sexo)

cat("\n--- Paro limpio ---\n")
print(head(paro_clean, 15))
cat("\nRango de años:", min(paro_clean$anio), "-", max(paro_clean$anio), "\n")
cat("Valores de sexo únicos:", paste(unique(paro_clean$sexo), collapse = ", "), "\n")

# -----------------------------------------------
# Carga a PostgreSQL
# -----------------------------------------------
con <- conectar_pg()

tryCatch({
  # Intenta eliminar tabla anterior
  dbExecute(con, "DROP TABLE IF EXISTS paro_registrado_montilla_sexo")
  
  # Crea tabla nueva
  dbWriteTable(con, "paro_registrado_montilla_sexo", paro_clean, overwrite = TRUE)
  
  # Crea índices
  dbExecute(con, "CREATE INDEX idx_paro_anio ON paro_registrado_montilla_sexo(anio)")
  dbExecute(con, "CREATE INDEX idx_paro_sexo ON paro_registrado_montilla_sexo(sexo)")
  
  cat("\n✓ Tabla paro_registrado_montilla_sexo guardada en PostgreSQL\n")
  
  # Verifica
  verificacion <- dbGetQuery(con, "
    SELECT 
      COUNT(*) as total_registros,
      MIN(anio) as anio_min,
      MAX(anio) as anio_max
    FROM paro_registrado_montilla_sexo
  ")
  print(verificacion)
  
}, error = function(e) {
  cat("\n✗ Error al cargar datos:", conditionMessage(e), "\n")
}, finally = {
  dbDisconnect(con)
})
