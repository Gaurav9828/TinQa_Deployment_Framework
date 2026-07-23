import time
import threading

from app.services.ble.ble_server import start_ble_server


BLE_STATUS = {
    "advertising": False,
    "connected": False
}

_ble_started = False

_ble_lock = threading.Lock()

_ble_thread = None


def _start_ble_thread():

    global _ble_thread

    _ble_thread = threading.Thread(
        target=start_ble_server,
        daemon=True
    )

    _ble_thread.start()


def enable_ble():

    global _ble_started

    with _ble_lock:

        if _ble_started:

            print("BLE already running")

            return

        print("🚀 Starting BLE...")

        _ble_started = True

        BLE_STATUS["advertising"] = False

        _start_ble_thread()

        print("✅ BLE thread started")


def start_ble_cycle():

    global _ble_started

    with _ble_lock:

        if _ble_started:

            print("BLE already active")

            return

    print("⏳ Waiting for Bluetooth stack...")

    time.sleep(2)

    enable_ble()

    start_time = time.time()

    while True:

        with _ble_lock:

            if not _ble_started:

                break

        elapsed = time.time() - start_time

        if elapsed >= 300:

            print("⌛ BLE timeout reached (auto stop)")

            disable_advertising()

            break

        time.sleep(5)


def disable_advertising():

    global _ble_started

    with _ble_lock:

        if not _ble_started:

            print("BLE already stopped")

            return

        print("🛑 Stopping BLE advertising...")

        _ble_started = False

        BLE_STATUS["advertising"] = False

    try:

        print("🧹 BLE cleanup done (no forced reset)")

    except Exception as e:

        print("❌ BLE stop error:", e)


def main():

    start_ble_cycle()