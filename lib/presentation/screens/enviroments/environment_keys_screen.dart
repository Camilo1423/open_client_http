import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/router/index.dart';
import 'package:open_client_http/presentation/widget/shared/app_bar.dart';
import 'package:open_client_http/presentation/widget/shared/drawer.dart';
import 'package:open_client_http/presentation/provider/environment/environment_key_provider.dart';
import 'package:open_client_http/presentation/provider/environment/environment_provider.dart';
import 'package:open_client_http/presentation/provider/environment/selected_environment_provider.dart';
import 'package:open_client_http/domain/models/environment_key.dart';
import 'package:open_client_http/domain/models/environment.dart';

class EnvironmentKeysScreen extends ConsumerWidget {
  final int environmentId;
  final String returnTo;

  const EnvironmentKeysScreen({
    super.key,
    required this.environmentId,
    required this.returnTo,
  });

  static const String name = "environment_keys_screen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environmentKeysAsync = ref.watch(environmentKeysProvider(environmentId));

    return FutureBuilder<Environment?>(
      future: ref.read(environmentRepositoryProvider).getEnvironmentById(environmentId),
      builder: (context, environmentSnapshot) {
        if (!environmentSnapshot.hasData || environmentSnapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final environment = environmentSnapshot.data!;
        
        return Scaffold(
          appBar: AppBarCustom(
            titleText: environment.name,
            leading: IconButton(
              onPressed: () =>context.go(returnTo),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () => _showCreateEnvironmentKeyBottomSheet(context, ref),
                icon: const Icon(Icons.add),
                tooltip: 'Add Key',
              ),
            ],
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with environment info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        environment.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    environment.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Section title
            Text(
              'Environment Variables',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Keys list
            Expanded(
              child: environmentKeysAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading environment variables',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(environmentKeysProvider(environmentId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (environmentKeys) {
                  if (environmentKeys.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.key_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No environment variables',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first key-value pair to configure this environment',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateEnvironmentKeyBottomSheet(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Variable'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: environmentKeys.length,
                    itemBuilder: (context, index) {
                      final environmentKey = environmentKeys[index];
                      return _EnvironmentKeyCard(
                        environmentKey: environmentKey,
                        onEdit: () => _showEditEnvironmentKeyBottomSheet(context, ref, environmentKey),
                        onDelete: () => _showDeleteConfirmation(context, ref, environmentKey),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: const DrawerCustom(),
    );
      },
    );
  }

  void _showCreateEnvironmentKeyBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateEnvironmentKeyBottomSheet(
        ref: ref,
        environmentId: environmentId,
      ),
    );
  }

  void _showEditEnvironmentKeyBottomSheet(BuildContext context, WidgetRef ref, EnvironmentKey environmentKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditEnvironmentKeyBottomSheet(
        ref: ref,
        environmentKey: environmentKey,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, EnvironmentKey environmentKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Delete Variable'),
        content: Text(
          'Are you sure you want to delete "${environmentKey.key}"? This action cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // Delete the environment key from the database
                await ref.read(environmentKeysProvider(environmentId).notifier).deleteEnvironmentKey(environmentKey);
                
                // Check if this environment is currently selected
                final selectedEnvironment = ref.read(selectedEnvironmentProvider);
                if (selectedEnvironment != null && selectedEnvironment.id == environmentId) {
                  // Refresh the selected environment keys provider to update the state
                  ref.refresh(selectedEnvironmentKeysProvider);
                }
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Variable deleted'),
                      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }
}

class _EnvironmentKeyCard extends StatelessWidget {
  final EnvironmentKey environmentKey;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EnvironmentKeyCard({
    required this.environmentKey,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with key name and menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.vpn_key,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          environmentKey.key,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Value
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
                ),
              ),
                             child: Text(
                 environmentKey.value,
                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                   fontFamily: 'monospace',
                 ),
               ),
             ),
           ],
         ),
       ),
     );
   }
}

class _CreateEnvironmentKeyBottomSheet extends StatefulWidget {
  final WidgetRef ref;
  final int environmentId;

