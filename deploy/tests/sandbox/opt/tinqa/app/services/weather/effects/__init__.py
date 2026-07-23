from .atmospheric import FoggyMorning, AuroraBorealis, GalaxySwirl
from .clear_sky import RotatingMilkyWay
from .stormy import StormNight

SCENARIO_REGISTRY = {
    "fog": FoggyMorning,
    "aurora": AuroraBorealis,
    "galaxy": GalaxySwirl,
    "milky_way": RotatingMilkyWay,
    "storm": StormNight
}