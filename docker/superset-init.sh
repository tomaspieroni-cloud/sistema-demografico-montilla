#!/bin/bash

echo "=== Iniciando configuración de Superset ==="

superset db upgrade
superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname Montilla \
    --email admin@montilla.com \
    --password admin
superset init

# Inyectar dashboard automáticamente si se encuentra el archivo físico
if [ -f "/app/dashboard.zip" ]; then
    echo "=== Importando dashboards y gráficos de Montilla ==="
    superset import-dashboards -p /app/dashboard.zip
fi

echo "=== Configuración completada con éxito ==="

superset run -p 8088 -h 0.0.0.0 --with-threads --reload