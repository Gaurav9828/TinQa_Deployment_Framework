import hashlib

class FrameCache:
    def __init__(self):
        self.last_hash = None

    def should_send(self, image):
        current_hash = hashlib.md5(image.tobytes()).hexdigest()
        if current_hash == self.last_hash:
            return False
        self.last_hash = current_hash
        return True