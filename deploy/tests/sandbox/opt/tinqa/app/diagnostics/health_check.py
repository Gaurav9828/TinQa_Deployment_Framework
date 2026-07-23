from datetime import datetime
from app.utils.system_utils import run_cmd_output, get_device_id, get_ip_address

def health_check(port=21324, ble_status="UNKNOWN"):
    report = ["\n========== START HEALTH REPORT =========="]
    report.append(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append(f"Device ID: {get_device_id()}")
    report.append(f"IP: {get_ip_address()}")
    
    # Service status checks [cite: 11, 23, 42]
    bt_status = run_cmd_output("systemctl is-active bluetooth")
    report.append(f"Bluetooth: {'OK' if bt_status == 'active' else 'FAIL'}")
    
    report.append(f"BLE Advertising: {ble_status}")
    report.append("========== END HEALTH REPORT ==========\n")
    return "\n".join(report)