@echo off
setlocal
cd /d "%~dp0"
echo ============================================================
echo Nextcloud WebDAV Admin v19 - debug start
echo ============================================================
echo Script dir: %CD%
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -NoExit -File "%~dp0NextcloudWebDAVAdmin.ps1"
echo.
pause
endlocal
