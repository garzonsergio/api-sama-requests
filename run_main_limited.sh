#!/bin/bash

# Directorio donde reside este script y, asumimos, main.py y el .venv
SCRIPT_DIR="/home/scgarzonp/apis-sama/api-sama-requests"
# Asegúrate de que esta ruta sea la correcta en tu VM

# Archivo para llevar la cuenta de las ejecuciones
COUNT_FILE="$SCRIPT_DIR/.execution_count_wrapper.txt"
MAX_RUNS=5

# Intérprete de Python del entorno virtual
PYTHON_EXEC="$SCRIPT_DIR/.venv/bin/python"
# Script de Python a ejecutar
PYTHON_SCRIPT="$SCRIPT_DIR/main.py"

# --- Lógica de conteo y ejecución ---

# Obtener el conteo actual
CURRENT_COUNT=0
if [ -f "$COUNT_FILE" ]; then
    COUNT_CONTENT=$(cat "$COUNT_FILE")
    if [[ "$COUNT_CONTENT" =~ ^[0-9]+$ ]]; then # Verificar si es un número
        CURRENT_COUNT=$COUNT_CONTENT
    else
        echo "Contenido inválido en $COUNT_FILE. Reiniciando a 0."
        CURRENT_COUNT=0
    fi
else
    echo "Archivo de conteo no encontrado. Creando e iniciando en 0."
fi

echo "Verificando conteo de ejecución. Actual: $CURRENT_COUNT, Máximo: $MAX_RUNS"

if [ "$CURRENT_COUNT" -ge "$MAX_RUNS" ]; then
    echo "El script ya se ha ejecutado $CURRENT_COUNT veces (máximo $MAX_RUNS). Saliendo."
    echo "Para reiniciar, elimina el archivo: $COUNT_FILE"
    exit 0
fi

echo "Intento de ejecución del cron job: $((CURRENT_COUNT + 1))/$MAX_RUNS"

# Ejecutar el script de Python
"$PYTHON_EXEC" "$PYTHON_SCRIPT"
# Nota: La salida del script de Python irá al log del cron job como antes.

# Incrementar el contador
NEW_COUNT=$((CURRENT_COUNT + 1))
echo "$NEW_COUNT" > "$COUNT_FILE"
echo "Conteo de ejecución incrementado a: $NEW_COUNT"

exit 0
