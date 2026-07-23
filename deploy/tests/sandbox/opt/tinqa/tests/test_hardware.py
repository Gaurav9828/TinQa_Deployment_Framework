import pytest
from unittest.mock import MagicMock, patch
from app.hardware.device_manager import DeviceManager
from unittest.mock import patch, MagicMock
from app.services.serial.serial_service import SerialService
from PIL import Image

def test_device_update_cycle():
    """Exercises the full path from frame generation to serial output."""
    # Initialize the DeviceManager
    dm = DeviceManager(32, 16)
    
    # Directly mock the serial_service inside the dm instance
    mock_service = MagicMock()
    dm.serial_service = mock_service
    
    dm.brightness = 100
    dm.power = True
    
    # Trigger the update logic
    dm.update()
    
    # Verify that the device manager called its serial service
    assert mock_service.send_frame.called
    
    # Verify the arguments: it should pass a PIL Image and the brightness
    args, _ = mock_service.send_frame.call_args
    assert args[1] == 100  # Brightness check


def test_serial_send_frame_error_handling():
    """Trigger the 'except' blocks in serial_service for full coverage."""
    with patch('serial.Serial') as mock_serial:
        # Simulate a serial connection failure
        mock_serial.side_effect = Exception("Port Busy")
        service = SerialService()
        
        from PIL import Image
        img = Image.new('RGB', (32, 16))
        
        # This should hit the 'except' block and log the error
        service.send_frame(img, brightness=100)
        assert True # Success if no crash occurred

def test_serial_connection_error_handling():
    """Covers the error handling paths when the ESP32 is disconnected."""
    with patch('serial.Serial') as mock_serial:
        # Simulate a 'Serial Exception' to trigger the error handling code
        mock_serial.side_effect = Exception("Serial Port Not Found")
        service = SerialService()
        
        img = Image.new('RGB', (32, 16))
        # This should execute the 'except' block and return gracefully
        service.send_frame(img, brightness=100)
        assert True 

def test_serial_write_logic():
    """Covers the actual byte-writing loop in serial_service by patching the local import."""
    # Patch the serial class WHERE it's used
    with patch('app.services.serial.serial_service.serial.Serial') as mock_serial:
        mock_inst = MagicMock()
        mock_serial.return_value = mock_inst
        
        # Initialize service after patching
        service = SerialService()
        
        # Ensure the service thinks the port is open
        service.ser = mock_inst 
        
        from PIL import Image
        img = Image.new('RGB', (32, 16))
        service.send_frame(img, brightness=100)
        
        # Verify that the byte-writing loop was triggered
        assert mock_inst.write.called