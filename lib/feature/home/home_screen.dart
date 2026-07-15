import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lan_gen/feature/history/history_screen.dart';
import 'package:lan_gen/feature/home/widget/action_modal.dart';
import 'package:lan_gen/feature/home/widget/export_mode_widget.dart';
import 'package:lan_gen/feature/home/widget/generate_modal.dart';
import 'package:lan_gen/feature/preview/sheet_preview.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';
import 'package:lan_gen/shared/provider/missing_key.dart';
import 'package:lan_gen/shared/widget/app_loading.dart';

import '../../shared/app_colors.dart';
import '../../shared/provider/sheet_provider/sheet_provider.dart';
import '../../shared/provider/translate_provider/translation_provider.dart';
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     final notifier = ref.read(translationProvider.notifier);
      //     if (notifier.validateData()) {
      //       ref.read(translationProvider.notifier).onExportAndGenerate();
      //     } else {
      //       onShowGenerateModal();
      //     }
      //   },
      //   icon: const Icon(Icons.autorenew_rounded),
      //   label: const Text("GENERATE"),
      // ),


      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.autorenew_rounded),
            label: 'GENERATE',
            onTap: () {
              final notifier = ref.read(translationProvider.notifier);
              if (notifier.validateData()) {
                ref.read(translationProvider.notifier).onExportAndGenerate();
              } else {
                onShowGenerateModal();
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_download),
            label: 'Sample Template',
            onTap: () {
              ref.read(translationProvider.notifier).onDownloadTemplate();
            },
          ),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: DuplicateModal(duplicateRecord: ref.watch(duplicateProvider)),
      ),
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Aoi.dev"),
        leading: const SizedBox(),
        leadingWidth: 0,
        actions: [
          ActionModal(
            onOpenHistory: () {
              onShowHistoryModal();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ExportModeWidget(
                    onTap: () async {
                      AppLoading.show(context);
                      await ref
                          .read(suggestedTranslationProvider.notifier)
                          .setSuggestion(
                            ref.read(translationProvider).translations,
                          );
                      if (context.mounted) {
                        AppLoading.close(context);
                      }
                    },
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    indicatorColor: AppColors.tertiary,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      Tab(text: "Preview"),
                      Tab(text: "Sheet"),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                Builder(
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: TranslationPreview(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        duplicates: ref.watch(duplicateProvider).length,
                      ),
                    );
                  },
                ),
                SheetPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
