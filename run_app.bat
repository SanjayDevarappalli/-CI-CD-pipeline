@echo off
REM ── run_app.bat  —  Start the Flask dev server on Windows ──
call .venv\Scripts\activate.bat
for /F "tokens=1,2 delims==" %%A in (.env) do (
    IF NOT "%%A"=="" IF NOT "%%A:~0,1%"=="#" SET %%A=%%B
)
echo Starting Flask development server...
echo API will be available at:  http://127.0.0.1:5000
echo Health check:              http://127.0.0.1:5000/health
echo.
flask run --host=0.0.0.0 --port=5000
pause
