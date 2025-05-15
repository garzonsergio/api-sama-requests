FROM ubuntu:22.04

# Evita preguntas interactivas
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependencias del sistema
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv cron && \
    apt-get clean

# Crea el directorio de trabajo
WORKDIR /app

# Copia los archivos del proyecto al contenedor
COPY . /app

# Instala las dependencias de Python
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt

# Da permisos de ejecución al script wrapper
RUN chmod +x /app/run_main_limited.sh

# Configura el cronjob
RUN echo "* * * * * /app/run_main_limited.sh >> /app/cron_wrapper.log 2>&1" > /etc/cron.d/sama-cron

# Da permisos correctos al archivo de cron y aplica
RUN chmod 0644 /etc/cron.d/sama-cron && crontab /etc/cron.d/sama-cron

# Asegura que cron se ejecute en primer plano
CMD ["cron", "-f"]