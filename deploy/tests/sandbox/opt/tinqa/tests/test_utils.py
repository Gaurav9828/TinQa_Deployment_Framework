import pytest
from unittest.mock import patch, mock_open
from app.utils.system_utils import get_device_id

def test_get_device_id_fail():
    """Trigger the 'except' block in device ID retrieval."""
    with patch("builtins.open", side_effect=FileNotFoundError):
        device_id = get_device_id()
        assert device_id == "TinQa-UNKNOWN"

def test_get_device_id_success():
    """Verify parsing of CPU serial numbers."""
    mock_cpuinfo = "Serial : 00000000abcdefgh\n"
    with patch("builtins.open", mock_open(read_data=mock_cpuinfo)):
        device_id = get_device_id()
        assert "abcdefgh" in device_id