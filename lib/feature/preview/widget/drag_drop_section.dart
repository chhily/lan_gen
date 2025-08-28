import 'dart:io';

import 'package:flutter/material.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_provider.dart';
import 'package:path/path.dart' as p;

import '../../../shared/app_colors.dart';
import '../../../shared/app_dimensions.dart';

class DragDropSection extends ConsumerStatefulWidget {
  const DragDropSection({super.key});

  @override
  ConsumerState createState() => _DragDropSectionState();
}

class _DragDropSectionState extends ConsumerState<DragDropSection> {
  bool _dragging = false;

  Future<void> _handleFileDrop(List<dynamic> files) async {
    if (files.isEmpty) return;

    final file = File(files.first.path);
    if (file.path.endsWith(".xlsx") || file.path.endsWith(".xls")) {
      final fileName = p.basename(file.path);
      ref.read(translationProvider.notifier).getSheetData(file.path, fileName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only Excel files (.xlsx / .xls) allowed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (detail) => _handleFileDrop(detail.files),
      child: GestureDetector(
        onTap: () {
          ref.read(translationProvider.notifier).onImportSheet();
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            border: Border.all(
              color: _dragging ? AppColors.success : AppColors.border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            color: _dragging
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.secondary,
          ),
          child: Center(child: Text("IMPORT OR DRAG FILE HERE")),
        ),
      ),
    );
  }
}
