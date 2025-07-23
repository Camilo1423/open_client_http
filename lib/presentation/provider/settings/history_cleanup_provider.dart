import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_cleanup_provider.g.dart';

enum HistoryCleanupOption {
  never('never', 'Never'),
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly');

  const HistoryCleanupOption(this.value, this.displayName);
  final String value;
  final String displayName;

  static HistoryCleanupOption fromString(String value) {
    return HistoryCleanupOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => HistoryCleanupOption.never,
    );
  }
}

@riverpod
class HistoryCleanup extends _$HistoryCleanup {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<HistoryCleanupOption> build() async {
    final cleanupValue = await storage.read(key: 'history_cleanup');
    return HistoryCleanupOption.fromString(cleanupValue ?? 'never');
  }

  Future<void> setCleanupOption(HistoryCleanupOption option) async {
    await storage.write(key: 'history_cleanup', value: option.value);
    state = AsyncValue.data(option);
  }
} 