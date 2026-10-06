setwd("C:/Users/tomas/OneDrive/Master Granada/Practicas Montilla")

library(tidyverse)

ruta_inmi <- file.path("Datos","Migracion","Inmigraciones por sexo en Montilla.txt")

inmi_raw <- read_delim(
  ruta_inmi,
  delim = ";",
  locale = locale(decimal_mark = ",", encoding = "UTF-8"),
  trim_ws = TRUE
)

glimpse(inmi_raw)
names(inmi_raw)