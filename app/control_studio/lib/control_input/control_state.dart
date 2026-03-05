class ControlState {
  // Joystick values: 0-255 (128 is neutral)
  int joystick1X;
  int joystick1Y;
  int joystick2X;
  int joystick2Y;

  // Normalized joystick positions for Satellite Plot (-1.0 to 1.0)
  double joystick1XNorm;
  double joystick1YNorm;
  double joystick2XNorm;
  double joystick2YNorm;

  // Buttons and toggles
  List<bool> buttonStates;
  List<bool> toggleStates;

  ControlState({
    this.joystick1X = 128,
    this.joystick1Y = 128,
    this.joystick2X = 128,
    this.joystick2Y = 128,
    this.joystick1XNorm = 0.0,
    this.joystick1YNorm = 0.0,
    this.joystick2XNorm = 0.0,
    this.joystick2YNorm = 0.0,
    List<bool>? buttonStates,
    List<bool>? toggleStates,
  })  : buttonStates = buttonStates ?? List.generate(8, (_) => false),
        toggleStates = toggleStates ?? List.generate(4, (_) => false);

  ControlState copyWith({
    int? joystick1X,
    int? joystick1Y,
    int? joystick2X,
    int? joystick2Y,
    double? joystick1XNorm,
    double? joystick1YNorm,
    double? joystick2XNorm,
    double? joystick2YNorm,
    List<bool>? buttonStates,
    List<bool>? toggleStates,
  }) {
    return ControlState(
      joystick1X: joystick1X ?? this.joystick1X,
      joystick1Y: joystick1Y ?? this.joystick1Y,
      joystick2X: joystick2X ?? this.joystick2X,
      joystick2Y: joystick2Y ?? this.joystick2Y,
      joystick1XNorm: joystick1XNorm ?? this.joystick1XNorm,
      joystick1YNorm: joystick1YNorm ?? this.joystick1YNorm,
      joystick2XNorm: joystick2XNorm ?? this.joystick2XNorm,
      joystick2YNorm: joystick2YNorm ?? this.joystick2YNorm,
      buttonStates: buttonStates ?? List<bool>.from(this.buttonStates),
      toggleStates: toggleStates ?? List<bool>.from(this.toggleStates),
    );
  }
}
