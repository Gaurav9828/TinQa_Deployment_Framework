import pytest
from app.services.weather.effects.atmospheric import AuroraBorealis, GalaxySwirl
from app.services.weather.effects.clear_sky import RotatingMilkyWay
from app.services.weather.effects.stormy import StormNight

@pytest.mark.parametrize("effect_class", [
    AuroraBorealis, GalaxySwirl, RotatingMilkyWay, StormNight
])
def test_all_effects_render(effect_class):
    """Rigorous check to ensure every animation generates a valid frame."""
    effect = effect_class(32, 16)
    effect.update()
    frame = effect.get_frame()
    
    assert frame.size == (32, 16)
    assert frame.mode == "RGB"

def test_storm_lightning_sequence():
    """Specifically test the frame queue logic in the Storm effect."""
    storm = StormNight(32, 16)
    # Force a lightning strike generation for coverage
    storm.frame_queue = storm._generate_strike()
    assert len(storm.frame_queue) > 0
    
    frame = storm.get_frame()
    assert frame is not None