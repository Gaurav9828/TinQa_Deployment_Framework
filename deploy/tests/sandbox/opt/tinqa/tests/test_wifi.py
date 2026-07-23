import pytest
from unittest.mock import patch, MagicMock
from app.services.wifi.wifi_manager import WiFiManager

@patch('app.services.wifi.wifi_manager.WiFiManager.get_ip_address')
@patch('app.services.wifi.wifi_manager.WiFiManager.get_current_wifi')
def test_wifi_status_format(mock_ssid, mock_ip):
    """Verify the wifi status returns the correct dictionary structure."""
    mock_ip.return_value = "192.168.1.50"
    mock_ssid.return_value = "TinQa_Home"
    
    status = WiFiManager.get_wifi_status()
    
    # These must match the keys in your WiFiManager.get_wifi_status() method
    assert status["connected"] is True
    assert status["ssid"] == "TinQa_Home" 
    assert status["ip"] == "192.168.1.50"

@patch('subprocess.run')
def test_wifi_connection_failure(mock_run):
    """Test handling of a failed connection attempt."""
    # Simulate a failed nmcli execution
    mock_run.return_value = MagicMock(returncode=1, stderr="Error: No network found")
    
    result = WiFiManager.connect_wifi("Fake_SSID", "wrong_password")
    
    # Updated to check 'error' instead of 'status' to match your WiFiManager code
    assert result["success"] is False
    assert "error" in result
    assert "No network found" in result["error"]