import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/domain/models/collection_item.dart';
import 'package:open_client_http/presentation/provider/collections/collections_provider.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:open_client_http/presentation/widget/shared/app_bar.dart';
import 'package:open_client_http/presentation/widget/shared/drawer.dart';
import 'package:open_client_http/presentation/provider/current_request/current_request_provider.dart';
import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/domain/models/saved_request.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  static const String name = "collections_screen";

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _folderNameController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _folderFocusNode = FocusNode();
  
  bool _isSearchExpanded = false;
  bool _isCreatingFolder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(collectionsProvider.notifier).loadItemsInPath('/');
    });
    
    // Listen to search changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _folderNameController.dispose();
    _searchFocusNode.dispose();
    _folderFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ref.read(collectionsProvider.notifier).clearSearch();
    } else {
      ref.read(collectionsProvider.notifier).searchItems(query);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        ref.read(collectionsProvider.notifier).clearSearch();
      }
    });
  }

  void _toggleCreateFolder() {
    setState(() {
      _isCreatingFolder = !_isCreatingFolder;
      if (_isCreatingFolder) {
        _folderNameController.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _folderFocusNode.requestFocus();
        });
      } else {
        _folderFocusNode.unfocus();
      }
    });
  }

  void _createFolder() {
    final name = _folderNameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(collectionsProvider.notifier).createFolder(name);
      _folderNameController.clear();
      setState(() {
        _isCreatingFolder = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Folder "$name" created'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collectionsState = ref.watch(collectionsProvider);
    final isLoading = collectionsState.isLoading;
    final items = collectionsState.displayItems;
    final error = collectionsState.error;
    final currentPath = collectionsState.currentPath;
    final isAtRoot = collectionsState.isAtRoot;
    final isSearchMode = collectionsState.isSearchMode;
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;
    
    // Check if we're in save mode
    final isSaveMode = GoRouterState.of(context).uri.queryParameters['mode'] == 'save';
    final currentRequest = isSaveMode ? ref.watch(currentRequestProvider) : null;

    return Scaffold(
      appBar: AppBarCustom(
        titleText: isSaveMode ? 'Save Request - Select Folder' : 'Collections',
        leading: isSaveMode ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouterPath.home),
          tooltip: 'Back to home',
        ) : null,
        actions: isSaveMode ? [] : [
          IconButton(
            icon: Icon(_isSearchExpanded ? Icons.search_off : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearchExpanded ? 'Close search' : 'Search collections',
          ),
          IconButton(
            icon: Icon(_isCreatingFolder ? Icons.close : Icons.create_new_folder),
            onPressed: _toggleCreateFolder,
            tooltip: _isCreatingFolder ? 'Cancel' : 'Create folder',
          ),
        ],
      ),
      drawer: const DrawerCustom(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Save mode banner
              if (isSaveMode) _buildSaveModeBanner(theme, currentRequest!),
              
              // Search bar (collapsible) - hidden in save mode
              if (_isSearchExpanded && !isSaveMode) _buildSearchBar(theme, hasSearchQuery),
              
              // Create folder form (collapsible)
              if (_isCreatingFolder) _buildCreateFolderForm(theme),
              
              // Navigation header
              _buildNavigationHeader(context, currentPath, isAtRoot),
              
              const SizedBox(height: 20),
              
              // Error display
              if (error != null) _buildErrorWidget(context, error),
              
              // Search results indicator
              if (isSearchMode) _buildSearchResultsHeader(theme, items.length),
              
              // Quick actions (only show when not searching and not in save mode)
              if (!isSearchMode && !isSaveMode) ...[
                _buildQuickActions(context),
                const SizedBox(height: 20),
              ],
              
              // Content section
              if (!isSearchMode) ...[
                _sectionTitle(isSaveMode ? 'Select folder to save your request:' : 'Items in Collection'),
                const SizedBox(height: 12),
              ],
              
              // Items list or empty state
              if (isLoading)
                _buildLoadingWidget()
              else if (items.isEmpty)
                _buildEmptyState(context, isSearchMode)
              else
                _buildItemsList(context, items, isSearchMode, isSaveMode),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(isSaveMode, isSearchMode, currentPath, currentRequest),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool hasSearchQuery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasSearchQuery 
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: hasSearchQuery ? 2 : 1,
            ),
            boxShadow: hasSearchQuery ? [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search collections and requests...',
              prefixIcon: Icon(
                Icons.search,
                color: hasSearchQuery 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateFolderForm(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.create_new_folder,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Create New Folder',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _folderNameController,
                  focusNode: _folderFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter folder name (e.g., Authentication APIs)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (_) => _createFolder(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _createFolder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsHeader(ThemeData theme, int resultCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Search Results',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.secondary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$resultCount items',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildNavigationHeader(BuildContext context, String currentPath, bool isAtRoot) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Path',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currentPath == '/' ? 'Root Collection' : currentPath,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!isAtRoot) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      ref.read(collectionsProvider.notifier).navigateToParent();
                    },
                    icon: const Icon(Icons.arrow_upward, size: 16),
                    tooltip: 'Go to parent folder',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
                IconButton(
                  onPressed: isAtRoot ? null : () {
                    ref.read(collectionsProvider.notifier).navigateToRoot();
                  },
                  icon: const Icon(Icons.home, size: 16),
                  tooltip: 'Go to root',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(child: _buildQuickActionButton(
          context,
          icon: Icons.create_new_folder,
          title: 'New Folder',
          subtitle: 'Create folder',
          color: theme.colorScheme.primary,
          onTap: _toggleCreateFolder,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildQuickActionButton(
          context,
          icon: Icons.search,
          title: 'Search',
          subtitle: 'Find items',
          color: theme.colorScheme.secondary,
          onTap: _toggleSearch,
        )),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.08),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(collectionsProvider.notifier).clearError();
            },
            icon: const Icon(Icons.close, size: 16),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearchMode) {
    final theme = Theme.of(context);
    
    if (isSearchMode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No items in this collection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new folder or save a request to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleCreateFolder,
                  icon: const Icon(Icons.create_new_folder, size: 16),
                  label: const Text('Create Folder'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showSaveCurrentRequestDialog(context),
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save Request'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, List<CollectionItem> items, bool isSearchMode, bool isSaveMode) {
    return Column(
      children: items.map((item) => _buildItemTile(context, item, isSearchMode, isSaveMode)).toList(),
    );
  }

  Widget _buildSaveModeBanner(ThemeData theme, CurrentRequest currentRequest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.save,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Saving Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentRequest.method} ${currentRequest.url}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (currentRequest.rawBody.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'With request body',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(bool isSaveMode, bool isSearchMode, String currentPath, CurrentRequest? currentRequest) {
    if (isSaveMode && currentRequest != null) {
      return FloatingActionButton.extended(
        onPressed: () => _showSaveRequestDialog(context, currentPath, currentRequest),
        icon: const Icon(Icons.save),
        label: const Text('Save Here'),
        tooltip: 'Save request in current folder',
      );
    } else if (!isSearchMode && !_isCreatingFolder) {
      return FloatingActionButton(
        onPressed: () => _showSaveCurrentRequestDialog(context),
        tooltip: 'Save current request',
        child: const Icon(Icons.save),
      );
    }
    return null;
  }

  Widget _buildItemTile(BuildContext context, CollectionItem item, bool isSearchMode, bool isSaveMode) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: FutureBuilder(
        future: item.isFile ? _getRequestInfo(item) : Future.value(null),
        builder: (context, snapshot) {
          final requestInfo = snapshot.data as Map<String, String>?;
          final method = requestInfo?['method'];
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.isFolder 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : _getMethodColor(context, item, method).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.isFolder ? Icons.folder : Icons.http,
                color: item.isFolder 
                    ? theme.colorScheme.primary 
                    : _getMethodColor(context, item, method),
                size: 20,
              ),
            ),
            title: Text(
              item.isFile && item.name.endsWith('.oreq')
                  ? item.name.substring(0, item.name.length - 5) // Remove .oreq extension for display
                  : item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            subtitle: item.isFolder 
                ? Row(
                    children: [
                      Text(
                        'Folder',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      if (isSearchMode) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${item.path}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          method != null 
                              ? '$method • ${requestInfo?['url'] ?? 'HTTP Request'}'
                              : 'HTTP Request',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontFamily: method != null ? 'monospace' : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSearchMode) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${item.path}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                                         ],
                   ),
            trailing: isSaveMode && item.isFolder 
                ? Icon(Icons.chevron_right, color: theme.colorScheme.primary)
                : PopupMenuButton<String>(
                    onSelected: (value) => _handleItemAction(value, item),
                    itemBuilder: (context) => [
                      if (item.isFolder) ...[
                        const PopupMenuItem(
                          value: 'open',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open, size: 16),
                              SizedBox(width: 8),
                              Text('Open'),
                            ],
                          ),
                        ),
                      ] else ...[
                        const PopupMenuItem(
                          value: 'load',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload, size: 16),
                              SizedBox(width: 8),
                              Text('Load Request'),
                            ],
                          ),
                        ),
                      ],
                      if (!isSaveMode) 
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
            onTap: () {
              if (item.isFolder) {
                // Clear search when navigating to folder
                if (isSearchMode) {
                  _searchController.clear();
                  setState(() {
                    _isSearchExpanded = false;
                  });
                }
                ref.read(collectionsProvider.notifier).navigateToPath(item.path);
              } else if (!isSaveMode) {
                _loadRequest(item);
              }
            },
          );
        },
      ),
    );
  }

  void _handleItemAction(String action, CollectionItem item) {
    final collectionsState = ref.read(collectionsProvider);
    final isSearchMode = collectionsState.isSearchMode;
    
    switch (action) {
      case 'open':
        if (item.isFolder) {
          // Clear search when navigating
          if (isSearchMode) {
            _searchController.clear();
            setState(() {
              _isSearchExpanded = false;
            });
          }
          ref.read(collectionsProvider.notifier).navigateToPath(item.path);
        }
        break;
      case 'load':
        if (!item.isFolder) {
          _loadRequest(item);
        }
        break;
      case 'delete':
        _showDeleteConfirmation(context, item);
        break;
    }
  }

  void _loadRequest(CollectionItem item) async {
    try {
      // Get display name (remove .oreq extension for display)
      final displayName = item.name.endsWith('.oreq') 
          ? item.name.substring(0, item.name.length - 5)
          : item.name;
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Loading: $displayName')),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Get the saved request from database using the item name directly
      final savedRequest = await ref.read(collectionsProvider.notifier).getSavedRequest(item.name);
      
      if (savedRequest != null) {
        // Load the request data into the current request provider
        final currentRequestNotifier = ref.read(currentRequestProvider.notifier);
        
        // Clear current request first
        currentRequestNotifier.reset();
        
        // Load the saved request data
        final requestData = savedRequest.request;
        
        // Set the ID to mark it as saved - use the database ID if available, otherwise use path/name
        final requestId = savedRequest.id?.toString() ?? '${savedRequest.collectionPath}/${savedRequest.name}';
        currentRequestNotifier.setRequestId(requestId);
        
        // Load all the request data
        currentRequestNotifier.updateMethod(requestData.method);
        
        // Load URL - use the full URL if available, otherwise reconstruct from baseUrl and queryParams
        if (requestData.url.isNotEmpty) {
          // If we have a full URL, use it directly
          currentRequestNotifier.updateUrlWithParsing(requestData.url);
        } else {
          // Reconstruct URL from baseUrl and queryParams
          String reconstructedUrl = requestData.baseUrl;
          if (requestData.queryParams.isNotEmpty) {
            final queryString = requestData.queryParams
                .map((param) => '${Uri.encodeComponent(param.key)}=${Uri.encodeComponent(param.value)}')
                .join('&');
            reconstructedUrl += '?$queryString';
          }
          currentRequestNotifier.updateUrlWithParsing(reconstructedUrl);
        }
        
        // Load headers (clear defaults first, then add saved headers)
        currentRequestNotifier.clearHeaders();
        for (final entry in requestData.headers.entries) {
          currentRequestNotifier.addHeader(entry.key, entry.value);
        }
        
        // Load auth settings
        currentRequestNotifier.updateAuthMethod(requestData.authMethod);
        if (requestData.authToken != null && requestData.authToken!.isNotEmpty) {
          currentRequestNotifier.updateAuthToken(requestData.authToken!);
        }
        if (requestData.authUsername != null && requestData.authPassword != null && 
            requestData.authUsername!.isNotEmpty && requestData.authPassword!.isNotEmpty) {
          currentRequestNotifier.updateBasicAuth(requestData.authUsername!, requestData.authPassword!);
        }
        
        // Load body
        currentRequestNotifier.updateRawBody(requestData.rawBody);
        
        // Navigate to home and show success
        context.go(RouterPath.home);
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded: $displayName'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'Send Request',
              textColor: Colors.white,
              onPressed: () {
                // User can manually send the request
              },
            ),
          ),
        );
      } else {
        // Request not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request "$displayName" not found in database'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading request: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _loadRequest(item),
          ),
        ),
      );
    }
  }

  void _showSaveCurrentRequestDialog(BuildContext context) {
    // Get current request from provider
    final currentRequest = ref.read(currentRequestProvider);
    
    // Check if there's a valid request to save
    if (currentRequest.url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid URL before saving'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Navigate to collections in save mode
    context.go('${RouterPath.collections}?mode=save');
  }

  void _showSaveRequestDialog(BuildContext context, String currentPath, CurrentRequest currentRequest) {
    final TextEditingController nameController = TextEditingController();
    
    // If this is an update, try to get the current name without extension
    if (currentRequest.id != null && currentRequest.id!.isNotEmpty) {
      final parts = currentRequest.id!.split('/');
      if (parts.isNotEmpty) {
        final fileName = parts.last;
        // Remove .oreq extension for editing
        final displayName = fileName.endsWith('.oreq') 
            ? fileName.substring(0, fileName.length - 5)
            : fileName;
        nameController.text = displayName;
      }
    }
    
    final isUpdate = currentRequest.id != null && currentRequest.id!.isNotEmpty;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdate ? 'Update Request' : 'Save Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Request name',
                hintText: 'e.g., Get User Profile',
                border: const OutlineInputBorder(),
                helperText: isUpdate ? 'This will update the existing request' : null,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Folder: ${currentPath == '/' ? 'Root Collection' : currentPath}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentRequest.method} ${currentRequest.url}',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                  if (isUpdate) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Previously saved request',
                      style: TextStyle(
                        fontSize: 10, 
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop();
                await _saveRequestToCollection(context, name, currentPath, currentRequest);
              }
            },
            style: isUpdate ? ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ) : null,
            child: Text(isUpdate ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveRequestToCollection(BuildContext context, String name, String currentPath, CurrentRequest currentRequest) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Saving request...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Add .oreq extension if not present
      final fileName = name.endsWith('.oreq') ? name : '$name.oreq';
      
      // Create SavedRequest from CurrentRequest
      final now = DateTime.now();
      
      // Check if this is an update or new creation
      final isUpdate = currentRequest.id != null && currentRequest.id!.isNotEmpty;
      
      if (isUpdate) {
        // This is an update - find the existing saved request and update it
        final existingSavedRequest = await ref.read(collectionsProvider.notifier).getSavedRequest(fileName);
        
        if (existingSavedRequest != null) {
          // Update existing request
          final updatedRequest = SavedRequest(
            id: existingSavedRequest.id,
            collectionPath: currentPath,
            name: fileName,
            request: currentRequest,
            createdAt: existingSavedRequest.createdAt, // Keep original creation time
            updatedAt: now, // Update the modification time
          );
          
          await ref.read(collectionsProvider.notifier).updateSavedRequest(fileName, updatedRequest);
          
          // Navigate back to home and show success
          if (mounted) {
            context.go(RouterPath.home);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Request "$name" updated successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'View Collection',
                  onPressed: () => context.go(RouterPath.collections),
                ),
              ),
            );
          }
        } else {
          throw Exception('Could not find existing request to update');
        }
      } else {
        // This is a new request
        final savedRequest = SavedRequest(
          collectionPath: currentPath,
          name: fileName,
          request: currentRequest,
          createdAt: now,
          updatedAt: now,
        );
        
        // Save using the collections provider
        await ref.read(collectionsProvider.notifier).createSavedRequest(fileName, savedRequest);
        
        // Update the current request with an ID to mark it as saved
        final requestId = '${currentPath}/${fileName}'.replaceAll('//', '/');
        ref.read(currentRequestProvider.notifier).setRequestId(requestId);
        
        // Navigate back to home and show success
        if (mounted) {
          context.go(RouterPath.home);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request "$name" saved to collection'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'View Collection',
                onPressed: () => context.go(RouterPath.collections),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving request: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveRequestToCollection(context, name, currentPath, currentRequest),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, CollectionItem item) {
    // Get display name (remove .oreq extension for files)
    final displayName = item.isFile && item.name.endsWith('.oreq')
        ? item.name.substring(0, item.name.length - 5)
        : item.name;
        
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${item.isFolder ? 'Folder' : 'Request'}'),
        content: Text(
          'Are you sure you want to delete "$displayName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(collectionsProvider.notifier).deleteItem(item.path);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$displayName deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Get the color for HTTP methods
  Color _getMethodColor(BuildContext context, CollectionItem item, [String? method]) {
    final theme = Theme.of(context);
    
    if (item.isFolder) {
      return theme.colorScheme.primary;
    }
    
    // Color based on HTTP method
    switch (method?.toUpperCase()) {
      case 'GET':
        return const Color(0xFF4CAF50); // Green
      case 'POST':
        return const Color(0xFF2196F3); // Blue
      case 'PUT':
        return const Color(0xFFFF9800); // Orange
      case 'DELETE':
        return const Color(0xFFF44336); // Red
      case 'PATCH':
        return const Color(0xFF9C27B0); // Purple
      case 'HEAD':
        return const Color(0xFF607D8B); // Blue Grey
      case 'OPTIONS':
        return const Color(0xFF795548); // Brown
      default:
        return theme.colorScheme.secondary; // Default
    }
  }

  /// Get request information for display
  Future<Map<String, String>?> _getRequestInfo(CollectionItem item) async {
    if (item.isFolder) return null;
    
    try {
      final savedRequest = await ref.read(collectionsProvider.notifier).getSavedRequest(item.name);
      if (savedRequest != null) {
        return {
          'method': savedRequest.request.method,
          'url': savedRequest.request.url.isNotEmpty ? savedRequest.request.url : savedRequest.request.baseUrl,
        };
      }
    } catch (e) {
      // If we can't get the request info, just return null
      print('Error getting request info for ${item.name}: $e');
    }
    
    return null;
  }
} 