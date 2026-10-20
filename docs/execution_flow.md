# Execution flow

The pipeline is run in this order by `R/run_pipeline.R`. Each step reads raw files from `MONTILLA_DATA_DIR` or tables already loaded in PostgreSQL, and writes its output to PostgreSQL.

| # | Script | What it does | Output (PostgreSQL) | Source |
|---|---|---|---|---|
| 1 | `02_etl/01_etl_ine_poblacion_art17.R` | Loads and unnests the official INE population JSON (Art. 17) | Total population and population by sex | INE |
| 2 | `02_etl/02_etl_ieca_edad_media_sexo.R` | Loads IECA text files and parses decimals | `edad_media_sexo_ieca` | IECA / SIMA |
| 3 | `03_indicators/01_calculo_edad_media_sexo_ine_2021_2025.R` | Estimates mean age from INE five-year age groups (mid-points) | `edad_media_sexo_ine` | INE annual census 2021-2025 |
| 4 | `04_harmonisation/01_union_edad_media_sexo.R` | Joins both series: IECA up to 2022, INE from 2023 | `edad_media_sexo_montilla` | Database |
| 5 | `02_etl/03_etl_ieca_indice_dependencia.R` | Cleans IECA dependency ratios by age type | `indice_dependencia_ieca` | IECA / SIMA |
| 6 | `03_indicators/02_calculo_indice_dependencia_ine_2021_2025.R` | Rebuilds the dependency ratio `((0-14 + 65+) / 15-64) * 100`, aligned with the IECA method | `indice_dependencia_ine` | INE annual census 2021-2025 |
| 7 | `04_harmonisation/02_union_indice_dependencia.R` | Joins both series: IECA up to 2022, INE from 2023 | `indice_dependencia_montilla` | Database |
| 8 | `02_etl/04_etl_ieca_indice_envejecimiento.R` | Loads and standardises the historical IECA ageing index | `indice_envejecimiento_ieca` | IECA / SIMA 1996-2022 |
| 9 | `02_etl/05_rebuild_ieca_indice_envejecimiento.R` | Rebuilds the long IECA series and fixes decimal parsing | `indice_envejecimiento_ieca` | IECA / SIMA |
| 10 | `03_indicators/03_calculo_indice_envejecimiento_ine_2021_2025.R` | Calculates the ageing index `(65+ / 0-14) * 100` from INE five-year groups | `indice_envejecimiento_ine` | INE annual census 2021-2025 |
| 11 | `04_harmonisation/03_armonizar_indice_envejecimiento.R` | Harmonises both series with an offset estimated on the 2021-2022 overlap | `indice_envejecimiento_montilla_harmonizado` | Database |
| 12 | `03_indicators/04_calculo_poblacion_joven_ine_2003_2025.R` | Young population (15-29), share of total and population by year, sex and five-year age group | `poblacion_joven_*`, `poblacion_edad_sexo_ine_*` | INE municipal register 2003-2022 and annual census 2021-2025 |
| 13 | `02_etl/06_etl_migracion.R` | Migration balance, immigration and emigration, comparison table for the 2021 overlap | `migracion_ieca_2003_2021`, `saldo_migratorio_*`, `tasa_saldo_migratorio_comparativa` | IECA and INE |
| 14 | `02_etl/07_etl_paro_registrado.R` | Registered unemployment by sex | `paro_registrado_montilla_sexo` | SEPE registered unemployment (local text file) |
| 15 | `02_etl/08_etl_registros_civiles.R` | Marriages, births and deaths | `registros_civiles_montilla` | Vital statistics (local text files) |
| 16 | `05_final_table/01_tabla_final_indicadores.R` | Builds the long-format indicator table and indicator dictionary | `montilla_indicadores_final_long`, `dim_indicador_sima` | Database and SIMA |
| 17 | `05_final_table/02_migracion_b12_b13.R` | Rebuilds immigration and emigration (b12, b13) without altering the final table | `migracion_rebuild` | Database |
| 18 | `05_final_table/03_vista_indicadores_migracion.R` | Recreates the final view used by the app | view `montilla_indicadores_migracion_fix` | Database |
| 19 | `05_final_table/04_crecimiento_natural.R` | Births, deaths and natural growth | `nacimientos_montilla`, `defunciones_montilla`, `crecimiento_natural_rebuild` | Vital statistics (local text files) |
| 20 | `05_final_table/05_migracion_ine_2021_2024.R` | Extends b12/b13 with INE EMCR flows: IECA 2003-2021, INE 2022-2024 | `migracion_rebuild` | INE EMCR |
| 21 | `05_final_table/06_variacion_poblacion_10_anios.R` | Recalculates the ten-year population change (b08) from INE Art. 17 | `montilla_indicadores_final_long` (b08 only) | INE |
| 22 | `05_final_table/07_validacion_indicadores_migracion.R` | Row counts and year ranges for the final view | none (checks only) | Database |
| 23 | `06_analysis/01_proyeccion_indice_envejecimiento_2032.R` | ARIMA projection (`auto.arima`) of the ageing index to 2032 with 80% and 95% intervals | `indice_envejecimiento_forecast_2032` | Database |

The download scripts in `R/01_download/` fetch the raw files from the INE API (JSON tables and census tracts WFS) and the IECA / SIMA municipal data file. They are run separately, before the pipeline.
