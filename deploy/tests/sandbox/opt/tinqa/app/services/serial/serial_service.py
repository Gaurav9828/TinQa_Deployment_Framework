import serial
import serial.tools.list_ports
import time
import numpy as np
from app.config import settings

class SerialService:
    def __init__(self):
        self.port = self._find_port()
        self.ser = None
        if self.port:
            self.ser = serial.Serial(self.port, settings.BAUD_RATE, timeout=0.1)
            time.sleep(2)

    def _find_port(self):
        for p in serial.tools.list_ports.comports():
            if any(x in p.description.lower() for x in ["cp210", "ch340", "usb"]):
                return p.device
        return None

    def send_frame(self, image, brightness):
        if not self.ser: return
        img = image.resize((settings.WIDTH, settings.HEIGHT))
        arr = np.array(img.convert("RGB"), dtype=np.float32)
        arr *= (brightness / 100.0)
        data = arr.astype(np.uint8).tobytes()
        
        self.ser.write(bytes([255, settings.WIDTH, settings.HEIGHT, 255]))
        self.ser.write(data)
        
        # Await Hardware Ack
        start = time.time()
        while self.ser.read() != b'K':
            if time.time() - start > 0.1: break