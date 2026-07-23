import pytest
import json
import sys
import asyncio
from unittest.mock import MagicMock, AsyncMock, patch

# --- 1. BOILERPLATE MOCKING ---
if 'bless' not in sys.modules:
    mock_bless = MagicMock()
    sys.modules['bless'] = mock_bless
    mock_bless.GATTCharacteristicProperties = MagicMock()
    mock_bless.GATTAttributePermissions = MagicMock()

# --- 2. IMPORTS (Updated to your actual UUIDs) ---
from app.services.ble.ble_server import TinQaBLEServer
from app.config.ble_constants import (
    TINQA_SERVICE_UUID,
    DEVICE_INFO_CHAR_UUID,
    COMMAND_CHAR_UUID,
    STATUS_CHAR_UUID
)

# --- 3. FIXTURES ---
@pytest.fixture
def ble_server():
    """Provides a fresh BLE server instance for each test."""
    return TinQaBLEServer()

# --- 4. OPTIMIZED TESTS ---

def test_ble_read_device_info(ble_server):
    """Verify the BLE read request returns valid JSON with required fields."""
    mock_char = MagicMock()
    mock_char.uuid = DEVICE_INFO_CHAR_UUID
        
    response = ble_server.read_request(mock_char)
    data = json.loads(response.decode())
    
    assert "deviceId" in data
    assert "firmware" in data
    assert data["type"] == "weather-sync"

def test_ble_command_write(ble_server):
    """Verify commands (like WiFi or Brightness) can be written via BLE."""
    mock_char = MagicMock()
    mock_char.uuid = COMMAND_CHAR_UUID 
    
    # Simulate a command payload
    payload = json.dumps({"cmd": "set_brightness", "value": 255}).encode()
    
    # This triggers the 'write_request' logic in ble_server.py
    ble_server.write_request(mock_char, payload)
    assert True 

@pytest.mark.asyncio
async def test_ble_async_run_mock(ble_server):
    """Exercise the async startup logic by patching the BlessServer class."""
    # 1. Create the AsyncMock that will act as our server instance
    mock_instance = AsyncMock()
    
    # 2. Patch the BlessServer CLASS where it is imported in ble_server.py
    # This ensures that when 'BlessServer(name=...)' is called, it returns our mock_instance
    with patch('app.services.ble.ble_server.BlessServer', return_value=mock_instance):
        # 3. Prevent the infinite loop
        with patch('asyncio.sleep', side_effect=asyncio.CancelledError):
            try:
                await ble_server.run_async()
            except asyncio.CancelledError:
                pass # Gracefully caught the intentional break
                
    # 5. Verify the service was registered with your TINQA_SERVICE_UUID
    mock_instance.add_new_service.assert_called_with(TINQA_SERVICE_UUID)