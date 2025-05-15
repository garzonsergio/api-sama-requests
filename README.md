# SAMA API Firestore Loader

This project fetches data from the API endpoint https://geopiragua.corantioquia.gov.co/api/v1/estaciones and stores it in a Google Firestore database. It is designed to run automatically at regular intervals using a cron job inside a Docker container.

## Features
- Fetches station data from the SAMA API.
- Stores each station as a document in a Firestore collection named with the current date and time (e.g., `estaciones_20250515_1530`).
- Runs automatically every minute (or at a custom interval) using cron inside Docker.
- Logs every execution and the output of the Python script to `cron_wrapper.log`.

## Requirements
- Docker
- A valid Firebase service account credentials file (`records-sama-firebase-adminsdk-fbsvc-515269b6c0.json`)

## Usage

### 1. Build the Docker Image

```
docker build -t sama-cron .
```

### 2. Run the Docker Container

```
docker run -d --name sama-cron sama-cron
```

This will start the container in detached mode. The cron job inside the container will execute the script every minute by default.

### 3. Check the Logs

#### See the last 50 lines of the log:
```
docker exec sama-cron tail -n 50 /app/cron_wrapper.log
```

#### See the log in real time:
```
docker exec -it sama-cron tail -f /app/cron_wrapper.log
```

#### See the container's standard output:
```
docker logs sama-cron
```

### 4. Stop the Cron Job Quickly

To stop the cron job (and all processes in the container) immediately:
```
docker stop sama-cron
```

To remove the container completely:
```
docker rm sama-cron
```

### 5. Modify the Cron Schedule

By default, the cron job is set to run every minute. To change the interval (for example, to every 5 minutes):

1. Edit the `Dockerfile` line that sets up the cron job:
   ```dockerfile
   RUN echo "* * * * * /app/run_main_limited.sh >> /app/cron_wrapper.log 2>&1" > /etc/cron.d/sama-cron
   ```
   Change it to:
   ```dockerfile
   RUN echo "*/5 * * * * /app/run_main_limited.sh >> /app/cron_wrapper.log 2>&1" > /etc/cron.d/sama-cron
   ```
   (This will run the script every 5 minutes.)

2. Rebuild the Docker image and restart the container:
   ```bash
   docker build -t sama-cron .
   docker stop sama-cron && docker rm sama-cron
   docker run -d --name sama-cron sama-cron
   ```

## Project Structure

- `main.py` — Python script that fetches API data and stores it in Firestore.
- `run_main_limited.sh` — Bash script called by cron to execute `main.py` and log output.
- `requirements.txt` — Python dependencies.
- `Dockerfile` — Docker build instructions.
- `records-sama-firebase-adminsdk-fbsvc-515269b6c0.json` — Firebase credentials (not included in version control).
- `cron_wrapper.log` — Log file generated at runtime.

## Notes
- The Firestore database and credentials must be properly configured for the script to work.
- The Docker container does not use a Python virtual environment; dependencies are installed globally inside the container.
- The log file (`cron_wrapper.log`) will grow over time; consider rotating or cleaning it if running long-term.

---

For any issues or questions, please check the logs as described above or open an issue in your repository.
