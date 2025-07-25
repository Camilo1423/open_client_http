import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/data/datasources/database_service.dart';
import 'package:open_client_http/data/repositories/collection_repository_impl.dart';
import 'package:open_client_http/domain/models/collection_item.dart';
import 'package:open_client_http/domain/models/saved_request.dart';
import 'package:open_client_http/domain/repositories/collection_repository.dart';
import 'package:open_client_http/domain/usecases/collection_usecases.dart';

// Providers for dependency injection
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return CollectionRepositoryImpl(databaseService);
});

// Use case providers
final getItemsInPathUseCaseProvider = Provider<GetItemsInPathUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return GetItemsInPathUseCase(repository);
});

final createFolderUseCaseProvider = Provider<CreateFolderUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return CreateFolderUseCase(repository);
});

final createSavedRequestUseCaseProvider = Provider<CreateSavedRequestUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return CreateSavedRequestUseCase(repository);
});

final updateSavedRequestUseCaseProvider = Provider<UpdateSavedRequestUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return UpdateSavedRequestUseCase(repository);
});

final deleteItemUseCaseProvider = Provider<DeleteItemUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return DeleteItemUseCase(repository);
});

final getSavedRequestUseCaseProvider = Provider<GetSavedRequestUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return GetSavedRequestUseCase(repository);
});

final getSavedRequestByIdUseCaseProvider = Provider<GetSavedRequestByIdUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return GetSavedRequestByIdUseCase(repository);
});

final searchItemsUseCaseProvider = Provider<SearchItemsUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return SearchItemsUseCase(repository);
});

final getBreadcrumbUseCaseProvider = Provider<GetBreadcrumbUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return GetBreadcrumbUseCase(repository);
});

final getRootItemsUseCaseProvider = Provider<GetRootItemsUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return GetRootItemsUseCase(repository);
});

final validatePathUseCaseProvider = Provider<ValidatePathUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return ValidatePathUseCase(repository);
});

final normalizePathUseCaseProvider = Provider<NormalizePathUseCase>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return NormalizePathUseCase(repository);
});

// State notifier for collections
class CollectionsNotifier extends StateNotifier<CollectionsState> {
  final GetItemsInPathUseCase _getItemsInPathUseCase;
  final CreateFolderUseCase _createFolderUseCase;
  final CreateSavedRequestUseCase _createSavedRequestUseCase;
  final UpdateSavedRequestUseCase _updateSavedRequestUseCase;
  final DeleteItemUseCase _deleteItemUseCase;
  final GetSavedRequestUseCase _getSavedRequestUseCase;
  final GetSavedRequestByIdUseCase _getSavedRequestByIdUseCase;
  final SearchItemsUseCase _searchItemsUseCase;
  final GetBreadcrumbUseCase _getBreadcrumbUseCase;
  final ValidatePathUseCase _validatePathUseCase;
  final NormalizePathUseCase _normalizePathUseCase;

  CollectionsNotifier({
    required GetItemsInPathUseCase getItemsInPathUseCase,
    required CreateFolderUseCase createFolderUseCase,
    required CreateSavedRequestUseCase createSavedRequestUseCase,
    required UpdateSavedRequestUseCase updateSavedRequestUseCase,
    required DeleteItemUseCase deleteItemUseCase,
    required GetSavedRequestUseCase getSavedRequestUseCase,
    required GetSavedRequestByIdUseCase getSavedRequestByIdUseCase,
    required SearchItemsUseCase searchItemsUseCase,
    required GetBreadcrumbUseCase getBreadcrumbUseCase,
    required ValidatePathUseCase validatePathUseCase,
    required NormalizePathUseCase normalizePathUseCase,
  })  : _getItemsInPathUseCase = getItemsInPathUseCase,
        _createFolderUseCase = createFolderUseCase,
        _createSavedRequestUseCase = createSavedRequestUseCase,
        _updateSavedRequestUseCase = updateSavedRequestUseCase,
        _deleteItemUseCase = deleteItemUseCase,
        _getSavedRequestUseCase = getSavedRequestUseCase,
        _getSavedRequestByIdUseCase = getSavedRequestByIdUseCase,
        _searchItemsUseCase = searchItemsUseCase,
        _getBreadcrumbUseCase = getBreadcrumbUseCase,
        _validatePathUseCase = validatePathUseCase,
        _normalizePathUseCase = normalizePathUseCase,
        super(CollectionsState.initial());

  /// Load items in current path
  Future<void> loadItemsInPath(String path) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final normalizedPath = _normalizePathUseCase(path);
      final items = await _getItemsInPathUseCase(normalizedPath);
      final breadcrumb = await _getBreadcrumbUseCase(normalizedPath);
      
