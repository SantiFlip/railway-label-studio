# Label Studio on Railway

One-click deployment of Label Studio for data annotation.

## Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https://github.com/YOUR_USERNAME/label-studio-railway)

## Manual Setup

1. Fork this repo
2. Create new project on [Railway](https://railway.app)
3. Deploy from GitHub repo
4. Add PostgreSQL database (recommended)
5. Set environment variables

## Environment Variables

### For PostgreSQL (recommended)
DJANGO_DB=default
POSTGRE_NAME=${{Postgres.PGDATABASE}}
POSTGRE_USER=${{Postgres.PGUSER}}
POSTGRE_PASSWORD=${{Postgres.PGPASSWORD}}
POSTGRE_HOST=${{Postgres.PGHOST}}
POSTGRE_PORT=${{Postgres.PGPORT}}

## Optional

LABEL_STUDIO_USERNAME=admin@company.com
LABEL_STUDIO_PASSWORD=your_secure_password
SSRF_PROTECTION_ENABLED=true

