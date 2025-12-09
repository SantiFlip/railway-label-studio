# Label Studio Deployment on Railway

## Quick Deploy

1. Create a new GitHub repository for Label Studio
2. Add the files from [Quick Setup](#quick-setup-files) below
3. Go to [Railway](https://railway.app)
4. Create new project → Deploy from GitHub repo
5. Add PostgreSQL database (optional but recommended)
6. Configure environment variables (see [Required Variables](#required-environment-variables))

---

## Required Environment Variables

### CSRF Configuration (Critical!)

These variables are **required** to avoid the `403 CSRF verification failed` error.

| Variable | Value | Notes |
|----------|-------|-------|
| `LABEL_STUDIO_HOST` | `https://your-app.up.railway.app` | **No trailing slash!** |
| `CSRF_TRUSTED_ORIGINS` | `https://your-app.up.railway.app` | **No trailing slash!** |
| `DJANGO_CSRF_TRUSTED_ORIGINS` | `https://your-app.up.railway.app` | **No trailing slash!** |

### Cookie Security

| Variable | Value | Notes |
|----------|-------|-------|
| `LABEL_STUDIO_SESSION_COOKIE_SECURE` | `1` | Use `1` not `true` |
| `LABEL_STUDIO_CSRF_COOKIE_SECURE` | `1` | Use `1` not `true` |

### PostgreSQL Database (Recommended)

| Variable | Value |
|----------|-------|
| `DJANGO_DB` | `default` |
| `POSTGRE_NAME` | `${{Postgres.PGDATABASE}}` |
| `POSTGRE_USER` | `${{Postgres.PGUSER}}` |
| `POSTGRE_PASSWORD` | `${{Postgres.PGPASSWORD}}` |
| `POSTGRE_HOST` | `${{Postgres.PGHOST}}` |
| `POSTGRE_PORT` | `${{Postgres.PGPORT}}` |

### Optional Settings

| Variable | Value | Description |
|----------|-------|-------------|
| `LABEL_STUDIO_USERNAME` | `admin@company.com` | Pre-set admin email |
| `LABEL_STUDIO_PASSWORD` | `your_password` | Pre-set admin password |
| `LABEL_STUDIO_DISABLE_SIGNUP_WITHOUT_LINK` | `0` | Allow open signups |
| `SSRF_PROTECTION_ENABLED` | `1` | Enable for production |
| `DEBUG` | `0` | Disable in production |

---

## ⚠️ Common Mistakes to Avoid

### 1. Boolean Values
Label Studio expects `1` or `0`, **not** `true` or `false`:

```bash
# ❌ WRONG - causes ValueError
LABEL_STUDIO_SESSION_COOKIE_SECURE=true

# ✅ CORRECT
LABEL_STUDIO_SESSION_COOKIE_SECURE=1
```

### 2. Trailing Slashes
URLs must **not** have a trailing slash:

```bash
# ❌ WRONG - causes CSRF failure
LABEL_STUDIO_HOST=https://my-app.up.railway.app/

# ✅ CORRECT
LABEL_STUDIO_HOST=https://my-app.up.railway.app
```

### 3. Quotes in Railway UI
Don't add quotes around values in Railway's UI - they handle strings automatically:

```bash
# ❌ WRONG - quotes become part of the value
"https://my-app.up.railway.app"

# ✅ CORRECT - no quotes needed
https://my-app.up.railway.app
```

---

## Quick Setup Files

### Dockerfile

```dockerfile
FROM docker.io/heartexlabs/label-studio:latest

ENV DATA_DIR=/label-studio/data
ENV MEDIA_ROOT=/label-studio/data/media

RUN mkdir -p /label-studio/data/media /label-studio/logs

USER root
RUN chown -R 1001:1001 /label-studio/data /label-studio/logs
USER 1001

CMD label-studio start --host 0.0.0.0 --port ${PORT:-8080}
```

### railway.json

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10,
    "healthcheckPath": "/health",
    "healthcheckTimeout": 300
  }
}
```

---

## Complete Setup Script

Run this to create a new Label Studio repository:

```bash
# Create directory
mkdir label-studio-railway && cd label-studio-railway

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM docker.io/heartexlabs/label-studio:latest

ENV DATA_DIR=/label-studio/data
ENV MEDIA_ROOT=/label-studio/data/media

RUN mkdir -p /label-studio/data/media /label-studio/logs

USER root
RUN chown -R 1001:1001 /label-studio/data /label-studio/logs
USER 1001

CMD label-studio start --host 0.0.0.0 --port ${PORT:-8080}
EOF

# Create railway.json
cat > railway.json << 'EOF'
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10,
    "healthcheckPath": "/health",
    "healthcheckTimeout": 300
  }
}
EOF

# Create README
cat > README.md << 'EOF'
# Label Studio on Railway

One-click deployment of Label Studio for data annotation.

## Deploy

