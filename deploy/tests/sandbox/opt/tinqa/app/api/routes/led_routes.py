from fastapi import APIRouter
from pydantic import BaseModel

class BrightnessRequest(BaseModel):
    value: int

class ColorRequest(BaseModel):
    color: str

class ThemeRequest(BaseModel):
    theme: str

class PowerRequest(BaseModel):
    power: bool

def create_router(device):
    router = APIRouter()

    @router.get("/status")
    def get_status():
        return {
            "power": device.power,
            "brightness": device.brightness,
            "mode": device.mode
        }

    @router.post("/brightness")
    def set_brightness(req: BrightnessRequest):
        device.set_brightness(req.value)
        return {"status": "success", "value": device.brightness}

    @router.post("/theme")
    def set_theme(req: ThemeRequest):
        device.set_theme(req.theme)
        return {"status": "success", "theme": req.theme}

    @router.post("/color")
    def set_color(req: ColorRequest):
        # This triggers the solid color mode in DeviceManager
        device.set_color(req.color)
        return {"status": "success", "color": req.color}

    @router.post("/power")
    def set_power(req: PowerRequest):
        device.set_power(req.power)
        return {"status": "success", "power": device.power}

    return router