import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/domain/models/environment.dart';
import 'package:open_client_http/domain/models/environment_key.dart';
import 'package:open_client_http/presentation/provider/environment/environment_key_provider.dart';

// Provider for the currently selected environment
final selectedEnvironmentProvider = StateProvider<Environment?>((ref) => null);

// Provider that automatically loads keys when environment changes
final selectedEnvironmentKeysProvider = FutureProvider<List<EnvironmentKey>>((ref) async {
  final selectedEnvironment = ref.watch(selectedEnvironmentProvider);
  
  if (selectedEnvironment == null) {
    return [];
  }
  
  // Get the keys for the selected environment
  final repository = ref.read(environmentKeyRepositoryProvider);
  return await repository.getEnvironmentKeysByEnvironmentId(selectedEnvironment.id!);
});

// Provider to get a specific key value by key name from selected environment
final getEnvironmentKeyValueProvider = Provider.family<String?, String>((ref, keyName) {
  final keysAsync = ref.watch(selectedEnvironmentKeysProvider);
  
  return keysAsync.when(
    data: (keys) {
      final key = keys.where((k) => k.key == keyName).firstOrNull;
      return key?.value;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider to get all key-value pairs as a Map for easy access
final selectedEnvironmentKeysMapProvider = Provider<Map<String, String>>((ref) {
  final keysAsync = ref.watch(selectedEnvironmentKeysProvider);
  
  return keysAsync.when(
    data: (keys) {
      final Map<String, String> keyMap = {};
      for (final key in keys) {
        keyMap[key.key] = key.value;
      }
      return keyMap;
    },
    loading: () => {},
    error: (_, __) => {},
  );
}); 