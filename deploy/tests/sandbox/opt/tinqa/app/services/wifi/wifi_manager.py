import subprocess
import socket
import time
import platform

class WiFiManager:
    @staticmethod
    def connect_wifi(ssid, password):
        try:
            subprocess.run(["sudo", "nmcli", "dev", "wifi", "rescan"], timeout=10)
            cmd = f'sudo nmcli dev wifi connect "{ssid}" password "{password}"'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=45)
            if result.returncode == 0:
                return {"success": True, "ip": WiFiManager.get_ip_address()}
            return {"success": False, "error": result.stderr}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def get_current_wifi():
        """Returns the SSID of the currently connected network."""
        try:
            if platform.system() == "Linux":
                return subprocess.check_output(["iwgetid", "-r"]).decode().strip()
            # On Mac for local testing:
            return "Mac_Test_WiFi" 
        except:
            return None

    @staticmethod
    def get_ip_address():
        """Standard IP retrieval used by the service."""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return None

    @staticmethod
    def get_wifi_status():
        """Returns a comprehensive status dictionary for the API and health checks."""
        ip = WiFiManager.get_ip_address()
        return {
            "connected": ip is not None,
            "ip": ip,
            "ssid": WiFiManager.get_current_wifi(), # Ensure this key is 'ssid'
            "internet": True  # Optional: keep this if used in your health reports
        }