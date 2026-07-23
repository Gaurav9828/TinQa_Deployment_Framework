import socket
from app.config import settings

class WLEDService:
    def __init__(self):
        self.esp_ip = settings.WLED_IP
        self.port = 21324 
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send_frame(self, image, brightness):
        img = image.convert("RGB")
        pixels = list(img.getdata())
        ratio = max(0, min(brightness, 100)) / 100.0
        
        frame = bytearray()
        for r, g, b in pixels:
            frame.extend([int(r * ratio), int(g * ratio), int(b * ratio)])

        try:
            # Chunked transmission logic preserved for ESP32 stability
            self.sock.sendto(frame[:768], (self.esp_ip, self.port))
            self.sock.sendto(frame[768:], (self.esp_ip, self.port))
        except Exception as e:
            print(f"UDP Error: {e}")