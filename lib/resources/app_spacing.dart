import 'package:flutter/widgets.dart';

class AppSpacing {
  static SizedBox horizontal({double size = 24}) => SizedBox(width: size);
  static SizedBox vertical({double size = 24}) => SizedBox(height: size);
  static SizedBox empty() => const SizedBox();
}
