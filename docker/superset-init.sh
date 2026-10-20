#!/bin/bash

echo "=== Starting Superset setup ==="

superset db upgrade
superset fab create-admin \
    --username "${SUPERSET_ADMIN_USER}" \
    --firstname Admin \
    --lastname Montilla \
    --email admin@example.com \
    --password "${SUPERSET_ADMIN_PASSWORD}"
superset init

# Import the Montilla dashboard and charts if the export is available
if [ -f "/app/dashboard.zip" ]; then
    echo "=== Importing Montilla dashboard ==="
    superset import-dashboards -p /app/dashboard.zip
fi

echo "=== Setup completed ==="

superset run -p 8088 -h 0.0.0.0 --with-threads --reload
