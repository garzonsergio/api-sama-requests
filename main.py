import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import requests
import os
from datetime import datetime

# Initialize Firebase
try:
    # Get the absolute path to the credentials file
    cred_path = os.path.join(os.path.dirname(__file__), 'records-sama-firebase-adminsdk-fbsvc-515269b6c0.json')
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    db = firestore.client(database_id="stations")
    print("Firebase App initialized successfully in database stations.")
except Exception as e:
    print(f"Error initializing Firebase: {e}")
    exit()

# API endpoint
api_url = "https://geopiragua.corantioquia.gov.co/api/v1/estaciones"

def fetch_and_store_data():
    """Fetches data from the API and stores it in Firestore."""
    try:
        response = requests.get(api_url)
        response.raise_for_status()  # Raise an exception for bad status codes (4xx or 5xx)
        data = response.json()
        
        # Get the date and time of the last request
        now = datetime.now().strftime("%Y%m%d_%H:%M")
        # Set colection name with date and time
        collection_name = f"estaciones_{now}"

        
        if not data:
            print("No data received from API.")
            return

        estaciones_collection = db.collection(collection_name)

        stations_list = data.get('values', [])
        if not stations_list:
            print("No station data found in the API response.")
            return
        
        for station in stations_list:
            station_id = str(station.get('id')) if station.get('id') is not None else str(station.get('codigo'))
            if station_id and station_id != 'None':
                # Store the data in Firestore
                estaciones_collection.document(station_id).set(station)
                print(f"Stored data for station ID: {station_id}")
            else:
                print(f"Station data missing a unique ID: {station}")
        print(f"Successfully stored {len(stations_list)} stations in Firestore.")
        
    
    # Handle potential errors
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data from API: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    fetch_and_store_data()
