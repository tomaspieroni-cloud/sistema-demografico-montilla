# Sistema de Análisis Demográfico Municipal – Montilla

Solución de datos de extremo a extremo y reproducible que integra estadísticas demográficas oficiales del municipio de Montilla (Córdoba) y las pone a disposición del personal municipal mediante una aplicación Shiny y un panel de Apache Superset.

Desarrollado por **Tomás Nelio Pieroni** en prácticas curriculares (Universidad de Granada – Ayuntamiento de Montilla, marzo–junio de 2026).

## Resumen

- **Fuentes:** INE (API JSON, WFS de secciones censales), IECA / SIMA y SEPE.
- **Flujo:** descarga y ETL en R → PostgreSQL → Shiny (8 pestañas, exportación en ZIP de la tabla final) y Superset → usuarios del Ayuntamiento.
- **Despliegue:** Docker Compose.
- **Decisión metodológica:** no se ocultan las diferencias entre IECA (padrón) e INE (censo anual desde 2021). Se conservan ambas fuentes, se documenta el motivo y se aplican reglas explícitas de unión o un ajuste por solapamiento 2021–2022.

## Puesta en marcha

```bash
git clone https://github.com/tomaspieroni-cloud/sistema-demografico-montilla.git
cd sistema-demografico-montilla
cp .env.example .env      # editar las contraseñas
docker compose up -d
```

- Shiny: http://localhost:3839
- Superset: http://localhost:8088 (usuario y contraseña definidos en `.env`)

Para reejecutar el pipeline desde los datos de origen, ver la sección *Running the pipeline from raw data* del [README en inglés](README.md) y el orden de ejecución en [docs/execution_flow.md](docs/execution_flow.md).