1. Fork this repo
2. Go to [railway.app](https://railway.app)
3. New Project → Deploy from GitHub
4. Add PostgreSQL database (click + New → Database → PostgreSQL)
5. Configure environment variables (see below)

## Required Environment Variables

```
LABEL_STUDIO_HOST=https://your-app.up.railway.app
CSRF_TRUSTED_ORIGINS=https://your-app.up.railway.app
DJANGO_CSRF_TRUSTED_ORIGINS=https://your-app.up.railway.app
LABEL_STUDIO_SESSION_COOKIE_SECURE=1
LABEL_STUDIO_CSRF_COOKIE_SECURE=1
```

## PostgreSQL Variables

```
DJANGO_DB=default
POSTGRE_NAME=${{Postgres.PGDATABASE}}
POSTGRE_USER=${{Postgres.PGUSER}}
POSTGRE_PASSWORD=${{Postgres.PGPASSWORD}}
POSTGRE_HOST=${{Postgres.PGHOST}}
POSTGRE_PORT=${{Postgres.PGPORT}}
```

## Important Notes

- Use `1` or `0` for boolean values (not `true`/`false`)
- No trailing slashes on URLs
- No quotes around values in Railway UI
EOF

# Initialize git
git init
git add .
git commit -m "Initial Label Studio Railway deployment"

echo ""
echo "Done! Next steps:"
echo "1. Create a new GitHub repo"
echo "2. git remote add origin https://github.com/YOUR_USERNAME/label-studio-railway.git"
echo "3. git push -u origin main"
echo "4. Deploy on Railway"
```

---

## Connecting Google Cloud Storage (GCS)

### 1. Create Service Account

```bash
# Create service account
gcloud iam service-accounts create label-studio-railway \
    --display-name="Label Studio Railway"

# Grant storage access to your bucket
gsutil iam ch serviceAccount:label-studio-railway@YOUR_PROJECT.iam.gserviceaccount.com:objectAdmin gs://YOUR_BUCKET_NAME

# Create key file
gcloud iam service-accounts keys create gcs-key.json \
    --iam-account=label-studio-railway@YOUR_PROJECT.iam.gserviceaccount.com
```

### 2. Configure CORS on GCS Bucket

```bash
# Create cors-config.json
cat > cors-config.json << 'EOF'
[
   {
      "origin": ["*"],
      "method": ["GET","PUT","POST","DELETE","HEAD"],
      "responseHeader": ["Content-Type","Access-Control-Allow-Origin"],
      "maxAgeSeconds": 3600
   }
]
EOF

# Apply CORS configuration
gsutil cors set cors-config.json gs://YOUR_BUCKET_NAME
```

### 3. Add Storage in Label Studio UI

1. Open your Railway Label Studio URL
2. Create or open a project
3. Go to **Settings → Cloud Storage**
4. Click **Add Source Storage**
5. Select **Google Cloud Storage**
6. Enter:
   - **Bucket:** your-bucket-name
   - **Prefix:** (optional folder path)
   - **Google Application Credentials:** paste contents of `gcs-key.json`
7. Click **Add Storage**

---

## Connecting to Cloud SQL PostgreSQL

### Option A: Public IP (Simpler)

1. Enable public IP on your Cloud SQL instance
2. Authorize Railway's IPs (or `0.0.0.0/0` for testing)
3. Create a database and user:

```bash
gcloud sql databases create labelstudio --instance=YOUR_INSTANCE
gcloud sql users create labelstudio --instance=YOUR_INSTANCE --password=YOUR_PASSWORD
```

4. Set Railway environment variables:

```
DJANGO_DB=default
POSTGRE_NAME=labelstudio
POSTGRE_USER=labelstudio
POSTGRE_PASSWORD=YOUR_PASSWORD
POSTGRE_HOST=YOUR_CLOUD_SQL_PUBLIC_IP
POSTGRE_PORT=5432
```

### Option B: Use Railway's PostgreSQL (Recommended for Testing)

1. In Railway, click **+ New** → **Database** → **PostgreSQL**
2. Railway auto-provisions the database
3. Use the `${{Postgres.XXX}}` syntax to auto-link variables

---

## Cost Estimate

| Plan | Monthly Cost | Notes |
|------|--------------|-------|
| Free Tier | $0 | 500 execution hours, may sleep |
| Hobby | ~$5-10 | Always on, recommended for testing |
| Pro | ~$20+ | Team features, more resources |

---

## Troubleshooting

### CSRF Error (403 Forbidden)

**Symptoms:** "CSRF verification failed" when signing up or logging in

**Solutions:**
1. Ensure `CSRF_TRUSTED_ORIGINS` matches your Railway URL exactly
2. Remove trailing slashes from URLs
3. Add both `CSRF_TRUSTED_ORIGINS` and `DJANGO_CSRF_TRUSTED_ORIGINS`
4. Redeploy after changing variables

### ValueError: invalid literal for int()

**Symptoms:** Container crashes with `ValueError: invalid literal for int() with base 10: 'true'`

**Solution:** Use `1` or `0` instead of `true` or `false` for boolean environment variables

### Container keeps restarting

**Solutions:**
- Check logs in Railway dashboard
- Ensure PostgreSQL is connected if `DJANGO_DB=default`
- Verify all environment variables are set correctly
- Check for typos in variable names

### Can't access GCS files

**Solutions:**
- Verify service account has `Storage Object Admin` role
- Check CORS is configured on the bucket
- Ensure the JSON key is valid and complete
- Test with a public bucket first

### Slow performance

**Solutions:**
- Upgrade to Hobby plan for more RAM
- Use PostgreSQL instead of SQLite for better concurrency
- Consider moving to GCP Compute Engine for production
