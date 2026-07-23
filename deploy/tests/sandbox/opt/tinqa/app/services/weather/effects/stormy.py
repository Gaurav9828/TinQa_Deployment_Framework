import random
from PIL import Image, ImageDraw
from app.services.weather.weather_engine import BaseWeather

class StormNight(BaseWeather):
    def __init__(self, width, height):
        super().__init__(width, height)
        self.frame_queue = []

    def update(self):
        if not self.frame_queue and random.random() < 0.02:
            self.frame_queue = self._generate_strike()

    def _generate_strike(self):
        seq = []
        # Flash
        flash = Image.new("RGB", (self.width, self.height), (255, 255, 255))
        seq.append(flash)
        # Decay
        for b in [150, 80, 30, 0]:
            seq.append(Image.new("RGB", (self.width, self.height), (b, b, b+5)))
        return seq

    def get_frame(self):
        if self.frame_queue:
            return self.frame_queue.pop(0)
        return Image.new("RGB", (self.width, self.height), (1, 1, 5))