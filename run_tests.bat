@echo off
REM ── run_tests.bat  —  Run pytest with coverage on Windows ──
call .venv\Scripts\activate.bat
echo Running test suite...
echo.
pytest tests/ -v --cov=app --cov-report=term-missing
echo.
pause
