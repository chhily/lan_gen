import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/core/extensions/context_extensions.dart';

import '../../core/themes/app_text_theme.dart';
import '../../core/ui/app_colors.dart';
import '../../core/ui/app_dimensions.dart';
import '../../core/ui/app_space.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Localize generator")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _swapButton(title:  "Preview", isSelected: true),
                      AppSpace.x(),
                      _swapButton(title:  "Sheet"),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  Widget _swapButton ({required String title, bool isSelected = false}) {
    return Container(
      decoration: isSelected ? swapStyle() : null,
      padding: context.mediumGap,
      child: Text(title, style: appTextTheme.bodyLarge,),
    );
  }


  BoxDecoration swapStyle () {
    return BoxDecoration (
      borderRadius: BorderRadiusGeometry.circular(AppDimensions.radiusSm),
      color: AppColors.secondary
    );
  }
}
