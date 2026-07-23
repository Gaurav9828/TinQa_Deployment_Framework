import random
import math
import time
from PIL import Image, ImageDraw
from app.services.weather.weather_engine import BaseWeather

class RotatingMilkyWay(BaseWeather):
    def __init__(self, width, height):
        super().__init__(width, height)
        self.center_x = width // 2
        self.center_y = height + 10 
        self.stars = []
        self._generate_stars()

    def _generate_stars(self):
        count = (self.width * self.height) // 5 
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            radius = random.uniform(5, self.width * 1.5)
            galaxy_plane = math.pi / 4 
            dist = abs(math.sin(angle - galaxy_plane))
            if random.random() < math.exp(-dist * 5) or random.random() < 0.05:
                is_core = dist < 0.15
                color = random.choice([(255, 210, 170), (200, 200, 255), (255, 255, 255)]) if is_core else (200, 200, 200)
                self.stars.append({
                    "radius": radius, "angle": angle, "color": color,
                    "brightness": random.randint(180, 255) if is_core else random.randint(100, 180),
                    "offset": random.uniform(0, 1000)
                })

    def get_frame(self):
        img = Image.new("RGB", (self.width, self.height), (2, 2, 12))
        draw = ImageDraw.Draw(img)
        t = time.time()
        rotation = t * ((2 * math.pi) / 86400) # Real-world rotation speed
        for s in self.stars:
            total_angle = s["angle"] + rotation
            x = self.center_x + s["radius"] * math.cos(total_angle)
            y = self.center_y + s["radius"] * math.sin(total_angle)
            if 0 <= x < self.width and 0 <= y < self.height:
                twinkle = 0.7 + 0.3 * math.sin(t * 1.5 + s["offset"])
                r, g, b = s["color"]
                final = tuple(int(c * twinkle * (s["brightness"]/255)) for c in (r, g, b))
                draw.point((int(x), int(y)), fill=final)
        return img