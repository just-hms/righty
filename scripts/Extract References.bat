@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0external.ps1" %*
