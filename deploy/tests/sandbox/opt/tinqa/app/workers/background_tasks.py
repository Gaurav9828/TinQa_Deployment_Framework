import time
import threading
from app.services.weather.weather_service import get_weather_data

def weather_update_worker(device_manager):
    """Periodically fetches weather data to influence effects."""
    while True:
        try:
            weather = get_weather_data()
            if weather:
                print(f"🌦 Background weather update: {weather.get('weather', [{}])[0].get('main')}")
                # You can extend this to auto-switch themes based on actual weather
        except Exception as e:
            print(f"Error in background weather task: {e}")
        
        time.sleep(1800)  # Check every 30 minutes

def start_background_workers(device_manager):
    thread = threading.Thread(target=weather_update_worker, args=(device_manager,), daemon=True)
    thread.start()