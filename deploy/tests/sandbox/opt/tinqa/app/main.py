import uvicorn
import threading
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI

from app.config import settings
from app.hardware.device_manager import DeviceManager
from app.services.rendering.render_loop import RenderLoop
from app.api.routes import led_routes

# 1. Initialize core components globally
device = DeviceManager(settings.WIDTH, settings.HEIGHT)
render_loop = RenderLoop(device, fps=30)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # --- Startup Logic ---
    render_loop.start()
    
    # Only start background workers and BLE if NOT in a test environment
    if not os.getenv("TESTING"):
        from app.workers.background_tasks import start_background_workers
        start_background_workers(device)

        try:
            from app.services.ble.ble_server import start_ble_server
            threading.Thread(target=start_ble_server, daemon=True).start()
        except ImportError:
            pass
            
    yield
    # --- Shutdown Logic ---
    render_loop.running = False
    
# 2. Initialize FastAPI app with lifespan handler
app = FastAPI(
    title="TinQa Weather Sync System", 
    lifespan=lifespan
)

# 3. Include Routers
app.include_router(led_routes.create_router(device), prefix="/api/v1/led")

@app.get("/health")
def health_check():
    """Verify system status for diagnostics."""
    from app.services.wifi.wifi_manager import WiFiManager
    return {
        "status": "online",
        "wifi": WiFiManager.get_wifi_status(),
        "device_id": device.width
    }

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app", 
        host="0.0.0.0", 
        port=settings.PORT, 
        reload=False
    )