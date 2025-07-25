import 'package:open_client_http/domain/models/environment_key.dart';

abstract class EnvironmentKeyRepository {
  /// Insert a new environment key
  Future<int> insertEnvironmentKey(EnvironmentKey environmentKey);

  /// Get all environment keys for a specific environment
  Future<List<EnvironmentKey>> getEnvironmentKeysByEnvironmentId(int environmentId);

  /// Get environment key by ID
  Future<EnvironmentKey?> getEnvironmentKeyById(int id);

  /// Update an existing environment key
  Future<int> updateEnvironmentKey(EnvironmentKey environmentKey);

  /// Delete an environment key by ID
  Future<int> deleteEnvironmentKey(int id);

  /// Delete all environment keys for a specific environment
  Future<int> deleteEnvironmentKeysByEnvironmentId(int environmentId);

  /// Check if key name exists for the environment
  Future<bool> keyNameExists(int environmentId, String key, {int? excludeId});

  /// Get environment keys count for a specific environment
  Future<int> getEnvironmentKeysCount(int environmentId);
} 