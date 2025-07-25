import 'package:open_client_http/data/datasources/database_service.dart';
import 'package:open_client_http/domain/models/environment_key.dart';
import 'package:open_client_http/domain/repositories/environment_key_repository.dart';

class EnvironmentKeyRepositoryImpl implements EnvironmentKeyRepository {
  final DatabaseService _databaseService;

  EnvironmentKeyRepositoryImpl(this._databaseService);

  @override
  Future<int> insertEnvironmentKey(EnvironmentKey environmentKey) async {
    final map = environmentKey.toMap();
    map.remove('id'); // Remove id for insert
    
    _databaseService.execute(
      '''INSERT INTO environment_keys (environment_id, key, value, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?)''',
      [
        map['environment_id'],
        map['key'],
        map['value'],
        map['created_at'],
        map['updated_at'],
      ],
    );
    
    return _databaseService.getLastInsertId();
  }

  @override
  Future<List<EnvironmentKey>> getEnvironmentKeysByEnvironmentId(int environmentId) async {
    final result = _databaseService.query(
      'SELECT * FROM environment_keys WHERE environment_id = ? ORDER BY created_at ASC',
      [environmentId],
    );
    
    return result.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < row.length; i++) {
        map[result.columnNames[i]] = row[i];
      }
      return EnvironmentKey.fromMap(map);
    }).toList();
  }

  @override
  Future<EnvironmentKey?> getEnvironmentKeyById(int id) async {
    final result = _databaseService.query(
      'SELECT * FROM environment_keys WHERE id = ?',
      [id],
    );
    
    if (result.isEmpty) return null;
    
    final row = result.first;
    final map = <String, dynamic>{};
    for (int i = 0; i < row.length; i++) {
      map[result.columnNames[i]] = row[i];
    }
    
    return EnvironmentKey.fromMap(map);
  }

  @override
  Future<int> updateEnvironmentKey(EnvironmentKey environmentKey) async {
    final map = environmentKey.toMap();
    
    return _databaseService.execute(
      '''UPDATE environment_keys 
         SET key = ?, value = ?, updated_at = ?
         WHERE id = ?''',
      [
        map['key'],
        map['value'],
        map['updated_at'],
        map['id'],
      ],
    );
  }

  @override
  Future<int> deleteEnvironmentKey(int id) async {
    return _databaseService.execute(
      'DELETE FROM environment_keys WHERE id = ?',
      [id],
    );
  }

  @override
  Future<int> deleteEnvironmentKeysByEnvironmentId(int environmentId) async {
    return _databaseService.execute(
      'DELETE FROM environment_keys WHERE environment_id = ?',
      [environmentId],
    );
  }

  @override
  Future<bool> keyNameExists(int environmentId, String key, {int? excludeId}) async {
    final result = excludeId != null
        ? _databaseService.query(
            'SELECT COUNT(*) as count FROM environment_keys WHERE environment_id = ? AND key = ? AND id != ?',
            [environmentId, key, excludeId],
          )
        : _databaseService.query(
            'SELECT COUNT(*) as count FROM environment_keys WHERE environment_id = ? AND key = ?',
            [environmentId, key],
          );
    
    if (result.isNotEmpty) {
      return result.first[0] as int > 0;
    }
    
    return false;
  }

  @override
  Future<int> getEnvironmentKeysCount(int environmentId) async {
    final result = _databaseService.query(
      'SELECT COUNT(*) as count FROM environment_keys WHERE environment_id = ?',
      [environmentId],
    );
    
    if (result.isNotEmpty) {
      return result.first[0] as int;
    }
    return 0;
  }
} 