  const _CreateEnvironmentKeyBottomSheet({
    required this.ref,
    required this.environmentId,
  });

  @override
  State<_CreateEnvironmentKeyBottomSheet> createState() => _CreateEnvironmentKeyBottomSheetState();
}

class _CreateEnvironmentKeyBottomSheetState extends State<_CreateEnvironmentKeyBottomSheet> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Text(
                        'Add Environment Variable',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _keyController,
                            decoration: InputDecoration(
                              labelText: 'Key',
                              hintText: 'API_URL, DATABASE_HOST, etc.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.vpn_key),
                            ),
                            style: const TextStyle(fontFamily: 'monospace'),
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                                  return newValue.copyWith(
                                    text: newValue.text.toUpperCase(),
                                    selection: newValue.selection,
                                  );
                                },
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Key is required';
                              }
                              if (!RegExp(r'^[A-Z_][A-Z0-9_]*$').hasMatch(value.trim())) {
                                return 'Key must be uppercase with underscores (e.g., API_URL)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _valueController,
                            decoration: InputDecoration(
                              labelText: 'Value',
                              hintText: 'Enter the value for this key',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.data_object),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            style: const TextStyle(fontFamily: 'monospace'),
                            textAlignVertical: TextAlignVertical.top,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Value is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _createEnvironmentKey,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Add Variable'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _createEnvironmentKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create the environment key in the database
      await widget.ref.read(environmentKeysProvider(widget.environmentId).notifier).createEnvironmentKey(
        _keyController.text.trim(),
        _valueController.text.trim(),
      );

      // Check if this environment is currently selected
      final selectedEnvironment = widget.ref.read(selectedEnvironmentProvider);
      if (selectedEnvironment != null && selectedEnvironment.id == widget.environmentId) {
        // Refresh the selected environment keys provider to update the state
        widget.ref.refresh(selectedEnvironmentKeysProvider);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Environment variable added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _EditEnvironmentKeyBottomSheet extends StatefulWidget {
  final WidgetRef ref;
  final EnvironmentKey environmentKey;

  const _EditEnvironmentKeyBottomSheet({
    required this.ref,
    required this.environmentKey,
  });

  @override
  State<_EditEnvironmentKeyBottomSheet> createState() => _EditEnvironmentKeyBottomSheetState();
}

class _EditEnvironmentKeyBottomSheetState extends State<_EditEnvironmentKeyBottomSheet> {
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.environmentKey.key);
    _valueController = TextEditingController(text: widget.environmentKey.value);
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Text(
                        'Edit Environment Variable',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _keyController,
                            decoration: InputDecoration(
                              labelText: 'Key',
                              hintText: 'API_URL, DATABASE_HOST, etc.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.vpn_key),
                            ),
                            style: const TextStyle(fontFamily: 'monospace'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Key is required';
                              }
                              if (!RegExp(r'^[A-Z_][A-Z0-9_]*$').hasMatch(value.trim())) {
                                return 'Key must be uppercase with underscores (e.g., API_URL)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _valueController,
                            decoration: InputDecoration(
                              labelText: 'Value',
                              hintText: 'Enter the value for this key',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.data_object),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            style: const TextStyle(fontFamily: 'monospace'),
                            textAlignVertical: TextAlignVertical.top,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Value is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _updateEnvironmentKey,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Update Variable'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateEnvironmentKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedEnvironmentKey = widget.environmentKey.copyWith(
        key: _keyController.text.trim(),
        value: _valueController.text.trim(),
      );

      // Update the environment key in the database
      await widget.ref.read(environmentKeysProvider(widget.environmentKey.environmentId).notifier).updateEnvironmentKey(updatedEnvironmentKey);

      // Check if this environment is currently selected
      final selectedEnvironment = widget.ref.read(selectedEnvironmentProvider);
      if (selectedEnvironment != null && selectedEnvironment.id == widget.environmentKey.environmentId) {
        // Refresh the selected environment keys provider to update the state
        widget.ref.refresh(selectedEnvironmentKeysProvider);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Environment variable updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 