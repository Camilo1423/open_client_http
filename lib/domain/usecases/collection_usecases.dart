import 'package:open_client_http/domain/models/collection_item.dart';
import 'package:open_client_http/domain/models/saved_request.dart';
import 'package:open_client_http/domain/repositories/collection_repository.dart';

/// Use case to get items in a specific path
class GetItemsInPathUseCase {
  final CollectionRepository _repository;

  GetItemsInPathUseCase(this._repository);

  Future<List<CollectionItem>> call(String path) async {
    return await _repository.getItemsInPath(path);
  }
}

/// Use case to create a new folder
class CreateFolderUseCase {
  final CollectionRepository _repository;

  CreateFolderUseCase(this._repository);

  Future<CollectionItem> call(String path, String name) async {
    if (!_repository.isValidPath('$path/$name')) {
      throw ArgumentError('Invalid folder name: $name');
    }
    
    final exists = await _repository.pathExists('$path/$name');
    if (exists) {
      throw ArgumentError('Folder already exists: $name');
    }
    
    return await _repository.createFolder(path, name);
  }
}

/// Use case to create a new saved request file
class CreateSavedRequestUseCase {
  final CollectionRepository _repository;

  CreateSavedRequestUseCase(this._repository);

  Future<SavedRequest> call(String path, String name, SavedRequest request) async {
    if (!_repository.isValidPath('$path/$name')) {
      throw ArgumentError('Invalid file name: $name');
    }
    
    final exists = await _repository.pathExists('$path/$name');
    if (exists) {
      throw ArgumentError('File already exists: $name');
    }
    
    return await _repository.createFile(path, name, request);
  }
}

/// Use case to update an existing saved request
class UpdateSavedRequestUseCase {
  final CollectionRepository _repository;

  UpdateSavedRequestUseCase(this._repository);

  Future<SavedRequest> call(String path, String name, SavedRequest request) async {
    final exists = await _repository.getSavedRequest(path, name);
    if (exists == null) {
      throw ArgumentError('File does not exist: $name');
    }
    
    return await _repository.updateFile(path, name, request);
  }
}

/// Use case to delete an item (folder or file)
class DeleteItemUseCase {
  final CollectionRepository _repository;

  DeleteItemUseCase(this._repository);

  Future<bool> call(String path) async {
    final exists = await _repository.pathExists(path);
    if (!exists) {
      throw ArgumentError('Item does not exist: $path');
    }
    
    return await _repository.deleteItem(path);
  }
}

/// Use case to get a saved request
class GetSavedRequestUseCase {
  final CollectionRepository _repository;

  GetSavedRequestUseCase(this._repository);

  Future<SavedRequest?> call(String path, String name) async {
    return await _repository.getSavedRequest(path, name);
  }
}

class GetSavedRequestByIdUseCase {
  final CollectionRepository _repository;

  GetSavedRequestByIdUseCase(this._repository);

  Future<SavedRequest?> call(String id) async {
    return await _repository.getSavedRequestById(id);
  }
}

/// Use case to search for items
class SearchItemsUseCase {
  final CollectionRepository _repository;

  SearchItemsUseCase(this._repository);

  Future<List<CollectionItem>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    return await _repository.searchItems(query.trim());
  }
}

/// Use case to get breadcrumb navigation
class GetBreadcrumbUseCase {
  final CollectionRepository _repository;

  GetBreadcrumbUseCase(this._repository);

  Future<List<CollectionItem>> call(String path) async {
    return await _repository.getBreadcrumb(path);
  }
}

/// Use case to get root items
class GetRootItemsUseCase {
  final CollectionRepository _repository;

  GetRootItemsUseCase(this._repository);

  Future<List<CollectionItem>> call() async {
    return await _repository.getRootItems();
  }
}

/// Use case to validate path
class ValidatePathUseCase {
  final CollectionRepository _repository;

  ValidatePathUseCase(this._repository);

  bool call(String path) {
    return _repository.isValidPath(path);
  }
}

/// Use case to normalize path
class NormalizePathUseCase {
  final CollectionRepository _repository;

  NormalizePathUseCase(this._repository);

  String call(String path) {
    return _repository.normalizePath(path);
  }
} 