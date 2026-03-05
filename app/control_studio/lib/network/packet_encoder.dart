import '../control_input/control_state.dart';
import 'dart:typed_data';

class PacketEncoder {
  static const int packetSize = 8;
  static const int headerByte = 0xAA; // Arbitrary header

  static Uint8List encode(ControlState state) {
    final buffer = Uint8List(packetSize);

    // Byte 0: Header
    buffer[0] = headerByte;

    // Byte 1-4: Joysticks (0-255)
    buffer[1] = state.joystick1X;
    buffer[2] = state.joystick1Y;
    buffer[3] = state.joystick2X;
    buffer[4] = state.joystick2Y;

    // Byte 5: Buttons (Bitmask)
    int buttonsByte = 0;
    for (int i = 0; i < 8; i++) {
      if (state.buttonStates.length > i && state.buttonStates[i]) {
        buttonsByte |= (1 << i);
      }
    }
    buffer[5] = buttonsByte;

    // Byte 6: Toggles (Bitmask)
    int togglesByte = 0;
    for (int i = 0; i < 4; i++) {
      if (state.toggleStates.length > i && state.toggleStates[i]) {
        togglesByte |= (1 << i);
      }
    }
    buffer[6] = togglesByte;

    // Byte 7: Checksum (XOR of bytes 0-6)
    int checksum = 0;
    for (int i = 0; i < 7; i++) {
      checksum ^= buffer[i];
    }
    buffer[7] = checksum;

    return buffer;
  }
}
