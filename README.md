# TaskAPI — Automated CI/CD Pipeline for Backend Python Web Application

Internship project by **Sanjay Devarapalli (CTIS6887)**  
Organisation: Codtech IT Solutions Private Limited  
Domain: DevOps with Backend (Python) | Duration: 12 Weeks

---

## Project Structure

```
taskapi/
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── models.py            # SQLAlchemy Task model
│   └── routes.py            # REST API endpoints
├── tests/
│   ├── conftest.py          # pytest fixtures
│   ├── test_models.py       # Unit tests (model layer)
│   └── test_routes.py       # Integration tests (API layer)
├── .github/
│   └── workflows/
│       └── ci-cd.yml        # GitHub Actions pipeline
├── scripts/
│   ├── deploy.sh            # EC2 zero-downtime deploy script
│   ├── provision_ec2.sh     # EC2 first-time setup script
│   └── setup_local.sh       # Linux/macOS local setup
├── Dockerfile               # Multi-stage Docker build
├── docker-compose.yml       # Local dev with PostgreSQL
├── requirements.txt
├── wsgi.py                  # WSGI entry point
├── pytest.ini
├── .flake8
│
│  ── Windows helpers ──
├── setup_local.bat          # One-shot Windows setup
├── run_app.bat              # Start Flask dev server
├── run_tests.bat            # Run pytest
└── run_lint.bat             # Run flake8
```

---

## Quickstart — Windows + Docker Desktop (Recommended)

> **Prerequisites:** Docker Desktop running, Git, Python 3.11+

### Step 1 — Clone the repository
```powershell
git clone https://github.com/<your-username>/taskapi.git
cd taskapi
```

### Step 2 — Start everything with Docker Compose
```powershell
docker compose up --build
```
This starts:
- **PostgreSQL 15** on port `5432`
- **Flask API** on port `5000` (with auto DB migration)

### Step 3 — Test the API
Open a new PowerShell window and try:

```powershell
# Health check
curl http://localhost:5000/health

# Create a task
curl -Method POST http://localhost:5000/api/tasks/ `
     -ContentType "application/json" `
     -Body '{"title": "My first task", "description": "Testing the API"}'

# List all tasks
curl http://localhost:5000/api/tasks/

# Update a task  (replace 1 with the actual task id)
curl -Method PUT http://localhost:5000/api/tasks/1 `
     -ContentType "application/json" `
     -Body '{"completed": true}'

# Delete a task
curl -Method DELETE http://localhost:5000/api/tasks/1
```

### Step 4 — Stop the containers
```powershell
docker compose down          # stop but keep DB data
docker compose down -v       # stop and wipe DB data
```

---

## Option B — Run Locally Without Docker

### Step 1 — Run the setup script
Double-click **`setup_local.bat`** or in Command Prompt:
```cmd
setup_local.bat
```
This creates a `.venv`, installs dependencies, and initialises an SQLite database.

### Step 2 — Start the app
```cmd
run_app.bat
```
API available at `http://127.0.0.1:5000`

### Step 3 — Run tests
```cmd
run_tests.bat
```

---

## API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/health` | Health check |
| GET | `/api/tasks/` | List all tasks |
| GET | `/api/tasks/?completed=true` | Filter by status |
| GET | `/api/tasks/<id>` | Get single task |
| POST | `/api/tasks/` | Create task |
| PUT | `/api/tasks/<id>` | Update task |
| DELETE | `/api/tasks/<id>` | Delete task |

### Request / Response Examples

**POST /api/tasks/**
```json
// Request body
{ "title": "Write tests", "description": "Cover all routes" }

// Response 201
{
  "id": 1,
  "title": "Write tests",
  "description": "Cover all routes",
  "completed": false,
  "created_at": "2025-09-05T10:00:00+00:00",
  "updated_at": "2025-09-05T10:00:00+00:00"
}
```

**PUT /api/tasks/1**
```json
// Request body
{ "completed": true }

// Response 200
{ "id": 1, "title": "Write tests", "completed": true, ... }
```

---

## Running Tests

```powershell
# Using the batch file (Windows)
run_tests.bat

# Or directly in PowerShell (after activating venv)
.venv\Scripts\activate
pytest tests/ -v --cov=app --cov-report=term-missing
```

Expected output: **21 passed**

---

## Linting

```powershell
run_lint.bat
# or
.venv\Scripts\activate
flake8 app/ tests/ wsgi.py
```

---

## CI/CD Pipeline (GitHub Actions)

The pipeline at `.github/workflows/ci-cd.yml` runs automatically on every push.

### Pipeline Flow
```
git push → Lint (flake8) → Tests (pytest) → Docker Build → Docker Push → Deploy EC2
```

### GitHub Secrets Required
Go to your repo → Settings → Secrets → Actions, and add:

| Secret | Value |
|--------|-------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `EC2_HOST` | Your EC2 public IP address |
| `EC2_SSH_KEY` | Contents of your EC2 `.pem` private key |

---

## Docker Commands Reference (Windows PowerShell)

```powershell
# Build image manually
docker build -t taskapi:latest .

# Run container standalone (SQLite, no Postgres needed)
docker run -p 5000:5000 `
  -e DATABASE_URL=sqlite:///tasks.db `
  taskapi:latest

# View running containers
docker ps

# View logs
docker logs taskapi_app

# Open shell inside container
docker exec -it taskapi_app /bin/bash

# Rebuild after code changes
docker compose up --build

# Remove everything (containers + volumes)
docker compose down -v --rmi all
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `sqlite:///tasks.db` | Database connection string |
| `FLASK_ENV` | `development` | Flask environment |
| `FLASK_DEBUG` | `1` | Enable debug mode |
| `SECRET_KEY` | *(set in .env)* | Flask secret key |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Python 3.11 |
| Framework | Flask 3.0 |
| ORM | Flask-SQLAlchemy |
| DB (prod) | PostgreSQL 15 |
| DB (dev/test) | SQLite |
| Container | Docker (multi-stage) |
| CI/CD | GitHub Actions |
| Registry | Docker Hub |
| Server | AWS EC2 (Ubuntu 22.04) |
| Testing | pytest + pytest-cov |
| Linting | flake8 |

---

## Intern Details

- **Name:** Sanjay Devarapalli
- **Intern ID:** CTIS6887
- **Organisation:** Codtech IT Solutions Private Limited
- **Period:** 05 September 2025 – 28 November 2025
- **Domain:** DevOps with Backend (Python)
