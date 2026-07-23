from fastapi import APIRouter
import threading
from app.services.ble.ble_manager import start_ble_cycle, BLE_STATUS

router = APIRouter()

@router.get("/ble/start")
def start_ble():
    threading.Thread(target=start_ble_cycle, daemon=True).start()
    return {"status": "BLE advertising triggered"}

@router.get("/ble/status")
def get_ble_status():
    return {"ble_status": BLE_STATUS}