import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'app_database.db';
  static const int _databaseVersion = 1;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Get database instance
  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initDatabase() first.');
    }
    return _database!;
  }

  /// Initialize database
  Future<void> initDatabase() async {
    if (_database != null) return;

    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);
      
      // Ensure directory exists
      final dbDir = Directory(dirname(path));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      // Open database
      _database = sqlite3.open(path);
      
      // Enable foreign keys
      _database!.execute('PRAGMA foreign_keys = ON;');
      
      // Create tables
      await _createTables();
      
      print('Database initialized successfully at: $path');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create all tables
  Future<void> _createTables() async {
    // Request history table
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS request_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        method TEXT NOT NULL,
        headers TEXT,
        body TEXT,
        response_status INTEGER,
        response_body TEXT,
        response_headers TEXT,
        created_at INTEGER NOT NULL,
        execution_time INTEGER
      );
    ''');

    // Environment configurations table
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS environments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    // Environment keys table (key-value pairs for each environment)
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS environment_keys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        environment_id INTEGER NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (environment_id) REFERENCES environments (id) ON DELETE CASCADE
      );
    ''');

    // Collections table - stores the hierarchical structure like S3
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('folder', 'file')),
        parent_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (parent_path) REFERENCES collections (path) ON DELETE CASCADE
      );
    ''');

    _database!.execute('''
      INSERT OR IGNORE INTO collections (path, name, type, parent_path, created_at, updated_at)
      VALUES (
          '/',
          'Root',
          'folder',
          NULL,
          ${DateTime.now().millisecondsSinceEpoch},
          ${DateTime.now().millisecondsSinceEpoch}
      );
    ''');

    // Saved requests table - stores the actual request data
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS saved_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection_path TEXT NOT NULL,
        name TEXT NOT NULL,
        method TEXT NOT NULL,
        base_url TEXT NOT NULL,
        url TEXT NOT NULL,
        query_params TEXT, -- JSON string of query parameters
        headers TEXT, -- JSON string of headers
        auth_method TEXT NOT NULL,
        auth_token TEXT,
        auth_username TEXT,
        auth_password TEXT,
        raw_body TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (collection_path) REFERENCES collections (path) ON DELETE CASCADE,
        UNIQUE(collection_path, name)
      );
    ''');

    // Create indexes for better performance
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_request_history_created_at ON request_history(created_at);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_request_history_method ON request_history(method);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_environments_name ON environments(name);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_environment_keys_environment_id ON environment_keys(environment_id);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_environment_keys_key ON environment_keys(key);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_collections_path ON collections(path);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_collections_parent_path ON collections(parent_path);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_collections_type ON collections(type);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_saved_requests_collection_path ON saved_requests(collection_path);');
    _database!.execute('CREATE INDEX IF NOT EXISTS idx_saved_requests_name ON saved_requests(name);');
  }

  /// Execute a query with parameters
  ResultSet query(String sql, [List<Object?> parameters = const []]) {
    try {
      final stmt = _database!.prepare(sql);
      final result = stmt.select(parameters);
      stmt.dispose();
      return result;
    } catch (e) {
      print('Error executing query: $sql, Error: $e');
      rethrow;
    }
  }

  /// Execute an insert/update/delete statement
  int execute(String sql, [List<Object?> parameters = const []]) {
    try {
      final stmt = _database!.prepare(sql);
      stmt.execute(parameters);
      final changes = _database!.getUpdatedRows();
      stmt.dispose();
      return changes;
    } catch (e) {
      print('Error executing statement: $sql, Error: $e');
      rethrow;
    }
  }

  /// Get last inserted row ID
  int getLastInsertId() {
    return _database!.lastInsertRowId;
  }

  /// Begin transaction
  void beginTransaction() {
    _database!.execute('BEGIN TRANSACTION;');
  }

  /// Commit transaction
  void commitTransaction() {
    _database!.execute('COMMIT;');
  }

  /// Rollback transaction
  void rollbackTransaction() {
    _database!.execute('ROLLBACK;');
  }

  /// Execute multiple statements in a transaction
  Future<T> transaction<T>(Future<T> Function() action) async {
    beginTransaction();
    try {
      final result = await action();
      commitTransaction();
      return result;
    } catch (e) {
      rollbackTransaction();
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      _database!.dispose();
      _database = null;
      print('Database connection closed');
    }
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  /// Delete database file (for testing purposes)
  Future<void> deleteDatabase() async {
    await close();
    final path = await getDatabasePath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print('Database deleted: $path');
    }
  }

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    final path = await getDatabasePath();
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Vacuum database to optimize storage
  void vacuum() {
    _database!.execute('VACUUM;');
  }
} 