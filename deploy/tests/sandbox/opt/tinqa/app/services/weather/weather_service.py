import requests
import json
import time
import os
from app.config import settings

CACHE_FILE = "weather_cache.json"

def get_weather_data():
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE, 'r') as f:
            cache = json.load(f)
        if (time.time() - cache.get("timestamp", 0)) < settings.CACHE_DURATION:
            return cache.get("data")

    url = f"http://api.openweathermap.org/data/2.5/weather?q={settings.CITY}&appid={settings.WEATHER_API_KEY}"
    try:
        response = requests.get(url, timeout=10)
        data = response.json()
        with open(CACHE_FILE, 'w') as f:
            json.dump({"timestamp": time.time(), "data": data}, f)
        return data
    except: return None