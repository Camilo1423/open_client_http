import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeout_settings_provider.g.dart';

class TimeoutSettings {
  final int connectionTimeout;
  final int readTimeout;
  final int writeTimeout;

  const TimeoutSettings({
    required this.connectionTimeout,
    required this.readTimeout,
    required this.writeTimeout,
  });

  TimeoutSettings copyWith({
    int? connectionTimeout,
    int? readTimeout,
    int? writeTimeout,
  }) {
    return TimeoutSettings(
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      readTimeout: readTimeout ?? this.readTimeout,
      writeTimeout: writeTimeout ?? this.writeTimeout,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connectionTimeout': connectionTimeout,
      'readTimeout': readTimeout,
      'writeTimeout': writeTimeout,
    };
  }

  factory TimeoutSettings.fromJson(Map<String, dynamic> json) {
    return TimeoutSettings(
      connectionTimeout: json['connectionTimeout'] ?? 30,
      readTimeout: json['readTimeout'] ?? 30,
      writeTimeout: json['writeTimeout'] ?? 30,
    );
  }

  static const TimeoutSettings defaultSettings = TimeoutSettings(
    connectionTimeout: 30,
    readTimeout: 30,
    writeTimeout: 30,
  );
}

@riverpod
class TimeoutSettingsNotifier extends _$TimeoutSettingsNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<TimeoutSettings> build() async {
    final timeoutJson = await storage.read(key: 'timeout_settings');
    if (timeoutJson != null) {
      try {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          Uri.splitQueryString(timeoutJson),
        );
        // Convert string values to int
        json.updateAll((key, value) => int.tryParse(value.toString()) ?? 30);
        return TimeoutSettings.fromJson(json);
      } catch (e) {
        return TimeoutSettings.defaultSettings;
      }
    }
    return TimeoutSettings.defaultSettings;
  }

  Future<void> updateConnectionTimeout(int timeout) async {
    final current = state.value ?? TimeoutSettings.defaultSettings;
    final updated = current.copyWith(connectionTimeout: timeout);
    await _saveSettings(updated);
  }

  Future<void> updateReadTimeout(int timeout) async {
    final current = state.value ?? TimeoutSettings.defaultSettings;
    final updated = current.copyWith(readTimeout: timeout);
    await _saveSettings(updated);
  }

  Future<void> updateWriteTimeout(int timeout) async {
    final current = state.value ?? TimeoutSettings.defaultSettings;
    final updated = current.copyWith(writeTimeout: timeout);
    await _saveSettings(updated);
  }

  Future<void> _saveSettings(TimeoutSettings settings) async {
    final json = settings.toJson();
    final queryString = json.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    await storage.write(key: 'timeout_settings', value: queryString);
    state = AsyncValue.data(settings);
  }
} 