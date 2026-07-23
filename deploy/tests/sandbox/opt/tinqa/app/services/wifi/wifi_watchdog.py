import threading
import time
from app.services.wifi.wifi_manager import WiFiManager

def wifi_watchdog_loop():
    while True:
        try:
            status = WiFiManager.get_wifi_status()
            if not status.get("connected"):
                print("❌ WiFi disconnected")
            time.sleep(300)
        except Exception as error:
            time.sleep(30)

def start_wifi_watchdog():
    threading.Thread(target=wifi_watchdog_loop, daemon=True).start()