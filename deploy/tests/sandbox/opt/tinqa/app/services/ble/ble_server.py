import asyncio
import json
import logging
from bless import (
    BlessServer,
    GATTCharacteristicProperties,
    GATTAttributePermissions
)
from app.utils.system_utils import get_device_id, get_ip_address
from app.config.ble_constants import (
    TINQA_SERVICE_UUID,
    DEVICE_INFO_CHAR_UUID,
    COMMAND_CHAR_UUID,
    STATUS_CHAR_UUID
)

class TinQaBLEServer:
    def __init__(self):
        self.server = None
        self.device_name = get_device_id()

    def read_request(self, characteristic, **kwargs):
        uuid = str(characteristic.uuid)
        if uuid == DEVICE_INFO_CHAR_UUID:
            payload = {
                "deviceId": self.device_name,
                "ip": get_ip_address(),
                "firmware": "1.1.0",
                "type": "weather-sync"
            }
            return json.dumps(payload).encode()
        return bytearray()

    def write_request(self, characteristic, value, **kwargs):
        decoded = bytes(value).decode("utf-8")
        print(f"📩 BLE Command Received: {decoded}")

    async def run_async(self):
        self.server = BlessServer(name=self.device_name)
        await self.server.add_new_service(TINQA_SERVICE_UUID)
        
        await self.server.add_new_characteristic(
            TINQA_SERVICE_UUID, DEVICE_INFO_CHAR_UUID,
            GATTCharacteristicProperties.read, bytearray(),
            GATTAttributePermissions.readable
        )
        
        await self.server.add_new_characteristic(
            TINQA_SERVICE_UUID, COMMAND_CHAR_UUID,
            GATTCharacteristicProperties.write | GATTCharacteristicProperties.read,
            bytearray(), GATTAttributePermissions.readable | GATTAttributePermissions.writeable
        )

        self.server.read_request_func = self.read_request
        self.server.write_request_func = self.write_request
        
        await self.server.start()
        while True:
            await asyncio.sleep(1)

def start_ble_server():
    ble = TinQaBLEServer()
    asyncio.run(ble.run_async())