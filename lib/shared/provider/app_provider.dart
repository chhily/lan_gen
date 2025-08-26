import 'package:lan_gen/models/duplicate_record.dart';
import 'package:lan_gen/core/services/exportor.dart';
import 'package:riverpod/riverpod.dart';

final exportModeProvider = StateProvider<ExportMode>(
  (ref) => ExportMode.overWrite,
);

class DuplicateNotifier extends StateNotifier<List<DuplicateRecord>> {
  DuplicateNotifier() : super([]);

  void clear() => state = [];
  void add(DuplicateRecord record) => state = [...state, record];
}

final duplicateProvider =
    StateNotifierProvider<DuplicateNotifier, List<DuplicateRecord>>(
      (ref) => DuplicateNotifier(),
    );
