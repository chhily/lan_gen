import 'package:lan_gen/models/duplicate_record.dart';
import 'package:lan_gen/core/services/exportor.dart';
import 'package:riverpod/riverpod.dart';


class DuplicateNotifier extends StateNotifier<List<DuplicateRecord>> {
  DuplicateNotifier() : super([]);

  void clear() => state = [];
  void add(DuplicateRecord record) => state = [...state, record];
}

final duplicateProvider =
    StateNotifierProvider<DuplicateNotifier, List<DuplicateRecord>>(
      (ref) => DuplicateNotifier(),
    );

/// Immutable config state
class AppConfigState {
  final bool useCamelCase;
  final ExportMode exportMode;

  const AppConfigState({
    this.useCamelCase = false,
    this.exportMode = ExportMode.overWrite,
  });

  AppConfigState copyWith({bool? useCamelCase, ExportMode? exportMode}) {
    return AppConfigState(
      useCamelCase: useCamelCase ?? this.useCamelCase,
      exportMode: exportMode ?? this.exportMode,
    );
  }
}

/// StateNotifier for updating config
class AppConfigNotifier extends StateNotifier<AppConfigState> {
  AppConfigNotifier() : super(const AppConfigState());

  void toggleCamelCase() {
    state = state.copyWith(useCamelCase: !state.useCamelCase);
  }

  void setExportMode(ExportMode mode) {
    state = state.copyWith(exportMode: mode);
  }
}

/// Provider
final appConfigProvider =
    StateNotifierProvider<AppConfigNotifier, AppConfigState>(
      (ref) => AppConfigNotifier(),
    );
