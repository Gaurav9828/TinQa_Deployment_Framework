import socket
import subprocess

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def get_wifi_interface():
    """Returns the name of the wireless interface, usually wlan0."""
    try:
        output = subprocess.check_output("iw dev | awk '$1==\"Interface\" {print $2}'", shell=True)
        return output.decode().strip()
    except:
        return "wlan0"

def get_signal_strength():
    """Returns the WiFi signal strength in dBm."""
    try:
        cmd = "nmcli -f IN-USE,SIGNAL device wifi | grep '*' | awk '{print $2}'"
        return subprocess.check_output(cmd, shell=True).decode().strip()
    except:
        return "N/A"