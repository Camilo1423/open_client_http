import 'package:open_client_http/data/datasources/database_service.dart';
import 'package:open_client_http/domain/models/environment.dart';
import 'package:open_client_http/domain/repositories/environment_repository.dart';

class EnvironmentRepositoryImpl implements EnvironmentRepository {
  final DatabaseService _databaseService;

  EnvironmentRepositoryImpl(this._databaseService);

  @override
  Future<int> insertEnvironment(Environment environment) async {
    final map = environment.toMap();
    map.remove('id'); // Remove id for insert
    
    _databaseService.execute(
      '''INSERT INTO environments (name, description, created_at, updated_at)
         VALUES (?, ?, ?, ?)''',
      [
        map['name'],
        map['description'],
        map['created_at'],
        map['updated_at'],
      ],
    );
    
    return _databaseService.getLastInsertId();
  }

  @override
  Future<List<Environment>> getAllEnvironments() async {
    final result = _databaseService.query(
      'SELECT * FROM environments ORDER BY created_at DESC',
    );
    
    return result.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < row.length; i++) {
        map[result.columnNames[i]] = row[i];
      }
      return Environment.fromMap(map);
    }).toList();
  }

  @override
  Future<Environment?> getEnvironmentById(int id) async {
    final result = _databaseService.query(
      'SELECT * FROM environments WHERE id = ?',
      [id],
    );
    
    if (result.isEmpty) return null;
    
    final row = result.first;
    final map = <String, dynamic>{};
    for (int i = 0; i < row.length; i++) {
      map[result.columnNames[i]] = row[i];
    }
    
    return Environment.fromMap(map);
  }

  @override
  Future<Environment?> getEnvironmentByName(String name) async {
    final result = _databaseService.query(
      'SELECT * FROM environments WHERE name = ?',
      [name],
    );
    
    if (result.isEmpty) return null;
    
    final row = result.first;
    final map = <String, dynamic>{};
    for (int i = 0; i < row.length; i++) {
      map[result.columnNames[i]] = row[i];
    }
    
    return Environment.fromMap(map);
  }

  @override
  Future<int> updateEnvironment(Environment environment) async {
    final map = environment.toMap();
    
    return _databaseService.execute(
      '''UPDATE environments 
         SET name = ?, description = ?, updated_at = ?
         WHERE id = ?''',
      [
        map['name'],
        map['description'],
        map['updated_at'],
        map['id'],
      ],
    );
  }

  @override
  Future<int> deleteEnvironment(int id) async {
    return _databaseService.execute(
      'DELETE FROM environments WHERE id = ?',
      [id],
    );
  }

  @override
  Future<bool> environmentNameExists(String name, {int? excludeId}) async {
    final result = excludeId != null
        ? _databaseService.query(
            'SELECT COUNT(*) as count FROM environments WHERE name = ? AND id != ?',
            [name, excludeId],
          )
        : _databaseService.query(
            'SELECT COUNT(*) as count FROM environments WHERE name = ?',
            [name],
          );
    
    if (result.isNotEmpty) {
      return result.first[0] as int > 0;
    }
    
    return false;
  }

  @override
  Future<int> getEnvironmentCount() async {
    final result = _databaseService.query('SELECT COUNT(*) as count FROM environments');
    if (result.isNotEmpty) {
      return result.first[0] as int;
    }
    return 0;
  }
} 