import socket
import time
import json
import threading
import struct

PORT_DISCOVERY = 8887
PORT_CONTROL = 8888
PORT_TELEMETRY = 8889

# Global state
app_address = None

def discovery_listener():
    global app_address
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('', PORT_DISCOVERY))
    print(f"[Discovery] Listening on port {PORT_DISCOVERY}")
    
    while True:
        data, addr = sock.recvfrom(1024)
        print(f"[Discovery] Received from {addr}: {data.decode()}")
        
        # When we receive a ping, we set this as the target app address for telemetry
        app_address = addr[0]
        
        # Respond to discovery
        response = json.dumps({"id": "ESP_TEST_1", "name": "Mock Drone ESP32"})
        sock.sendto(response.encode(), addr)

def control_listener():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('', PORT_CONTROL))
    print(f"[Control] Listening for packets on port {PORT_CONTROL}")
    
    while True:
        data, addr = sock.recvfrom(1024)
        if len(data) == 8:
            header, j1x, j1y, j2x, j2y, btns, tgls, hsum = struct.unpack('BBBBBBBB', data)
            # Only print occasionally to not flood stdout
            if time.time() % 2.0 < 0.1:
                print(f"[Control] From {addr} -> J1({j1x},{j1y}) J2({j2x},{j2y}) Btns:{bin(btns)} Tgls:{bin(tgls)}")

def telemetry_sender():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    voltage = 12.0
    temp = 30.0
    
    print(f"[Telemetry] Sender ready. Waiting for discovery ping...")
    while True:
        if app_address:
            # Simulate slight fluctuations
            import random
            voltage = max(10.5, voltage - random.uniform(-0.1, 0.12))
            temp = max(20.0, min(80.0, temp + random.uniform(-0.5, 0.5)))
            
            payload = json.dumps({"v": round(voltage, 1), "t": round(temp, 1)})
            sock.sendto(payload.encode(), (app_address, PORT_TELEMETRY))
            
        time.sleep(0.5) # 2 Hz telemetry

if __name__ == '__main__':
    threading.Thread(target=discovery_listener, daemon=True).start()
    threading.Thread(target=control_listener, daemon=True).start()
    threading.Thread(target=telemetry_sender, daemon=True).start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Shutting down mock server.")
