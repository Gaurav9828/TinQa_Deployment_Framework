import subprocess
import socket

def get_device_id():
    try:
        with open("/proc/cpuinfo", "r") as file:
            for line in file:
                if line.startswith("Serial"):
                    return f"TinQa-{line.strip().split(': ')[1][-8:]}"
    except Exception:
        return "TinQa-UNKNOWN"

def get_ip_address():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "N/A"

def run_cmd_output(cmd):
    try:
        return subprocess.check_output(cmd, shell=True).decode().strip()
    except Exception:
        return ""