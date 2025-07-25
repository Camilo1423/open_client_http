import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/data/datasources/database_service.dart';
import 'package:open_client_http/data/repositories/environment_key_repository_impl.dart';
import 'package:open_client_http/domain/models/environment_key.dart';
import 'package:open_client_http/domain/repositories/environment_key_repository.dart';

// Provider for environment key repository
final environmentKeyRepositoryProvider = Provider<EnvironmentKeyRepository>((ref) {
  return EnvironmentKeyRepositoryImpl(DatabaseService());
});

// Provider for environment keys list by environment ID
final environmentKeysProvider = AsyncNotifierProvider.family<EnvironmentKeysNotifier, List<EnvironmentKey>, int>(() {
  return EnvironmentKeysNotifier();
});

class EnvironmentKeysNotifier extends FamilyAsyncNotifier<List<EnvironmentKey>, int> {
  @override
  Future<List<EnvironmentKey>> build(int environmentId) async {
    return await _loadEnvironmentKeys(environmentId);
  }

  Future<List<EnvironmentKey>> _loadEnvironmentKeys(int environmentId) async {
    final repository = ref.read(environmentKeyRepositoryProvider);
    return await repository.getEnvironmentKeysByEnvironmentId(environmentId);
  }

  /// Create a new environment key
  Future<void> createEnvironmentKey(String key, String value) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(environmentKeyRepositoryProvider);
      final environmentId = arg;
      
      // Check if key already exists
      final exists = await repository.keyNameExists(environmentId, key);
      if (exists) {
        throw Exception('A key with that name already exists in this environment');
      }
      
      final now = DateTime.now();
      final environmentKey = EnvironmentKey(
        environmentId: environmentId,
        key: key,
        value: value,
        createdAt: now,
        updatedAt: now,
      );
      
      await repository.insertEnvironmentKey(environmentKey);
      
      // Reload the list
      final environmentKeys = await _loadEnvironmentKeys(environmentId);
      state = AsyncValue.data(environmentKeys);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update an environment key
  Future<void> updateEnvironmentKey(EnvironmentKey environmentKey) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(environmentKeyRepositoryProvider);
      
      // Check if key name already exists (excluding current one)
      final exists = await repository.keyNameExists(
        environmentKey.environmentId,
        environmentKey.key,
        excludeId: environmentKey.id,
      );
      if (exists) {
        throw Exception('A key with that name already exists in this environment');
      }
      
      final updatedEnvironmentKey = environmentKey.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await repository.updateEnvironmentKey(updatedEnvironmentKey);
      
      // Reload the list
      final environmentKeys = await _loadEnvironmentKeys(environmentKey.environmentId);
      state = AsyncValue.data(environmentKeys);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete an environment key
  Future<void> deleteEnvironmentKey(EnvironmentKey environmentKey) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(environmentKeyRepositoryProvider);
      await repository.deleteEnvironmentKey(environmentKey.id!);
      
      // Reload the list
      final environmentKeys = await _loadEnvironmentKeys(environmentKey.environmentId);
      state = AsyncValue.data(environmentKeys);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh the environment keys list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final environmentKeys = await _loadEnvironmentKeys(arg);
      state = AsyncValue.data(environmentKeys);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 