from datetime import datetime
from core.utils import (
    run_cmd_output,
    get_device_id,
    get_hostname,
    get_ip_address
)


def run_command(cmd):
    try:
        result = run_cmd_output(cmd)
        return True, result
    except:
        return False, ""


def health_check(port=5000, ble_status="UNKNOWN"):
    report = []

    report.append("\n========== START HEALTH REPORT ==========")

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    report.append(f"Timestamp: {now}")

    report.append(f"Device ID: {get_device_id()}")
    report.append(f"Hostname: {get_hostname()}")
    report.append(f"IP Address: {get_ip_address()}")
    report.append(f"Port: {port}")

    bt_ok, bt_status = run_command("systemctl is-active bluetooth")
    report.append(f"Bluetooth Service: {'OK' if bt_ok and bt_status == 'active' else 'FAIL'}")

    wifi_ok, wifi_status = run_command("iwgetid")
    report.append(f"WiFi Connected: {'YES' if wifi_ok and wifi_status else 'NO'}")

    svc_ok, svc_status = run_command("systemctl is-active tinqa.service")
    report.append(f"TinQa Service: {'RUNNING' if svc_ok and svc_status == 'active' else 'FAIL'}")

    report.append(f"BLE Advertising: {ble_status}")

    overall = "PASS" if ("FAIL" not in "".join(report)) else "FAIL"
    report.append(f"\nFINAL STATUS: {overall}")

    report.append("========== END HEALTH REPORT ==========\n")

    return "\n".join(report)