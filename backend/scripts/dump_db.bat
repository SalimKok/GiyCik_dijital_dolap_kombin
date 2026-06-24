@echo off
REM =====================================================================
REM  GiyÇık PostgreSQL Database Backup Script
REM  Exports the 'gircik' database schema and data to backup.sql
REM =====================================================================

SET PGPASSWORD=sk6137!

echo [1/2] Dumping database schema and data...
pg_dump -U postgres -h localhost -p 5432 --no-owner --no-privileges --if-exists --clean gircik > "%~dp0..\backup.sql"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] pg_dump failed. Make sure PostgreSQL is running and credentials are correct.
    SET PGPASSWORD=
    exit /b 1
)

echo [2/2] Backup completed successfully!
echo File: %~dp0..\backup.sql

SET PGPASSWORD=
