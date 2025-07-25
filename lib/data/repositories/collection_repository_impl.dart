import 'dart:convert';
import 'package:open_client_http/data/datasources/database_service.dart';
import 'package:open_client_http/domain/models/collection_item.dart';
import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/domain/models/saved_request.dart';
import 'package:open_client_http/domain/models/url_parameter.dart';
import 'package:open_client_http/domain/repositories/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final DatabaseService _databaseService;

  CollectionRepositoryImpl(this._databaseService);

  @override
  Future<List<CollectionItem>> getItemsInPath(String path) async {
    final normalizedPath = normalizePath(path);
    
    final result = _databaseService.query('''
      SELECT id, path, name, type, parent_path, created_at, updated_at
      FROM collections
      WHERE parent_path = ?
      ORDER BY type ASC, name ASC
    ''', [normalizedPath]);

    return result.map((row) => _mapRowToCollectionItem(row)).toList();
  }

  @override
  Future<CollectionItem?> getItemByPath(String path) async {
    final normalizedPath = normalizePath(path);
    
    final result = _databaseService.query('''
      SELECT id, path, name, type, parent_path, created_at, updated_at
      FROM collections
      WHERE path = ?
    ''', [normalizedPath]);

    if (result.isEmpty) return null;
    return _mapRowToCollectionItem(result.first);
  }

  @override
  Future<CollectionItem> createFolder(String path, String name) async {
    final normalizedPath = normalizePath(path);
    final fullPath = normalizePath('$normalizedPath/$name');
    final parentPath = getParentPath(fullPath);
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Si estamos creando en la raíz, no necesitamos parent_path
    final actualParentPath = parentPath == '/' ? "/" : parentPath;
    
    _databaseService.execute('''
      INSERT INTO collections (path, name, type, parent_path, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [fullPath, name, 'folder', actualParentPath, now, now]);

    return CollectionItem(
      id: _databaseService.getLastInsertId(),
      path: fullPath,
      name: name,
      type: CollectionItemType.folder,
      parentPath: actualParentPath,
      createdAt: DateTime.fromMillisecondsSinceEpoch(now),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
  }

  @override
  Future<SavedRequest> createFile(String path, String name, SavedRequest request) async {
    final normalizedPath = normalizePath(path);
    final fullPath = normalizePath('$normalizedPath/$name');
    final parentPath = getParentPath(fullPath);
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Create the collection item as a file (not folder)
    final actualParentPath = parentPath == '/' ? "/" : parentPath;
    
    _databaseService.execute('''
      INSERT INTO collections (path, name, type, parent_path, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [fullPath, name, 'file', actualParentPath, now, now]);
    
    // Then create the saved request
    
    _databaseService.execute('''
      INSERT INTO saved_requests (
        collection_path, name, method, base_url, url, query_params, 
        headers, auth_method, auth_token, auth_username, auth_password, 
        raw_body, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      normalizedPath,
      name,
      request.request.method,
      request.request.baseUrl,
      request.request.url,
      jsonEncode(request.request.queryParams.map((p) => {'key': p.key, 'value': p.value}).toList()),
      jsonEncode(request.request.headers),
      request.request.authMethod.name,
      request.request.authToken,
      request.request.authUsername,
      request.request.authPassword,
      request.request.rawBody,
      now,
      now,
    ]);

    return request.copyWith(
      id: _databaseService.getLastInsertId(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(now),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
  }

  @override
  Future<SavedRequest> updateFile(String path, String name, SavedRequest request) async {
    final normalizedPath = normalizePath(path);
    final now = DateTime.now().millisecondsSinceEpoch;
    
    _databaseService.execute('''
      UPDATE saved_requests SET
        method = ?, base_url = ?, url = ?, query_params = ?, 
        headers = ?, auth_method = ?, auth_token = ?, auth_username = ?, 
        auth_password = ?, raw_body = ?, updated_at = ?
      WHERE collection_path = ? AND name = ?
    ''', [
      request.request.method,
      request.request.baseUrl,
      request.request.url,
      jsonEncode(request.request.queryParams.map((p) => {'key': p.key, 'value': p.value}).toList()),
      jsonEncode(request.request.headers),
      request.request.authMethod.name,
      request.request.authToken,
      request.request.authUsername,
      request.request.authPassword,
      request.request.rawBody,
      now,
      normalizedPath,
      name,
    ]);

    return request.copyWith(
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
  }

  @override
  Future<bool> deleteItem(String path) async {
    final normalizedPath = normalizePath(path);
    
    // Delete from collections table (this will cascade to saved_requests)
    final changes = _databaseService.execute('''
      DELETE FROM collections WHERE path = ?
    ''', [normalizedPath]);
    
    return changes > 0;
  }

  @override
  Future<SavedRequest?> getSavedRequest(String path, String name) async {
    final normalizedPath = normalizePath(path);
    
    final result = _databaseService.query('''
      SELECT id, collection_path, name, method, base_url, url, query_params,
             headers, auth_method, auth_token, auth_username, auth_password,
             raw_body, created_at, updated_at
      FROM saved_requests
      WHERE collection_path = ? AND name = ?
    ''', [normalizedPath, name]);

    if (result.isEmpty) return null;
    return _mapRowToSavedRequest(result.first);
  }

  @override
  Future<SavedRequest?> getSavedRequestById(String id) async {
    final result = _databaseService.query('''
      SELECT id, collection_path, name, method, base_url, url, query_params,
             headers, auth_method, auth_token, auth_username, auth_password,
             raw_body, created_at, updated_at
      FROM saved_requests
      WHERE id = ?
    ''', [id]);

    if (result.isEmpty) return null;
    return _mapRowToSavedRequest(result.first);
  }
  

  @override
  Future<List<SavedRequest>> getSavedRequestsInPath(String path) async {
    final normalizedPath = normalizePath(path);
    
    final result = _databaseService.query('''
      SELECT id, collection_path, name, method, base_url, url, query_params,
             headers, auth_method, auth_token, auth_username, auth_password,
             raw_body, created_at, updated_at
      FROM saved_requests
      WHERE collection_path = ?
      ORDER BY name ASC
    ''', [normalizedPath]);

    return result.map((row) => _mapRowToSavedRequest(row)).toList();
  }

  @override
  Future<List<CollectionItem>> searchItems(String query) async {
    final searchQuery = '%$query%';
    
    final result = _databaseService.query('''
      SELECT id, path, name, type, parent_path, created_at, updated_at
      FROM collections
      WHERE name LIKE ?
      ORDER BY type ASC, name ASC
    ''', [searchQuery]);

    return result.map((row) => _mapRowToCollectionItem(row)).toList();
  }

  @override
  Future<List<CollectionItem>> getBreadcrumb(String path) async {
    final normalizedPath = normalizePath(path);
    final breadcrumb = <CollectionItem>[];
    
    if (normalizedPath == '/') {
      return breadcrumb;
    }
    
    final parts = normalizedPath.split('/').where((part) => part.isNotEmpty).toList();
    String currentPath = '/';
    
    for (final part in parts) {
      currentPath = normalizePath('$currentPath/$part');
      final item = await getItemByPath(currentPath);
      if (item != null) {
        breadcrumb.add(item);
      }
    }
    
    return breadcrumb;
  }

  @override
  Future<bool> pathExists(String path) async {
    final normalizedPath = normalizePath(path);
    
    final result = _databaseService.query('''
      SELECT COUNT(*) as count FROM collections WHERE path = ?
    ''', [normalizedPath]);
    
    return result.first['count'] as int > 0;
  }

  @override
  String? getParentPath(String path) {
    final normalizedPath = normalizePath(path);
    if (normalizedPath == '/') return null;
    
    final parts = normalizedPath.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    
    parts.removeLast();
    return parts.isEmpty ? '/' : '/${parts.join('/')}';
  }

  @override
  String normalizePath(String path) {
    if (path.isEmpty) return '/';
    
    // Remove leading and trailing slashes
    var normalized = path.trim();
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }
    
    // Remove trailing slash unless it's the root
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    
    // Remove double slashes
    normalized = normalized.replaceAll(RegExp(r'\/+'), '/');
    
    return normalized;
  }

  @override
  bool isValidPath(String path) {
    if (path.isEmpty) return false;
    
    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"|?*]');
    if (invalidChars.hasMatch(path)) return false;
    
    // Check for reserved names
    final reservedNames = ['CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'];
    final pathParts = path.split('/').where((part) => part.isNotEmpty);
    
    for (final part in pathParts) {
      if (reservedNames.contains(part.toUpperCase())) return false;
    }
    
    return true;
  }

  @override
  Future<List<CollectionItem>> getRootItems() async {
    return getItemsInPath('/');
  }

  // Helper methods for mapping database rows to models
  CollectionItem _mapRowToCollectionItem(Map<String, Object?> row) {
    return CollectionItem(
      id: row['id'] as int?,
      path: row['path'] as String,
      name: row['name'] as String,
      type: (row['type'] as String) == 'folder' ? CollectionItemType.folder : CollectionItemType.file,
      parentPath: row['parent_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
    );
  }

  SavedRequest _mapRowToSavedRequest(Map<String, Object?> row) {
    final queryParamsJson = row['query_params'] as String?;
    final headersJson = row['headers'] as String?;
    
    List<Map<String, String>> queryParams = [];
    Map<String, String> headers = {};
    
    if (queryParamsJson != null && queryParamsJson.isNotEmpty) {
      final decoded = jsonDecode(queryParamsJson) as List;
      queryParams = decoded.map((item) => Map<String, String>.from(item)).toList();
    }
    
    if (headersJson != null && headersJson.isNotEmpty) {
      headers = Map<String, String>.from(jsonDecode(headersJson));
    }
    
    return SavedRequest(
      id: row['id'] as int?,
      collectionPath: row['collection_path'] as String,
      name: row['name'] as String,
      request: CurrentRequest(
        method: row['method'] as String,
        baseUrl: row['base_url'] as String,
        url: row['url'] as String,
        queryParams: queryParams.map((p) => UrlParameter(key: p['key']!, value: p['value']!)).toList(),
        headers: headers,
        authMethod: AuthorizationMethod.values.firstWhere(
          (e) => e.name == (row['auth_method'] as String),
          orElse: () => AuthorizationMethod.none,
        ),
        authToken: row['auth_token'] as String?,
        authUsername: row['auth_username'] as String?,
        authPassword: row['auth_password'] as String?,
        rawBody: row['raw_body'] as String? ?? '',
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
    );
  }
} 