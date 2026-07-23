import json

def load_json_file(path):
    try:
        with open(path, 'r') as f:
            return json.load(f)
    except:
        return {}

def save_json_file(path, data):
    with open(path, 'w') as f:
        json.dump(data, f, indent=4)

def map_range(x, in_min, in_max, out_min, out_max):
    """Standard Arduino-style map function for scaling values."""
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min