# Database schema

Generated from `database/dump.sql` (PostgreSQL 15). Tables and views of the `montilla_db` database.

## Tables

| Table | Rows | Columns |
|---|---:|---|
| `crecimiento_natural_rebuild` | 67 | cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto |
| `defunciones_montilla` | 29 | anio, defunciones |
| `dim_indicador_sima` | 8 | indicador_id, bloque, indicador_nombre, unidad, tipo |
| `edad_media_sexo_ieca` | 75 | anio, sexo, edad_media, fuente |
| `edad_media_sexo_ine` | 15 | anio, sexo, edad_media, fuente |
| `edad_media_sexo_montilla` | 84 | anio, sexo, edad_media, fuente |
| `indice_dependencia_ieca` | 3 | anio, tipo, indice_dependencia |
| `indice_dependencia_ine` | 5 | anio, indice_dependencia |
| `indice_envejecimiento_forecast_2032` | 36 | anio, fuente_modelo, metodo, tipo, valor, lo80, hi80, lo95, hi95 |
| `indice_envejecimiento_ieca` | 26 | municipio, anio, indicador, medida, indice_envejecimiento, fuente |
| `indice_envejecimiento_ine` | 5 | anio, indice_envejecimiento |
| `inmigracion_sexo_ieca_2003_2021` | 57 | anio, sexo, inmigraciones, fuente |
| `migracion_ieca_2003_2021` | 19 | anio, inmigraciones, emigraciones, saldo_migratorio, fuente |
| `migracion_ine_2021_2024_total` | 4 | anio, inmigracion_exterior, emigracion_exterior, inmigracion_intermunicipal, emigracion_intermunicipal, inmigraciones, emigraciones, saldo_migratorio_calculado, fuente |
| `migracion_rebuild` | 44 | cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto |
| `montilla_indicadores_final_long` | 132 | cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto |
| `nacimientos_montilla` | 19 | anio, nacimientos |
| `paro_registrado_montilla_sexo` | 51 | anio, sexo, paro_registrado |
| `poblacion_edad_sexo_ine_censo_2021_2025` | 210 | anio, sexo, grupo_edad, edad_min, poblacion, fuente |
| `poblacion_edad_sexo_ine_comparativa` | 1050 | anio, sexo, grupo_edad, edad_min, poblacion, fuente |
| `poblacion_edad_sexo_ine_padron_2003_2022` | 840 | anio, sexo, grupo_edad, edad_min, poblacion, fuente |
| `poblacion_joven_ine_2003_2022` | 20 | anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente |
| `poblacion_joven_ine_2021_2025` | 5 | anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente |
| `poblacion_joven_ine_serie` | 23 | anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente |
| `poblacion_joven_ine_stack` | 25 | anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente |
| `saldo_migratorio_comparativa` | 23 | anio, saldo_migratorio, fuente |
| `saldo_migratorio_ine_2021_2024` | 4 | anio, saldo_migratorio, fuente |
| `tasa_saldo_migratorio_comparativa` | 23 | anio, saldo_migratorio, fuente, poblacion_total, tasa_saldo_1000 |

## Views

- `montilla_indicadores_migracion_fix`: final long-format indicator table used by the Shiny app and Superset (combines `montilla_indicadores_final_long` with the rebuilt migration and natural-growth series).

## Indicator dictionary (`dim_indicador_sima`)

| ID | Block | Indicator | Unit |
|---|---|---|---|
| b01 | Poblacion | Poblacion total | habitantes |
| b02 | Poblacion | Poblacion. Hombres | habitantes |
| b03 | Poblacion | Poblacion. Mujeres | habitantes |
| b06 | Poblacion | Porcentaje de poblacion menor de 20 anos | % |
| b07 | Poblacion | Porcentaje de poblacion mayor de 65 anos | % |
| b08 | Poblacion | Variacion relativa de la poblacion en diez anos | % |
| b14 | Poblacion | Nacimientos | nacimientos |
| b15 | Poblacion | Defunciones | defunciones |
