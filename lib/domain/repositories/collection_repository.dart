import 'package:open_client_http/domain/models/collection_item.dart';
import 'package:open_client_http/domain/models/saved_request.dart';

abstract class CollectionRepository {
  /// Get all collection items in a specific path
  Future<List<CollectionItem>> getItemsInPath(String path);
  
  /// Get a specific collection item by path
  Future<CollectionItem?> getItemByPath(String path);
  
  /// Create a new folder
  Future<CollectionItem> createFolder(String path, String name);
  
  /// Create a new file (saved request)
  Future<SavedRequest> createFile(String path, String name, SavedRequest request);
  
  /// Update an existing saved request
  Future<SavedRequest> updateFile(String path, String name, SavedRequest request);
  
  /// Delete a collection item (folder or file)
  Future<bool> deleteItem(String path);
  
  /// Get a saved request by path and name
  Future<SavedRequest?> getSavedRequest(String path, String name);
  
  /// Get a saved request by id
  Future<SavedRequest?> getSavedRequestById(String id);
  
  /// Get all saved requests in a specific path
  Future<List<SavedRequest>> getSavedRequestsInPath(String path);
  
  /// Search for items by name (recursive)
  Future<List<CollectionItem>> searchItems(String query);
  
  /// Get the breadcrumb navigation for a path
  Future<List<CollectionItem>> getBreadcrumb(String path);
  
  /// Check if a path exists
  Future<bool> pathExists(String path);
  
  /// Get the parent path of a given path
  String? getParentPath(String path);
  
  /// Normalize a path (remove double slashes, etc.)
  String normalizePath(String path);
  
  /// Validate if a path is valid
  bool isValidPath(String path);
  
  /// Get the root path items
  Future<List<CollectionItem>> getRootItems();
} 