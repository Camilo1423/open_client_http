import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/data/datasources/database_service.dart';
import 'package:open_client_http/data/repositories/environment_repository_impl.dart';
import 'package:open_client_http/domain/models/environment.dart';
import 'package:open_client_http/domain/repositories/environment_repository.dart';

// Provider for environments repository
final environmentRepositoryProvider = Provider<EnvironmentRepository>((ref) {
  return EnvironmentRepositoryImpl(DatabaseService());
});

// Provider for environments list
final environmentsProvider = AsyncNotifierProvider<EnvironmentsNotifier, List<Environment>>(() {
  return EnvironmentsNotifier();
});

class EnvironmentsNotifier extends AsyncNotifier<List<Environment>> {
  @override
  Future<List<Environment>> build() async {
    return await _loadEnvironments();
  }

  Future<List<Environment>> _loadEnvironments() async {
    final repository = ref.read(environmentRepositoryProvider);
    return await repository.getAllEnvironments();
  }

  /// Create a new environment
  Future<void> createEnvironment(String name, String description) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(environmentRepositoryProvider);
      
      // Check if name already exists
      final exists = await repository.environmentNameExists(name);
      if (exists) {
        throw Exception('An environment with that name already exists');
      }
      
      final now = DateTime.now();
      final environment = Environment(
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
      );
      
              await repository.insertEnvironment(environment);
        
        // Reload the list
        final environments = await _loadEnvironments();
        state = AsyncValue.data(environments);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update an environment
  Future<void> updateEnvironment(Environment environment) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(environmentRepositoryProvider);
      
      // Check if name already exists (excluding current one)
      final exists = await repository.environmentNameExists(
        environment.name, 
        excludeId: environment.id,
      );
      if (exists) {
        throw Exception('An environment with that name already exists');
      }
      
      final updatedEnvironment = environment.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await repository.updateEnvironment(updatedEnvironment);
      
      // Reload the list
      final environments = await _loadEnvironments();
      state = AsyncValue.data(environments);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete an environment
  Future<void> deleteEnvironment(int id) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(environmentRepositoryProvider);
      await repository.deleteEnvironment(id);
      
      // Reload the list
      final environments = await _loadEnvironments();
      state = AsyncValue.data(environments);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh the environments list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final environments = await _loadEnvironments();
      state = AsyncValue.data(environments);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 