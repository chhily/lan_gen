import 'package:flutter/cupertino.dart';

import '../app_dimensions.dart';

class AppSpace extends SizedBox {
  const AppSpace.x({super.key, this.x = AppDimensions.md, this.y})
      : super(width: x ?? AppDimensions.md);
  const AppSpace.y({super.key, this.x, this.y = AppDimensions.md})
      : super(height: y ?? AppDimensions.md);

  final double? x;
  final double? y;
}
