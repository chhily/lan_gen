import 'package:lan_gen/services/exportor.dart';
import 'package:riverpod/riverpod.dart';

final exportModeProvider = StateProvider<ExportMode>(
  (ref) => ExportMode.overWrite,
);
