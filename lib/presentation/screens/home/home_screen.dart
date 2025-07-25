import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/config/config.dart';
import 'package:open_client_http/presentation/provider/providers.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:open_client_http/presentation/widget/widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String name = "home_screen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBarCustom(
          titleText: 'New request',
          actions: [_buildActions(context, ref)],
        ),
        drawer: const DrawerCustom(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _requestWidget(context, ref),
                const SizedBox(height: 20),
                _environmentSelector(context, ref),
                const SizedBox(height: 20),
                _sectionTitle('Quick Actions'),
                const SizedBox(height: 12),
                _quickActionButtons(context),
                const SizedBox(height: 20),
                _sectionTitle('Request Body'),
                const SizedBox(height: 12),
                // Raw body widget with fixed height
                SizedBox(height: 350, child: _rawBodyWidget(context, ref)),
                const SizedBox(height: 24),
                // Send button now part of the scrollable content
                _sendButton(context, ref),
                const SizedBox(height: 16), // Extra space at bottom
              ],
            ),
          ),
        ),
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

  Widget _quickActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _paramsButton(context)),
        const SizedBox(width: 16),
        Expanded(child: _authorizationButton(context)),
      ],
    );
  }

  Widget _paramsButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(RouterPath.params),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Parameters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Query & Headers',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
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

  Widget _authorizationButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(RouterPath.authorization),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Authorization',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Auth Methods',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
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

  Widget _sendButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(isRequestLoadingProvider);

    // Escuchar errores y navegación solo una vez (no en cada build)
    ref.listen(requestErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request failed: $next'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    ref.listen(requestExecutionProvider, (previous, next) {
      if (previous?.state != RequestState.success &&
          next.state == RequestState.success) {
        context.go(RouterPath.renderResponse);
      }
    });

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  final request = ref.read(currentRequestProvider);
                  final isAvailableRequest = ref.watch(
                    isAvailableRequestProvider,
                  );

                  // Validar antes de ejecutar la petición usando isAvailableRequestProvider
                  if (isAvailableRequest.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isAvailableRequest == ''
                              ? 'Please enter a valid URL'
                              : isAvailableRequest,
                        ),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                    return;
                  }

                  // Validación extra por si acaso (opcional)
                  if (request.url.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please enter a valid URL'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                    return;
                  }

                  // Ejecutar la petición solo si la validación pasa
                  await ref
                      .read(requestExecutionProvider.notifier)
                      .executeRequest(request);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Send Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _requestWidget(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request Configuration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDropdown(context, ref),
            const SizedBox(width: 12),
            Expanded(child: _buildInput(context, ref)),
          ],
        ),
      ],
    );
  }

  Widget _environmentSelector(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedEnvironment = ref.watch(selectedEnvironmentProvider);
    final environmentsAsync = ref.watch(environmentsProvider);
    final keysAsync = ref.watch(selectedEnvironmentKeysProvider);
    final urlContainsVariables = ref.watch(urlContainsVariablesProvider);
    final interpolatedUrl = ref.watch(interpolatedUrlProvider);
    final detectedVariables = ref.watch(detectedVariablesProvider);
    final environmentKeysMap = ref.watch(selectedEnvironmentKeysMapProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show URL preview and variable info if variables are detected
        if (urlContainsVariables) ...[
          _buildUrlPreview(
            context,
            interpolatedUrl,
            detectedVariables,
            environmentKeysMap,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Text(
              'Environment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            if (keysAsync.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        environmentsAsync.when(
          loading: () => Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.error),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: Center(
              child: Text(
                'Error loading environments',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
          data: (environments) {
            // Add "No Environment" option
            final environmentOptions = <String>['No Environment'];
            environmentOptions.addAll(environments.map((env) => env.name));

            final selectedValue = selectedEnvironment?.name ?? 'No Environment';

            return CustomDropdown<String>(
              items: environmentOptions,
              initialItem: selectedValue,
              onChanged: (value) {
                if (value == 'No Environment') {
                  ref.read(selectedEnvironmentProvider.notifier).state = null;
                } else {
                  final selectedEnv = environments.firstWhere(
                    (env) => env.name == value,
                  );
                  ref.read(selectedEnvironmentProvider.notifier).state =
                      selectedEnv;
                }
              },
              decoration: CustomDropdownDecoration(
                closedBorder: Border.all(color: theme.colorScheme.outline),
                closedBorderRadius: BorderRadius.circular(12),
                closedSuffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                expandedBorder: Border.all(color: theme.colorScheme.outline),
                expandedBorderRadius: BorderRadius.circular(12),
                expandedSuffixIcon: Icon(
                  Icons.keyboard_arrow_up,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                closedFillColor: theme.colorScheme.surface,
                expandedFillColor: theme.colorScheme.surface,
              ),
              closedHeaderPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              headerBuilder: (context, selectedItem, enabled) {
                return Row(
                  children: [
                    Icon(
                      selectedItem == 'No Environment'
                          ? Icons.layers_clear
                          : Icons.folder,
                      size: 20,
                      color: selectedItem == 'No Environment'
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedItem,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedItem == 'No Environment'
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                )
                              : theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
              listItemBuilder: (context, item, isSelected, onItemSelect) {
                final isNoEnvironment = item == 'No Environment';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isNoEnvironment ? Icons.layers_clear : Icons.folder,
                        size: 20,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : isNoEnvironment
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),

        // Show loaded keys info and preview
        if (selectedEnvironment != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: keysAsync.when(
              loading: () => Text(
                'Loading variables...',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              error: (error, stack) => Text(
                'Error loading variables',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
              ),
              data: (keys) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${keys.length} variable${keys.length != 1 ? 's' : ''} loaded',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (keys.isNotEmpty)
                        InkWell(
                          onTap: () => context.push(
                            '/environments/${selectedEnvironment.id}/keys',
                            extra: {'returnTo': RouterPath.home},
                          ),
                          child: Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (keys.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show first 3 variables as preview
                          ...keys
                              .take(3)
                              .map(
                                (key) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${key.key}:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          key.value.length > 30
                                              ? '${key.value.substring(0, 30)}...'
                                              : key.value,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                            color: theme.colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          // Show "and X more" if there are more variables
                          if (keys.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '... and ${keys.length - 3} more',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInput(BuildContext context, WidgetRef ref) {
    final displayUrl = ref.watch(displayUrlProvider);

    return Column(
      children: [
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (value) {
            ref
                .read(currentRequestProvider.notifier)
                .updateUrlWithParsing(value);
          },
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: displayUrl,
              selection: TextSelection.collapsed(offset: displayUrl.length),
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            hintText:
                'Enter API endpoint URL (use {{VARIABLE_NAME}} for environment variables)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlPreview(
    BuildContext context,
    String interpolatedUrl,
    List<String> detectedVariables,
    Map<String, String> environmentKeysMap,
  ) {
    final theme = Theme.of(context);

    // Check which variables are missing
    final missingVariables = detectedVariables
        .where((variable) => !environmentKeysMap.containsKey(variable))
        .toList();
    final hasValidEnvironment = environmentKeysMap.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: missingVariables.isNotEmpty
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.1)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: missingVariables.isNotEmpty
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                missingVariables.isNotEmpty
                    ? Icons.warning_rounded
                    : Icons.preview_rounded,
                size: 16,
                color: missingVariables.isNotEmpty
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  missingVariables.isNotEmpty
                      ? 'URL Preview (Missing Variables)'
                      : 'URL Preview with Variables',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: missingVariables.isNotEmpty
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Show interpolated URL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              interpolatedUrl.isNotEmpty
                  ? interpolatedUrl
                  : 'Invalid URL with variables',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Show variable status
          if (detectedVariables.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: detectedVariables.map((variable) {
                final isAvailable = environmentKeysMap.containsKey(variable);
                final value = environmentKeysMap[variable];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAvailable
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAvailable ? Icons.check_circle : Icons.error,
                        size: 12,
                        color: isAvailable
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        variable,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: isAvailable
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                      if (isAvailable && value != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '= ${value.length > 15 ? '${value.substring(0, 15)}...' : value}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Show help message if no environment is selected
          if (!hasValidEnvironment && detectedVariables.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Select an environment above to resolve variables',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMethod = ref.watch(currentMethodProvider);

    return Container(
      height: 56,
      constraints: const BoxConstraints(maxWidth: 110),
      child: CustomDropdown<String>(
        items: httpMethod,
        initialItem: currentMethod,
        onChanged: (value) {
          if (value != null) {
            ref.read(currentRequestProvider.notifier).updateMethod(value);
          }
        },
        decoration: CustomDropdownDecoration(
          closedBorder: Border.all(color: theme.colorScheme.outline),
          closedBorderRadius: BorderRadius.circular(12),
          closedSuffixIcon: const SizedBox.shrink(),
          expandedBorder: Border.all(color: theme.colorScheme.outline),
          expandedBorderRadius: BorderRadius.circular(12),
          expandedSuffixIcon: const SizedBox.shrink(),
          closedFillColor: theme.colorScheme.surface,
          expandedFillColor: theme.colorScheme.surface,
        ),
        closedHeaderPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        headerBuilder: (context, selectedItem, enabled) {
          return Text(
            selectedItem,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          );
        },
        listItemBuilder: (context, item, isSelected, onItemSelect) {
          return Text(
            item,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  Widget _rawBodyWidget(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rawBody = ref.watch(currentRawBodyProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        color: theme.colorScheme.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(RouterPath.rawEditor),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.data_object_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Raw Body',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: rawBody.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_add_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No request body',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to add content',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                            ),
                            child: Text(
                              rawBody,
                              style: TextStyle(
                                fontFamily: 'Courier New',
                                fontSize: 13,
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          tooltip: 'View history',
          icon: const Icon(Icons.history),
          onPressed: () {
            context.go(RouterPath.history);
          },
        ),
        // Icono para guardar la request
        IconButton(
          tooltip: 'Save request',
          icon: const Icon(Icons.save),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Request guardada')));
          },
        ),
        // Icono para limpiar la request
        IconButton(
          tooltip: 'Clear request',
          icon: const Icon(Icons.clear),
          onPressed: () {
            ref.read(currentRequestProvider.notifier).reset();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Request limpiada')));
          },
        ),
      ],
    );
  }
}
