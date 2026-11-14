@echo off
setlocal
cd /d "%~dp0"
echo Starting USB Backup Assistant...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0src\USB-Backup.ps1"
echo.
if errorlevel 1 (
  echo The backup ended with an error. Read the message above.
) else (
  echo The backup program has finished.
)
pause
endlocal
