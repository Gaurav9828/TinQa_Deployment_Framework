import serial
import serial.tools.list_ports
import time
import math

# --- CONFIG ---
BAUD = 921600
WIDTH = 32
HEIGHT = 16

def find_esp32_port():
    """Automatically finds the COM port for an ESP32 device."""
    ports = serial.tools.list_ports.comports()
    print("Scanning for devices...")
    for port in ports:
        # Check for common ESP32 USB-to-Serial bridge drivers
        description = port.description.lower()
        if "cp210" in description or "ch340" in description or "usb serial" in description:
            print(f"Found TinQa Hardware on {port.device} ({port.description})")
            return port.device
    return None

def send_frame(ser, frame_data):
    # Ensure the input buffer is empty before sending
    ser.reset_input_buffer()
    
    # Header: Start(255), Width, Height, End(255)
    ser.write(bytes([255, WIDTH, HEIGHT, 255]))
    ser.write(frame_data)
    
    # Wait for Acknowledgment 'K'
    # Reduced timeout for faster recovery
    start_wait = time.time()
    while True:
        if ser.in_waiting > 0:
            char = ser.read()
            if char == b'K':
                return True # Success
        if time.time() - start_wait > 0.1: 
            return False # Timeout

def generate_pattern(t):
    frame = bytearray()
    for y in range(HEIGHT):
        for x in range(WIDTH):
            # Dynamic wave pattern
            r = int(127 + 127 * math.sin(x * 0.3 + t))
            g = 0
            b = int(127 + 127 * math.cos(y * 0.3 + t))
            frame.extend([r, g, b])
    return frame

# --- MAIN EXECUTION ---
target_port = find_esp32_port()

if not target_port:
    print("Error: ESP32 not found. Check your USB connection and drivers.")
else:
    try:
        ser = serial.Serial(target_port, BAUD, timeout=0.1)
        time.sleep(2) # Wait for ESP32 reset
        print(f"Streaming started on {target_port}...")
        
        start_time = time.time()
        while True:
            t = time.time() - start_time
            frame = generate_pattern(t)
            send_frame(ser, frame)
            
    except serial.SerialException as e:
        print(f"Failed to connect: {e}")
    except KeyboardInterrupt:
        print("\nStopping stream...")
        ser.close()