import 'package:flutter_test/flutter_test.dart';
import 'package:control_studio/control_input/control_state.dart';
import 'package:control_studio/network/packet_encoder.dart';

void main() {
  test('PacketEncoder generates correct 8-byte UDP payload', () {
    // 1. Arrange: Create a specific control state
    final state = ControlState(
      joystick1X: 255, // Max Right
      joystick1Y: 0,   // Max Down (or Up depending on map)
      joystick2X: 128, // Neutral
      joystick2Y: 128, // Neutral
    );
    
    // Set some buttons (Button 0 and Button 7 ON)
    state.buttonStates[0] = true;
    state.buttonStates[7] = true;
    
    // Set some toggles (Toggle 1 and 2 ON)
    state.toggleStates[1] = true;
    state.toggleStates[2] = true;

    // 2. Act: Encode
    final packet = PacketEncoder.encode(state);

    // 3. Assert: Packet structure
    expect(packet.length, 8);
    expect(packet[0], 0xAA); // Header
    expect(packet[1], 255);  // J1X
    expect(packet[2], 0);    // J1Y
    expect(packet[3], 128);  // J2X
    expect(packet[4], 128);  // J2Y
    
    // Button Bitmask: 10000001 binary = 129 decimal
    expect(packet[5], 129);  
    
    // Toggle Bitmask: 00000110 binary = 6 decimal
    expect(packet[6], 6);

    // Checksum: 0xAA ^ 255 ^ 0 ^ 128 ^ 128 ^ 129 ^ 6 = 224
    int expectedChecksum = 0xAA ^ 255 ^ 0 ^ 128 ^ 128 ^ 129 ^ 6;
    expect(packet[7], expectedChecksum);
  });
}
