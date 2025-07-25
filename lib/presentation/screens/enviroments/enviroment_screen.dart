import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/provider/environment/selected_environment_provider.dart';
import 'package:open_client_http/presentation/router/index.dart';
import 'package:open_client_http/presentation/widget/shared/app_bar.dart';
import 'package:open_client_http/presentation/widget/shared/drawer.dart';
import 'package:open_client_http/presentation/provider/environment/environment_provider.dart';
import 'package:open_client_http/domain/models/environment.dart';

class EnviromentScreen extends ConsumerWidget {
  const EnviromentScreen({super.key});

  static const String name = "enviroment_screen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environmentsAsync = ref.watch(environmentsProvider);

    return Scaffold(
      appBar: AppBarCustom(
        titleText: 'Environments',
        actions: [
          IconButton(
            onPressed: () => _showCreateEnvironmentDialog(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'Create Environment',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Your Environments',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Lista de environments
            Expanded(
              child: environmentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
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
                        'Error loading environments',
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
                        onPressed: () => ref.refresh(environmentsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (environments) {
                  if (environments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No environments',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first environment to organize your configurations',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showCreateEnvironmentDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Environment'),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: environments.length,
                    itemBuilder: (context, index) {
                      final environment = environments[index];
                      return _EnvironmentCard(
                        environment: environment,
                        onTap: () =>
                            _navigateToEnvironmentKeys(context, environment),
                        onEdit: () => _showEditEnvironmentDialog(
                          context,
                          ref,
                          environment,
                        ),
                        onDelete: () =>
                            _showDeleteConfirmation(context, ref, environment),
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
  }

  void _navigateToEnvironmentKeys(
    BuildContext context,
    Environment environment,
  ) {
    // Navigate to environment keys screen
    context.push(
      '/environments/${environment.id}/keys',
      extra: {'returnTo': RouterPath.environments},
    );
  }

  void _showCreateEnvironmentDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateEnvironmentBottomSheet(ref: ref),
    );
  }

  void _showEditEnvironmentDialog(
    BuildContext context,
    WidgetRef ref,
    Environment environment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _EditEnvironmentBottomSheet(ref: ref, environment: environment),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Environment environment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Delete Environment'),
        content: Text(
          'Are you sure you want to delete "${environment.name}"? This action cannot be undone.',
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
                await ref
                    .read(environmentsProvider.notifier)
                    .deleteEnvironment(environment.id!);

                final selectedEnvironment = ref.read(
                  selectedEnvironmentProvider,
                );
                if (selectedEnvironment != null &&
                    selectedEnvironment.id == environment.id) {
                  // Refresh the selected environment keys provider to update the state
                  ref.read(selectedEnvironmentProvider.notifier).state = null;
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Environment deleted'),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.inverseSurface,
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

class _EnvironmentCard extends StatelessWidget {
  final Environment environment;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EnvironmentCard({
    required this.environment,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y menú
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.folder,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
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

              // Nombre del environment
              Text(
                environment.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Descripción
              Expanded(
                child: Text(
                  environment.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateEnvironmentBottomSheet extends StatefulWidget {
  final WidgetRef ref;

  const _CreateEnvironmentBottomSheet({required this.ref});

  @override
  State<_CreateEnvironmentBottomSheet> createState() =>
      _CreateEnvironmentBottomSheetState();
}

class _CreateEnvironmentBottomSheetState
    extends State<_CreateEnvironmentBottomSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Text(
                        'Create Environment',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
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
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter environment name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.label_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter environment description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                Icons.description_outlined,
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            textAlignVertical: TextAlignVertical.top,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
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
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
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
                          onPressed: _isLoading ? null : _createEnvironment,
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
                              : const Text(
                                  'Create Environment',
                                  style: TextStyle(color: Colors.white),
                                ),
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

  Future<void> _createEnvironment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.ref
          .read(environmentsProvider.notifier)
          .createEnvironment(
            _nameController.text.trim(),
            _descriptionController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Environment created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _EditEnvironmentBottomSheet extends StatefulWidget {
  final WidgetRef ref;
  final Environment environment;

  const _EditEnvironmentBottomSheet({
    required this.ref,
    required this.environment,
  });

  @override
  State<_EditEnvironmentBottomSheet> createState() =>
      _EditEnvironmentBottomSheetState();
}

class _EditEnvironmentBottomSheetState
    extends State<_EditEnvironmentBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.environment.name);
    _descriptionController = TextEditingController(
      text: widget.environment.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Text(
                        'Edit Environment',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
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
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter environment name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.label_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter environment description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                Icons.description_outlined,
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            textAlignVertical: TextAlignVertical.top,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
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
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
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
                          onPressed: _isLoading ? null : _updateEnvironment,
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
                              : const Text('Update Environment'),
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

  Future<void> _updateEnvironment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedEnvironment = widget.environment.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      await widget.ref
          .read(environmentsProvider.notifier)
          .updateEnvironment(updatedEnvironment);

      final selectedEnvironment = widget.ref.read(
        selectedEnvironmentProvider,
      );
      if (selectedEnvironment != null &&
          selectedEnvironment.id == updatedEnvironment.id) {
        widget.ref.read(selectedEnvironmentProvider.notifier).state =
            updatedEnvironment;
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Environment updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
