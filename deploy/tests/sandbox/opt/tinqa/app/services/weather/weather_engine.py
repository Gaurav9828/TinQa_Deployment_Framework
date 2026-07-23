from PIL import Image
import time

class BaseWeather:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.start_time = time.time()

    def update(self):
        """Override for animation logic."""
        pass

    def get_frame(self) -> Image:
        """Returns the current animation frame."""
        return Image.new("RGB", (self.width, self.height), (0, 0, 0))

class WeatherManager:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.active_effect = None

    def set_effect(self, effect_class):
        print(f"[ENGINE] Scaling to {self.width}x{self.height} for {effect_class.__name__}")
        self.active_effect = effect_class(self.width, self.height)

    def get_frame(self):
        if self.active_effect:
            self.active_effect.update() 
            return self.active_effect.get_frame()
        return Image.new("RGB", (self.width, self.height), (0, 0, 0))