      state = state.copyWith(
        currentPath: normalizedPath,
        items: items,
        breadcrumb: breadcrumb,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Create a new folder
  Future<void> createFolder(String name) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _createFolderUseCase(state.currentPath, name);
      await loadItemsInPath(state.currentPath);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Create a new saved request
  Future<void> createSavedRequest(String name, SavedRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _createSavedRequestUseCase(state.currentPath, name, request);
      await loadItemsInPath(state.currentPath);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Update an existing saved request
  Future<void> updateSavedRequest(String name, SavedRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _updateSavedRequestUseCase(state.currentPath, name, request);
      await loadItemsInPath(state.currentPath);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Delete an item
  Future<void> deleteItem(String path) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _deleteItemUseCase(path);
      await loadItemsInPath(state.currentPath);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Get a saved request
  Future<SavedRequest?> getSavedRequest(String name) async {
    try {
      return await _getSavedRequestUseCase(state.currentPath, name);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get a saved request by id
  Future<SavedRequest?> getSavedRequestById(String id) async {
    try {
      return await _getSavedRequestByIdUseCase(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Search for items
  Future<void> searchItems(String query) async {
    if (query.trim().isEmpty) {
      await loadItemsInPath(state.currentPath);
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final searchResults = await _searchItemsUseCase(query);
      state = state.copyWith(
        searchResults: searchResults,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Navigate to a path
  Future<void> navigateToPath(String path) async {
    await loadItemsInPath(path);
  }

  /// Navigate to parent directory
  Future<void> navigateToParent() async {
    if (state.currentPath == '/') return;
    
    final parentPath = _getParentPath(state.currentPath);
    if (parentPath != null) {
      await navigateToPath(parentPath);
    }
  }

  /// Navigate to root
  Future<void> navigateToRoot() async {
    await navigateToPath('/');
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }

  /// Validate path
  bool isValidPath(String path) {
    return _validatePathUseCase(path);
  }

  /// Normalize path
  String normalizePath(String path) {
    return _normalizePathUseCase(path);
  }

  /// Get parent path
  String? _getParentPath(String path) {
    if (path == '/') return null;
    
    final parts = path.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    
    parts.removeLast();
    return parts.isEmpty ? '/' : '/${parts.join('/')}';
  }
}

// State class for collections
class CollectionsState {
  final String currentPath;
  final List<CollectionItem> items;
  final List<CollectionItem> breadcrumb;
  final List<CollectionItem> searchResults;
  final bool isLoading;
  final String? error;

  const CollectionsState({
    required this.currentPath,
    required this.items,
    required this.breadcrumb,
    required this.searchResults,
    required this.isLoading,
    this.error,
  });

  factory CollectionsState.initial() {
    return const CollectionsState(
      currentPath: '/',
      items: [],
      breadcrumb: [],
      searchResults: [],
      isLoading: false,
    );
  }

  CollectionsState copyWith({
    String? currentPath,
    List<CollectionItem>? items,
    List<CollectionItem>? breadcrumb,
    List<CollectionItem>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return CollectionsState(
      currentPath: currentPath ?? this.currentPath,
      items: items ?? this.items,
      breadcrumb: breadcrumb ?? this.breadcrumb,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Check if we're in search mode
  bool get isSearchMode => searchResults.isNotEmpty;

  /// Get items to display (search results or current items)
  List<CollectionItem> get displayItems => isSearchMode ? searchResults : items;

  /// Check if we're at root
  bool get isAtRoot => currentPath == '/';

  /// Check if we have an error
  bool get hasError => error != null;
}

// Main provider
final collectionsProvider = StateNotifierProvider<CollectionsNotifier, CollectionsState>((ref) {
  return CollectionsNotifier(
    getItemsInPathUseCase: ref.watch(getItemsInPathUseCaseProvider),
    createFolderUseCase: ref.watch(createFolderUseCaseProvider),
    createSavedRequestUseCase: ref.watch(createSavedRequestUseCaseProvider),
    updateSavedRequestUseCase: ref.watch(updateSavedRequestUseCaseProvider),
    deleteItemUseCase: ref.watch(deleteItemUseCaseProvider),
    getSavedRequestUseCase: ref.watch(getSavedRequestUseCaseProvider),
    getSavedRequestByIdUseCase: ref.watch(getSavedRequestByIdUseCaseProvider),
    searchItemsUseCase: ref.watch(searchItemsUseCaseProvider),
    getBreadcrumbUseCase: ref.watch(getBreadcrumbUseCaseProvider),
    validatePathUseCase: ref.watch(validatePathUseCaseProvider),
    normalizePathUseCase: ref.watch(normalizePathUseCaseProvider),
  );
});

// Computed providers
final currentPathProvider = Provider<String>((ref) {
  return ref.watch(collectionsProvider).currentPath;
});

final currentItemsProvider = Provider<List<CollectionItem>>((ref) {
  return ref.watch(collectionsProvider).displayItems;
});

final breadcrumbProvider = Provider<List<CollectionItem>>((ref) {
  return ref.watch(collectionsProvider).breadcrumb;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(collectionsProvider).isLoading;
});

final errorProvider = Provider<String?>((ref) {
  return ref.watch(collectionsProvider).error;
});

final isSearchModeProvider = Provider<bool>((ref) {
  return ref.watch(collectionsProvider).isSearchMode;
});

final isAtRootProvider = Provider<bool>((ref) {
  return ref.watch(collectionsProvider).isAtRoot;
}); 