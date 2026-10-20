# ETL INE – Población municipal (Art. 17)
# Municipio: Montilla
# Fuente: Instituto Nacional de Estadística (INE)
# Formato: JSON local
# La ingesta de datos se realizó a partir del fichero JSON correspondiente a las 
# Cifras Oficiales de Población del INE (Art. 17), descargado desde la plataforma INEbase.

# Librerías 
library(tidyverse)
library(jsonlite)

# Ruta al archivo JSON
ruta_json <- file.path(Sys.getenv("MONTILLA_DATA_DIR", "."), "Datos INE/Demograficos/población de los municipios españoles en aplicación de la Ley de Bases del Régimen Local (Art. 17).json")

# Cargar el JSON 
datos <- fromJSON(ruta_json)

# Comprobación rápida
str(datos)
names(datos)

# Desanidar la estructura
# El INE guarda las series temporales dentro de la columna 'Data'
datos_long <- datos %>%
  unnest(Data)

# Verificar que ahora existen las variables clave
names(datos_long)
glimpse(datos_long)

# Filtrar el municipio de Montilla 
# En esta tabla, Montilla aparece claramente en el campo 'Nombre'
datos_montilla <- datos_long %>%
  filter(str_detect(Nombre, "^Montilla"))

# Comprobación
unique(datos_montilla$Nombre)

# Separar población total --------------------------------
poblacion_total_montilla <- datos_montilla %>%
  filter(str_detect(Nombre, "Total\\. Total")) %>%
  select(
    Anyo,
    Valor
  ) %>%
  rename(
    anio = Anyo,
    poblacion_total = Valor
  ) %>%
  arrange(anio)

# Resultado final
glimpse(poblacion_total_montilla)
summary(poblacion_total_montilla)

# Vista rápida
print(poblacion_total_montilla)




# Carga en PostgreSQL
library(DBI)
library(RPostgres)

#Conexión a la base
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME", "montilla_db"),
  host = Sys.getenv("DB_HOST", "localhost"),
  port = as.integer(Sys.getenv("DB_PORT", "5432")),
  user = Sys.getenv("DB_USER", "montilla_user"),
  password = Sys.getenv("DB_PASS")
)

# Comprobar conexión
dbListTables(con)


# ETL población por sexo (Montilla)
poblacion_montilla_sexo <- datos_long %>%
  filter(str_detect(Nombre, "^Montilla")) %>%
  mutate(
    sexo = case_when(
      str_detect(Nombre, "Hombres") ~ "Hombres",
      str_detect(Nombre, "Mujeres") ~ "Mujeres",
      str_detect(Nombre, "Total\\. Total") ~ "Total",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(sexo)) %>%
  select(
    Anyo,
    sexo,
    Valor
  ) %>%
  rename(
    anio = Anyo,
    poblacion = Valor
  ) %>%
  arrange(anio, sexo)

glimpse(poblacion_montilla_sexo)
table(poblacion_montilla_sexo$sexo)


dbWriteTable(
  con,
  "poblacion_montilla_sexo",
  poblacion_montilla_sexo,
  overwrite = TRUE
)

dbListTables

dbGetQuery(con, "SELECT * FROM poblacion_montilla_sexo LIMIT 5")

dbDisconnect(con)