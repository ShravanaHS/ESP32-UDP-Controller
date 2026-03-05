import 'package:flutter/foundation.dart';
import 'control_state.dart';

class ControlProvider extends ChangeNotifier {
  ControlState _state = ControlState();

  ControlState get state => _state;

  ControlProvider();

  void updateJoystick1(int x, int y, double nx, double ny) {
    _state = _state.copyWith(
      joystick1X: x, 
      joystick1Y: y,
      joystick1XNorm: nx,
      joystick1YNorm: ny,
    );
    notifyListeners();
  }

  void updateJoystick2(int x, int y, double nx, double ny) {
    _state = _state.copyWith(
      joystick2X: x, 
      joystick2Y: y,
      joystick2XNorm: nx,
      joystick2YNorm: ny,
    );
    notifyListeners();
  }

  void updateButton(int index, bool isPressed) {
    if (index >= 0 && index < _state.buttonStates.length) {
      final newButtons = List<bool>.from(_state.buttonStates);
      newButtons[index] = isPressed;
      _state = _state.copyWith(buttonStates: newButtons);
      notifyListeners();
    }
  }

  void updateToggle(int index, bool isOn) {
    if (index >= 0 && index < _state.toggleStates.length) {
      final newToggles = List<bool>.from(_state.toggleStates);
      newToggles[index] = isOn;
      _state = _state.copyWith(toggleStates: newToggles);
      notifyListeners();
    }
  }
}

