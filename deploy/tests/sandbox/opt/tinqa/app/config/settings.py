import os

# Server Settings
PORT = 21324

# Hardware Dimensions (32x16 LED Matrix)
WIDTH = 32
HEIGHT = 16

# Communication Settings
BAUD_RATE = 921600
WLED_IP = "192.168.29.x"  # Update this to your ESP32's current IP

# Weather API Settings
CITY = "Ladakh"  # Based on your travel interests
WEATHER_API_KEY = "YOUR_OPENWEATHERMAP_API_KEY"
CACHE_DURATION = 3600  # 1 hour in seconds