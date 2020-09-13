import 'package:flutter/widgets.dart';

class SpeedDialChild {
  const SpeedDialChild({
    this.child,
    this.label,
    this.onPressed,
    this.closeSpeedDialOnPressed = true,
    this.backgroundGradient,
    this.labelBackgroundColor,
    this.labelBackgroundGradient,
  });

  final Widget child;
  final String label;
  final Function onPressed;
  final bool closeSpeedDialOnPressed;
  final Gradient backgroundGradient;
  final Color labelBackgroundColor;
  final Gradient labelBackgroundGradient;
}
