import math
from PIL import Image, ImageDraw
from app.services.weather.weather_engine import BaseWeather

class FoggyMorning(BaseWeather):
    def __init__(self, width, height):
        super().__init__(width, height)
        self.offset = 0

    def update(self):
        self.offset += 0.05

    def get_frame(self):
        img = Image.new("RGB", (self.width, self.height), (100, 100, 100))
        draw = ImageDraw.Draw(img)
        for x in range(self.width):
            for y in range(self.height):
                noise = math.sin(x * 0.2 + self.offset) * math.cos(y * 0.3 + self.offset)
                val = int(180 + 40 * noise)
                draw.point((x, y), fill=(val, val, val))
        return img

class AuroraBorealis(BaseWeather):
    def __init__(self, width, height):
        super().__init__(width, height)
        self.phase = 0

    def update(self):
        self.phase += 0.03

    def get_frame(self):
        img = Image.new("RGB", (self.width, self.height), (0, 0, 10))
        draw = ImageDraw.Draw(img)
        for x in range(self.width):
            wave = math.sin(self.phase + x * 0.3) * (self.height / 3)
            center_y = (self.height / 2) + wave
            for y in range(self.height):
                dist = abs(y - center_y)
                if dist < 4:
                    g = int(255 * (1 - dist/4))
                    b = int(150 * (1 - dist/4))
                    p = int(100 * math.sin(self.phase))
                    draw.point((x, y), fill=(p, g, b))
        return img

class GalaxySwirl(BaseWeather):
    def __init__(self, width, height):
        super().__init__(width, height)
        self.angle = 0

    def update(self):
        self.angle += 0.02

    def get_frame(self):
        img = Image.new("RGB", (self.width, self.height), (5, 0, 15))
        draw = ImageDraw.Draw(img)
        cx, cy = self.width // 2, self.height // 2
        for x in range(self.width):
            for y in range(self.height):
                dx, dy = x - cx, y - cy
                dist = math.sqrt(dx*dx + dy*dy)
                theta = math.atan2(dy, dx) + dist * 0.5 + self.angle
                brightness = math.sin(theta * 3)
                if brightness > 0.5:
                    r = int(100 * brightness)
                    b = int(255 * brightness)
                    draw.point((x, y), fill=(r, 0, b))
        return img