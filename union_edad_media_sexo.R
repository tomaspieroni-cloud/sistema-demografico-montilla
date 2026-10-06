# ============================================================
# Unión – Edad media por sexo (Montilla)
# Regla: IECA <= 2022, INE >= 2023
# Salida DB: edad_media_sexo_montilla
# ============================================================

setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")
getwd()

library(DBI)
library(RPostgres)
library(dplyr)

# -------------------------------
# 1) Conexión a PostgreSQL
# -------------------------------
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "montilla_db",
  host = "localhost",
  port = 5432,
  user = "montilla_user",
  password = "montilla_pass"
)

# -------------------------------
# 2) Leer tablas origen
# -------------------------------
ieca <- dbGetQuery(con, "SELECT anio, sexo, edad_media, fuente FROM edad_media_sexo_ieca;")
ine  <- dbGetQuery(con, "SELECT anio, sexo, edad_media, fuente FROM edad_media_sexo_ine;")

# -------------------------------
# 3) Aplicar regla de unión
#    IECA <= 2022  /  INE >= 2023
# -------------------------------
ieca_final <- ieca %>%
  filter(anio <= 2022)

ine_final <- ine %>%
  filter(anio >= 2023)

edad_final <- bind_rows(ieca_final, ine_final) %>%
  # Normalizar etiqueta de sexo para que IECA y INE coincidan
  mutate(sexo = ifelse(sexo == "Ambos sexos", "Total", sexo)) %>%
  arrange(anio, sexo)

# Opcional: si no queremos NAs (por ejemplo en 1998/2000), descomentar:
# edad_final <- edad_final %>% filter(!is.na(edad_media))

# -------------------------------
# 4) Guardar tabla final
# -------------------------------
dbWriteTable(con, "edad_media_sexo_montilla", edad_final, overwrite = TRUE)

# -------------------------------
# 5) Verificación (IMPORTANTE: antes de desconectar)
# -------------------------------
cat("\n--- Últimos 30 registros (DESC) ---\n")
print(dbGetQuery(con, "
  SELECT *
  FROM edad_media_sexo_montilla
  ORDER BY anio DESC, sexo
  LIMIT 30;
"))

cat("\n--- Primeros 30 registros (ASC) ---\n")
print(dbGetQuery(con, "
  SELECT *
  FROM edad_media_sexo_montilla
  ORDER BY anio ASC, sexo
  LIMIT 30;
"))

# -------------------------------
# 6) Cerrar conexión
# -------------------------------
dbDisconnect(con)

cat("\n✅ union_edad_media_sexo.R terminado correctamente.\n")