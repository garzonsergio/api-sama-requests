#!/bin/bash

# Directorio donde reside este script y main.py
SCRIPT_DIR="/app"

# Intérprete de Python
PYTHON_EXEC="python3"
# Script de Python a ejecutar
PYTHON_SCRIPT="$SCRIPT_DIR/main.py"

# Archivo de log
LOG_FILE="$SCRIPT_DIR/cron_wrapper.log"

# Registrar la ejecución con fecha y hora
NOW=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$NOW] Ejecutando run_main_limited.sh" >> "$LOG_FILE"

# Ejecutar el script de Python
$PYTHON_EXEC $PYTHON_SCRIPT >> "$LOG_FILE" 2>&1
