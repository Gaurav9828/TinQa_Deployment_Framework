import time
import threading

class RenderLoop:
    def __init__(self, device_manager, fps=30):
        self.device = device_manager
        self.frame_time = 1.0 / fps
        self.running = False

    def start(self):
        if self.running: return
        self.running = True
        thread = threading.Thread(target=self.run, daemon=True)
        thread.start()

    def run(self):
        while self.running:
            start = time.time()
            self.device.update()
            elapsed = time.time() - start
            sleep_time = self.frame_time - elapsed
            if sleep_time > 0:
                time.sleep(sleep_time)