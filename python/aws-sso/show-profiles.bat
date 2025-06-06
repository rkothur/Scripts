@echo off
echo "================"
echo "Avaialble AWS profiles:"
echo "================"
REM type %HOMEPATH%\.aws\credentials |findstr [ 

powershell -Command "(gc %HOMEPATH%\.aws\credentials |findstr [) -replace '\[', '' -replace '\]', ''