from PIL import Image
from app.services.weather.weather_engine import WeatherManager
from app.services.weather.effects import SCENARIO_REGISTRY
from app.services.rendering.frame_cache import FrameCache
from app.services.serial.serial_service import SerialService
from app.workers.thread_manager import ThreadManager

class DeviceManager:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.brightness = 60
        self.power = True
        self.mode = "ANIMATION"
        self.solid_color = (255, 255, 255)
        
        self.weather_engine = WeatherManager(width, height)
        self.serial_service = SerialService()
        self.frame_cache = FrameCache()
        self.thread_pool = ThreadManager.get_instance()
        
        self.weather_engine.set_effect(SCENARIO_REGISTRY["milky_way"])

    def set_color(self, hex_color):
        """Changes mode to SOLID_COLOR and updates the color value."""
        self.mode = "SOLID_COLOR"
        self.solid_color = self.hex_to_rgb(hex_color)

    def set_theme(self, theme):
        if theme in SCENARIO_REGISTRY:
            self.weather_engine.set_effect(SCENARIO_REGISTRY[theme])
            self.mode = "ANIMATION"

    def update(self):
        if not self.power:
            return
            
        if self.mode == "SOLID_COLOR":
            frame = Image.new("RGB", (self.width, self.height), self.solid_color)
        else:
            frame = self.weather_engine.get_frame()

        if self.frame_cache.should_send(frame):
            self.serial_service.send_frame(frame, self.brightness)

    def hex_to_rgb(self, hex_color):
        hex_color = hex_color.lstrip("#")
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

    def set_brightness(self, value):
        self.brightness = max(0, min(value, 100))

    def set_power(self, state: bool):
        self.power = state
        if not state:
            black = Image.new("RGB", (self.width, self.height), (0, 0, 0))
            self.serial_service.send_frame(black, 0)