import 'package:flutter/widgets.dart';

extension WidgetExtensions on Widget {
  Widget get toSliver {
    return SliverToBoxAdapter(
      child: this,
    );
  }
}
