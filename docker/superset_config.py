import os

# Superset metadata database (credentials come from .env via docker-compose)
SQLALCHEMY_DATABASE_URI = (
    "postgresql+psycopg2://"
    f"{os.environ['SUPERSET_DB_USER']}:{os.environ['SUPERSET_DB_PASS']}"
    f"@postgres_superset:5432/{os.environ['SUPERSET_DB_NAME']}"
)
