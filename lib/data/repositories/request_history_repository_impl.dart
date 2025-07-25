import 'package:open_client_http/data/datasources/database_service.dart';
import 'package:open_client_http/domain/models/request_history.dart';
import 'package:open_client_http/domain/repositories/request_history_repository.dart';

class RequestHistoryRepositoryImpl implements RequestHistoryRepository {
  final DatabaseService _databaseService;

  RequestHistoryRepositoryImpl(this._databaseService);

  @override
  Future<int> insertRequestHistory(RequestHistory request) async {
    final map = request.toMap();
    map.remove('id'); // Remove id for insert
    
    _databaseService.execute(
      '''INSERT INTO request_history 
         (url, method, headers, body, response_status, response_body, response_headers, created_at, execution_time)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        map['url'],
        map['method'],
        map['headers'],
        map['body'],
        map['response_status'],
        map['response_body'],
        map['response_headers'],
        map['created_at'],
        map['execution_time'],
      ],
    );
    
    return _databaseService.getLastInsertId();
  }

  @override
  Future<List<RequestHistory>> getAllRequestHistory({int? limit, int? offset}) async {
    String sql = 'SELECT * FROM request_history ORDER BY created_at DESC';
    final parameters = <Object?>[];
    
    if (limit != null) {
      sql += ' LIMIT ?';
      parameters.add(limit);
      
      if (offset != null) {
        sql += ' OFFSET ?';
        parameters.add(offset);
      }
    }
    
    final result = _databaseService.query(sql, parameters);
    
    return result.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < row.length; i++) {
        map[result.columnNames[i]] = row[i];
      }
      return RequestHistory.fromMap(map);
    }).toList();
  }

  @override
  Future<RequestHistory?> getRequestHistoryById(int id) async {
    final result = _databaseService.query(
      'SELECT * FROM request_history WHERE id = ?',
      [id],
    );
    
    if (result.isEmpty) return null;
    
    final row = result.first;
    final map = <String, dynamic>{};
    for (int i = 0; i < row.length; i++) {
      map[result.columnNames[i]] = row[i];
    }
    
    return RequestHistory.fromMap(map);
  }

  @override
  Future<List<RequestHistory>> getRequestHistoryByMethod(String method) async {
    final result = _databaseService.query(
      'SELECT * FROM request_history WHERE method = ? ORDER BY created_at DESC',
      [method],
    );
    
    return result.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < row.length; i++) {
        map[result.columnNames[i]] = row[i];
      }
      return RequestHistory.fromMap(map);
    }).toList();
  }

  @override
  Future<List<RequestHistory>> searchRequestHistory(String query) async {
    final result = _databaseService.query(
      '''SELECT * FROM request_history 
         WHERE url LIKE ? OR method LIKE ? OR response_body LIKE ?
         ORDER BY created_at DESC''',
      ['%$query%', '%$query%', '%$query%'],
    );
    
    return result.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < row.length; i++) {
        map[result.columnNames[i]] = row[i];
      }
      return RequestHistory.fromMap(map);
    }).toList();
  }

  @override
  Future<int> deleteRequestHistory(int id) async {
    return _databaseService.execute(
      'DELETE FROM request_history WHERE id = ?',
      [id],
    );
  }

  @override
  Future<int> deleteOldRequestHistory(DateTime before) async {
    return _databaseService.execute(
      'DELETE FROM request_history WHERE created_at < ?',
      [before.millisecondsSinceEpoch],
    );
  }

  @override
  Future<int> clearAllRequestHistory() async {
    return _databaseService.execute('DELETE FROM request_history');
  }

  @override
  Future<int> getRequestHistoryCount() async {
    final result = _databaseService.query('SELECT COUNT(*) as count FROM request_history');
    if (result.isNotEmpty) {
      return result.first[0] as int;
    }
    return 0;
  }

  @override
  Future<List<RequestHistory>> getRecentRequests(int count) async {
    final result = _databaseService.query(
      'SELECT * FROM request_history ORDER BY created_at DESC LIMIT ?',
      [count],
    );
    
    return result.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < row.length; i++) {
        map[result.columnNames[i]] = row[i];
      }
      return RequestHistory.fromMap(map);
    }).toList();
  }
} 