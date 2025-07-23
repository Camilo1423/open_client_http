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
        appBar: AppBarCustom(
          titleText: 'New request',
          actions: [_buildActions(context, ref)],
        ),
        drawer: const DrawerCustom(),
        body: Column(
          children: [
            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _requestWidget(context, ref),
                      const SizedBox(height: 20),
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 12),
                      _quickActionButtons(context),
                      const SizedBox(height: 20), // Espacio extra al final
                    ],
                  ),
                ),
              ),
            ),
            // Botón fijo al final
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: _sendButton(context, ref),
              ),
            ),
          ],
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
        color: theme.colorScheme.primary.withOpacity(0.08),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
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
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
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
        color: theme.colorScheme.secondary.withOpacity(0.08),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
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
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
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
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final request = ref.read(currentRequestProvider);
            // TODO: Implement send request logic
            print('Sending request: $request');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send_rounded,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Send Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
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
            Expanded(child: _buildInput(ref)),
          ],
        ),
      ],
    );
  }

  Widget _buildInput(WidgetRef ref) {
    final displayUrl = ref.watch(displayUrlProvider);

    return TextField(
      autocorrect: false,
      enableSuggestions: false,
      onChanged: (value) {
        ref.read(currentRequestProvider.notifier).updateUrlWithParsing(value);
      },
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: displayUrl,
          selection: TextSelection.collapsed(offset: displayUrl.length),
        ),
      ),
      decoration: InputDecoration(
        filled: true,
        hintText: 'Enter API endpoint URL',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          tooltip: 'View history',
          icon: const Icon(Icons.history),
          onPressed: () {
            // TODO: Navegar a la pantalla de historial
            context.go(RouterPath.history); // Asegúrate de tener esta ruta
          },
        ),
        // Icono para guardar la request
        IconButton(
          tooltip: 'Save request',
          icon: const Icon(Icons.save),
          onPressed: () {
            // TODO: Implementar lógica para guardar la request
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
