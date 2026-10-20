# ============================================================
# Run the full R pipeline in dependency order
#
# Requirements:
#   - PostgreSQL running (e.g. `docker compose up -d postgres`)
#   - Environment variables from .env: DB_HOST, DB_PORT, DB_NAME,
#     DB_USER, DB_PASS and MONTILLA_DATA_DIR (folder with raw data)
#
# Usage (from the repository root):
#   Rscript R/run_pipeline.R
# ============================================================

repo_root <- normalizePath(getwd())

steps <- c(
  # 1. Official population series (INE, Art. 17)
  "R/02_etl/01_etl_ine_poblacion_art17.R",
  # 2. Mean age by sex: IECA load + own INE calculation + union
  "R/02_etl/02_etl_ieca_edad_media_sexo.R",
  "R/03_indicators/01_calculo_edad_media_sexo_ine_2021_2025.R",
  "R/04_harmonisation/01_union_edad_media_sexo.R",
  # 3. Dependency ratio: IECA load + own INE calculation + union
  "R/02_etl/03_etl_ieca_indice_dependencia.R",
  "R/03_indicators/02_calculo_indice_dependencia_ine_2021_2025.R",
  "R/04_harmonisation/02_union_indice_dependencia.R",
  # 4. Ageing index: IECA load and rebuild + own INE calculation + harmonisation
  "R/02_etl/04_etl_ieca_indice_envejecimiento.R",
  "R/02_etl/05_rebuild_ieca_indice_envejecimiento.R",
  "R/03_indicators/03_calculo_indice_envejecimiento_ine_2021_2025.R",
  "R/04_harmonisation/03_armonizar_indice_envejecimiento.R",
  # 5. Young population (15-29) and population pyramid (needed by migration)
  "R/03_indicators/04_calculo_poblacion_joven_ine_2003_2025.R",
  # 6. Migration, registered unemployment and vital statistics
  "R/02_etl/06_etl_migracion.R",
  "R/02_etl/07_etl_paro_registrado.R",
  "R/02_etl/08_etl_registros_civiles.R",
  # 7. Final long-format indicator table and corrections
  "R/05_final_table/01_tabla_final_indicadores.R",
  "R/05_final_table/02_migracion_b12_b13.R",
  "R/05_final_table/03_vista_indicadores_migracion.R",
  "R/05_final_table/04_crecimiento_natural.R",
  "R/05_final_table/05_migracion_ine_2021_2024.R",
  "R/05_final_table/06_variacion_poblacion_10_anios.R",
  "R/05_final_table/07_validacion_indicadores_migracion.R",
  # 8. Ageing index projection to 2032
  "R/06_analysis/01_proyeccion_indice_envejecimiento_2032.R"
)

for (step in steps) {
  path <- file.path(repo_root, step)
  message("\n>>> Running ", step)
  source(path, local = new.env(), encoding = "UTF-8")
  setwd(repo_root)
}

message("\nPipeline completed.")
