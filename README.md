# Municipal Demographic Analysis System – Montilla (Spain)

An end-to-end, reproducible data system that integrates official demographic statistics for the municipality of Montilla (Córdoba, Spain) and makes them accessible to non-technical municipal staff through an interactive Shiny application and an Apache Superset dashboard.

Developed by **Tomás Nelio Pieroni** as a curricular internship (University of Granada – Montilla City Council, March–June 2026). Project page: [tomaspieroni-cloud.github.io/proyectos/sistema-demografico-montilla.html](https://tomaspieroni-cloud.github.io/proyectos/sistema-demografico-montilla.html)

## The problem

The City Council relied on demographic information from several official sources (INE, IECA, SEPE) that were scattered and not integrated. Planning social services, care for older people and policies to attract young residents required a single, documented and up-to-date evidence base.

## Architecture

```
INE and IECA APIs ──► ETL in R ──► PostgreSQL ──► Shiny app / Apache Superset ──► End users
                                       ▲
                       Docker Compose orchestrates every service
```

| Layer | Technology |
|---|---|
| Extraction | R (`httr`, `jsonlite`): INE JSON API, INE census tracts WFS, IECA / SIMA municipal data file |
| Transformation | R (`tidyverse`): cleaning, own indicator calculations, harmonisation between sources |
| Storage | PostgreSQL 15, relational model with a long-format indicator table and an indicator dictionary |
| Interfaces | Shiny (8 thematic tabs, ZIP export of the final indicator table) and Apache Superset dashboard |
| Deployment | Docker Compose |

## Methodological decision: harmonising sources

In 2021 the INE moved to an annual census based on administrative records, which does not fully match the IECA series based on the municipal register. Instead of forcing a single series, the system:

- keeps both sources and documents the reason for each difference;
- joins series with an explicit cut-off rule (IECA up to 2022, INE from 2023);
- for the ageing index, estimates an offset on the 2021–2022 overlap to produce a continuous harmonised series;
- lets users choose the source of each series in the Shiny app, with the overlap year marked on the charts.

## Indicators

Total population and population by sex, population structure (under 20, over 65), ten-year population change, mean age by sex, ageing index (with an ARIMA projection to 2032), dependency ratio, young population (15–29), population pyramid, immigration, emigration and migration balance, births, deaths and natural growth, and registered unemployment by sex. See [docs/database_schema.md](docs/database_schema.md).

## Repository structure

```
├── app/app.R                  Shiny application
├── database/dump.sql          PostgreSQL dump with all final tables and views
├── docker/                    Dockerfiles and Superset configuration
├── superset/dashboard.zip     Superset dashboard export
├── R/
│   ├── 01_download/           API download scripts (INE, IECA / SIMA)
│   ├── 02_etl/                Load and clean source files
│   ├── 03_indicators/         Own indicator calculations from INE data
│   ├── 04_harmonisation/      Joining and harmonising IECA and INE series
│   ├── 05_final_table/        Final long-format indicator table and corrections
│   ├── 06_analysis/           Ageing index projection to 2032
│   └── run_pipeline.R         Runs every step in dependency order
├── docs/
│   ├── execution_flow.md      What each script does, in order
│   └── database_schema.md     Tables, columns and indicator dictionary
├── docker-compose.yml
└── .env.example               Configuration template (credentials are not versioned)
```

## Quick start (Docker)

Requirements: Docker and Docker Compose.

```bash
git clone https://github.com/tomaspieroni-cloud/sistema-demografico-montilla.git
cd sistema-demografico-montilla
cp .env.example .env      # then edit the passwords in .env
docker compose up -d
```

PostgreSQL is initialised automatically from `database/dump.sql`.

| Service | URL |
|---|---|
| Shiny app | http://localhost:3839 |
| Superset | http://localhost:8088 (user and password from `.env`) |
| PostgreSQL | `localhost:5433` |

Ports can be changed in `.env`. If the Superset charts show a connection error after the first start, set the password of the `montilla_db` connection in *Settings → Database Connections* (Superset does not export passwords).

## Running the pipeline from raw data

The raw files are public (INE, IECA / SIMA) but are not versioned in this repository.

1. Download the source files with the scripts in `R/01_download/` (or manually from INE and IECA) into a local folder.
2. Set `MONTILLA_DATA_DIR` to that folder and the `DB_*` variables to your PostgreSQL instance (see `.env.example`).
3. From the repository root, run:

```bash
Rscript R/run_pipeline.R
```

The order of the steps and the output of each one are documented in [docs/execution_flow.md](docs/execution_flow.md).

## Key findings (2025 data)

- Population peaked at 23,907 in 2010 and fell to 22,192 in 2025.
- Mean age rose from 38.8 (2001) to 45.5 (2025).
- Deaths have exceeded births every year since 2011.
- The share of young people (15–29) fell from about 21% to just over 16%.

## Limitations

- Temporal coverage depends on what each source publishes.
- The system is built for one municipality; extending it requires reviewing geographic correspondences.
- Comments and object names in the code are in Spanish.

## Deliverables

ETL processes, relational PostgreSQL model, Shiny application, Superset dashboard, data dictionary, technical documentation, user manual and executive presentation. The user manual and the executive presentation were delivered to the City Council and are not part of this repository.

---

*Versión en español: [README.es.md](README.es.md)*
