@echo off
set "ps1File=%~n0.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0%ps1File%" %*
