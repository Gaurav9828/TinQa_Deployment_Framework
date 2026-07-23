import pytest
from app.services.weather.weather_engine import WeatherManager
from app.services.weather.effects.atmospheric import FoggyMorning

def test_effect_switching():
    """Ensure the engine correctly updates the active effect instance."""
    manager = WeatherManager(32, 16)
    manager.set_effect(FoggyMorning)
    
    assert isinstance(manager.active_effect, FoggyMorning)
    assert manager.active_effect.width == 32
    
    frame = manager.get_frame()
    assert frame.size == (32, 16)