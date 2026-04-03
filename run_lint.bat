@echo off
REM ── run_lint.bat  —  Lint the codebase on Windows ──
call .venv\Scripts\activate.bat
echo Running flake8 linter...
echo.
flake8 app/ tests/ wsgi.py
IF ERRORLEVEL 1 (
    echo.
    echo [FAIL] Lint errors found — fix them before committing.
) ELSE (
    echo [OK] No lint errors.
)
echo.
pause
