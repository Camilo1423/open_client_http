import 'package:open_client_http/domain/models/environment.dart';

abstract class EnvironmentRepository {
  /// Insert a new environment
  Future<int> insertEnvironment(Environment environment);

  /// Get all environments
  Future<List<Environment>> getAllEnvironments();

  /// Get environment by ID
  Future<Environment?> getEnvironmentById(int id);

  /// Get environment by name
  Future<Environment?> getEnvironmentByName(String name);

  /// Update an existing environment
  Future<int> updateEnvironment(Environment environment);

  /// Delete an environment by ID
  Future<int> deleteEnvironment(int id);

  /// Check if environment name exists
  Future<bool> environmentNameExists(String name, {int? excludeId});

  /// Get environment count
  Future<int> getEnvironmentCount();
} 