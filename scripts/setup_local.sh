#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# setup_local.sh  —  One-shot local development environment setup
# Works on macOS and Linux. On Windows use Git Bash or WSL2.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   TaskAPI — Local Setup Script                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── 1. Check Python ──────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 not found. Install Python 3.11+ first."
  exit 1
fi
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "✔  Python $PYTHON_VERSION found"

# ── 2. Create virtual environment ───────────────────────
if [ ! -d ".venv" ]; then
  echo "→  Creating virtual environment..."
  python3 -m venv .venv
fi
echo "✔  Virtual environment ready at .venv/"

# ── 3. Activate and install deps ────────────────────────
# shellcheck disable=SC1091
source .venv/bin/activate
echo "→  Installing dependencies..."
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
echo "✔  Dependencies installed"

# ── 4. Create .env file if missing ──────────────────────
if [ ! -f ".env" ]; then
  cat > .env <<'EOF'
# Local development environment variables
FLASK_APP=wsgi.py
FLASK_ENV=development
FLASK_DEBUG=1
# SQLite (no Postgres needed locally)
DATABASE_URL=sqlite:///tasks.db
SECRET_KEY=dev-secret-key-change-in-production
EOF
  echo "✔  Created .env (SQLite mode — no Docker needed)"
else
  echo "✔  .env already exists — skipping"
fi

# ── 5. Initialise / migrate database ────────────────────
export $(grep -v '^#' .env | xargs)
echo "→  Running database migrations..."
flask db init 2>/dev/null || true    # idempotent
flask db migrate -m "initial" 2>/dev/null || true
flask db upgrade
echo "✔  Database ready"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Setup complete!                               ║"
echo "║                                                 ║"
echo "║   Run the app:   source .venv/bin/activate      ║"
echo "║                  flask run                      ║"
echo "║                                                 ║"
echo "║   Run tests:     pytest tests/ -v               ║"
echo "║                                                 ║"
echo "║   Docker mode:   docker compose up --build      ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
