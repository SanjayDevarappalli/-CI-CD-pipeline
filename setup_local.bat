@echo off
REM =========================================================
REM  setup_local.bat  —  Windows local dev setup
REM  Double-click this OR run from Command Prompt / PowerShell
REM =========================================================

echo.
echo ╔══════════════════════════════════════════╗
echo ║   TaskAPI — Windows Setup Script        ║
echo ╚══════════════════════════════════════════╝
echo.

REM ── Check Python ─────────────────────────────────────────
where python >nul 2>&1
IF ERRORLEVEL 1 (
    echo ERROR: python not found. Download from https://python.org
    pause & exit /b 1
)
python --version
echo [OK] Python found

REM ── Create virtual environment ───────────────────────────
IF NOT EXIST ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)
echo [OK] Virtual environment ready

REM ── Activate and install deps ────────────────────────────
call .venv\Scripts\activate.bat
echo Installing dependencies...
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
echo [OK] Dependencies installed

REM ── Create .env if missing ───────────────────────────────
IF NOT EXIST ".env" (
    echo Creating .env file...
    (
        echo FLASK_APP=wsgi.py
        echo FLASK_ENV=development
        echo FLASK_DEBUG=1
        echo DATABASE_URL=sqlite:///tasks.db
        echo SECRET_KEY=dev-secret-key-change-in-production
    ) > .env
    echo [OK] Created .env ^(SQLite mode^)
) ELSE (
    echo [OK] .env already exists
)

REM ── Set env vars from .env ───────────────────────────────
for /F "tokens=1,2 delims==" %%A in (.env) do (
    IF NOT "%%A"=="" IF NOT "%%A:~0,1%"=="#" SET %%A=%%B
)

REM ── Init DB ──────────────────────────────────────────────
echo Setting up database...
flask db init 2>nul
flask db migrate -m "initial" 2>nul
flask db upgrade
echo [OK] Database ready

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  Setup complete!                                    ║
echo ║                                                     ║
echo ║  Start the app:   run_app.bat                       ║
echo ║  Run tests:       run_tests.bat                     ║
echo ║  Docker mode:     docker compose up --build         ║
echo ╚══════════════════════════════════════════════════════╝
echo.
pause
