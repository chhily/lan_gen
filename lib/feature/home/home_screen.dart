import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/feature/history/history_screen.dart';
import 'package:lan_gen/feature/home/widget/action_modal.dart';
import 'package:lan_gen/feature/home/widget/export_mode_widget.dart';
import 'package:lan_gen/feature/home/widget/generate_modal.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';

import '../../shared/provider/translate_provider/translation_provider.dart';
import '../../shared/widget/app_space.dart';
import '../preview/translation_preview.dart';
import 'widget/duplicate_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void onShowHistoryModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Padding(padding: EdgeInsets.all(80), child: HistoryScreen());
      },
    );
  }

  void onShowGenerateModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Padding(padding: EdgeInsets.all(120), child: GenerateModal());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final notifier = ref.read(translationProvider.notifier);
          if (notifier.validateData()) {
            ref.read(translationProvider.notifier).onExportAndGenerate();
          } else {
            onShowGenerateModal();
          }
        },
        icon: const Icon(Icons.autorenew_rounded),
        label: const Text("GENERATE"),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: DuplicateModal(duplicateRecord: ref.watch(duplicateProvider)),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Aoi.dev"),
        leading: SizedBox(),
        leadingWidth: 0,
        actions: [
          ActionModal(
            onOpenHistory: () {
              // show history dialog
              onShowHistoryModal();
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          // ExportModeModal
          ExportModeWidget(
            onTap: () {
              onShowGenerateModal();
            },
          ),
          AppSpace.y(y: 32),
          // TranslationPreview
          Builder(
            builder: (context) {
              return Center(
                child: TranslationPreview(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  duplicates: ref.watch(duplicateProvider).length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
