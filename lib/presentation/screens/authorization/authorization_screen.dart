import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/config/constants/authorize_method.dart';
import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/presentation/provider/current_request/current_request_provider.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:open_client_http/presentation/widget/widgets.dart';

class AuthorizationScreen extends ConsumerStatefulWidget {
  const AuthorizationScreen({super.key});

  static const String name = "authorization_screen";

  @override
  ConsumerState<AuthorizationScreen> createState() =>
      _AuthorizationScreenState();
}

class _AuthorizationScreenState extends ConsumerState<AuthorizationScreen> {
  late TextEditingController _tokenController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AuthorizationMethod _stringToAuthMethod(String authString) {
    switch (authString) {
      case 'Basic Auth':
        return AuthorizationMethod.basicAuth;
      case 'Bearer Token':
        return AuthorizationMethod.bearerToken;
      case 'No Auth':
      default:
        return AuthorizationMethod.none;
    }
  }

  String _authMethodToString(AuthorizationMethod method) {
    switch (method) {
      case AuthorizationMethod.basicAuth:
        return 'Basic Auth';
      case AuthorizationMethod.bearerToken:
        return 'Bearer Token';
      case AuthorizationMethod.none:
      default:
        return 'No Auth';
    }
  }

  void _onAuthMethodChanged(String? newMethod) {
    if (newMethod == null) return;

    final authMethod = _stringToAuthMethod(newMethod);
    final notifier = ref.read(currentRequestProvider.notifier);

    // Actualizar el método de autorización
    notifier.updateAuthMethod(authMethod);

    // Limpiar estados según la selección
    switch (authMethod) {
      case AuthorizationMethod.none:
        // Limpiar todo
        notifier.clearAuth();
        _clearAllControllers();
        break;
      case AuthorizationMethod.basicAuth:
        // Limpiar Bearer Token pero mantener Basic Auth si existe
        notifier.updateAuthToken(null);
        _tokenController.clear();
        break;
      case AuthorizationMethod.bearerToken:
        // Limpiar Basic Auth pero mantener Bearer Token si existe
        notifier.updateBasicAuth(null, null);
        _usernameController.clear();
        _passwordController.clear();
        break;
      case AuthorizationMethod.apiKey:
        // No está en las opciones actuales, pero por completitud
        break;
    }
  }

  void _clearAllControllers() {
    _tokenController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentRequest = ref.watch(currentRequestProvider);
    final currentAuthMethod = _authMethodToString(currentRequest.authMethod);

    // Sincronizar controladores con el estado actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentRequest.authToken != null &&
          _tokenController.text != currentRequest.authToken) {
        _tokenController.text = currentRequest.authToken!;
      }
      if (currentRequest.authUsername != null &&
          _usernameController.text != currentRequest.authUsername) {
        _usernameController.text = currentRequest.authUsername!;
      }
      if (currentRequest.authPassword != null &&
          _passwordController.text != currentRequest.authPassword) {
        _passwordController.text = currentRequest.authPassword!;
      }
    });

    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBarCustom(
          titleText: 'Authorization',
          leading: _buildLeading(context),
        ),
        drawer: const DrawerCustom(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Authentication Type Section
              _buildSectionCard(
                title: 'Authentication Type',
                icon: Icons.security_rounded,
                child: _buildAuthMethodSelector(currentAuthMethod),
              ),

              const SizedBox(height: 16),

              // Authentication Configuration Section
              _buildSectionCard(
                title: 'Configuration',
                icon: _getConfigIcon(currentRequest.authMethod),
                child: _buildAuthFields(currentRequest.authMethod),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethodSelector(String currentAuthMethod) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select authentication method',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomDropdown<String>(
            items: authorizeMethod,
            initialItem: currentAuthMethod,
            onChanged: _onAuthMethodChanged,
            decoration: CustomDropdownDecoration(
              closedBorder: Border.all(color: Colors.transparent),
              closedBorderRadius: BorderRadius.circular(12),
              closedSuffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurface,
              ),
              expandedBorder: Border.all(color: Colors.transparent),
              expandedBorderRadius: BorderRadius.circular(12),
              expandedSuffixIcon: Icon(
                Icons.keyboard_arrow_up,
                color: theme.colorScheme.onSurface,
              ),
              closedFillColor: theme.colorScheme.surface,
              expandedFillColor: theme.colorScheme.surface,
            ),
            closedHeaderPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            headerBuilder: (context, selectedItem, enabled) {
              final IconData icon = _getMethodIcon(selectedItem);

              return Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 12),
                  Text(
                    selectedItem,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              );
            },
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              final IconData icon = _getMethodIcon(item);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'Basic Auth':
        return Icons.person_rounded;
      case 'Bearer Token':
        return Icons.key_rounded;
      case 'No Auth':
      default:
        return Icons.no_encryption_rounded;
    }
  }

  IconData _getConfigIcon(AuthorizationMethod method) {
    switch (method) {
      case AuthorizationMethod.basicAuth:
        return Icons.person_rounded;
      case AuthorizationMethod.bearerToken:
        return Icons.key_rounded;
      case AuthorizationMethod.none:
      default:
        return Icons.settings_rounded;
    }
  }

  Widget _buildAuthFields(AuthorizationMethod authMethod) {
    switch (authMethod) {
      case AuthorizationMethod.basicAuth:
        return _buildBasicAuthFields();
      case AuthorizationMethod.bearerToken:
        return _buildBearerTokenFields();
      case AuthorizationMethod.none:
      default:
        return _buildNoAuthFields();
    }
  }

  Widget _buildNoAuthFields() {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.no_encryption_rounded,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'No Authentication',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your requests will be sent without authentication headers',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBasicAuthFields() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            hintText: 'Enter username',
          ),
          onChanged: (value) {
            final notifier = ref.read(currentRequestProvider.notifier);
            notifier.updateBasicAuth(
              value.isEmpty ? null : value,
              _passwordController.text.isEmpty
                  ? null
                  : _passwordController.text,
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Password',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            hintText: 'Enter password',
          ),
          onChanged: (value) {
            final notifier = ref.read(currentRequestProvider.notifier);
            notifier.updateBasicAuth(
              _usernameController.text.isEmpty
                  ? null
                  : _usernameController.text,
              value.isEmpty ? null : value,
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Basic Auth will be encoded as Base64 and sent in the Authorization header',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBearerTokenFields() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bearer Token',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tokenController,
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Icon(
                Icons.key_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            hintText: 'Enter your bearer token',
            alignLabelWithHint: true,
          ),
          onChanged: (value) {
            final notifier = ref.read(currentRequestProvider.notifier);
            notifier.updateAuthToken(value.isEmpty ? null : value);
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bearer token will be sent in the Authorization header as "Bearer <token>"',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => context.go(RouterPath.home),
      icon: const Icon(Icons.arrow_back),
    );
  }
}
