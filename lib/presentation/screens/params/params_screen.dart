import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:open_client_http/presentation/widget/widgets.dart';
import 'package:open_client_http/presentation/provider/current_request/current_request_provider.dart';
import 'package:open_client_http/config/constants/headers.dart' as header_constants;

enum ParamType { params, headers }

// Provider para el tipo seleccionado
final selectedParamTypeProvider = StateProvider<ParamType>(
  (ref) => ParamType.params,
);

// Provider para controlar qué parámetro está siendo editado
final editingParameterProvider = StateProvider<String?>((ref) => null);

class ParamsScreen extends ConsumerWidget {
  const ParamsScreen({super.key});

  static const String name = "params_screen";

  // Codificar valor para URL (equivalente a encodeURIComponent)
  String encodeValue(String value) {
    return Uri.encodeComponent(value);
  }

  // Decodificar valor de URL (equivalente a decodeURIComponent)
  String decodeValue(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (e) {
      return value; // Si no se puede decodificar, devolver el valor original
    }
  }

  // Construir URL completa con parámetros
  String buildCompleteUrl(String baseUrl, Map<String, String> queryParams) {
    if (queryParams.isEmpty) return baseUrl;

    final uri = Uri.parse(baseUrl.contains('?') ? baseUrl : baseUrl);
    final existingParams = Map<String, String>.from(uri.queryParameters);
    existingParams.addAll(queryParams);

    final newUri = uri.replace(queryParameters: existingParams);
    return newUri.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentRequest = ref.watch(currentRequestProvider);
    final selectedType = ref.watch(selectedParamTypeProvider);
    final completeUrl = buildCompleteUrl(
      currentRequest.url,
      currentRequest.queryParams,
    );

    return Scaffold(
      appBar: AppBarCustom(
        titleText: 'Parameters',
        leading: _buildLeading(context),
      ),
      drawer: const DrawerCustom(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL Display Section
              _buildUrlSection(context, completeUrl),

              const SizedBox(height: 24),

              // Type Selector (Tabs style)
              _buildTypeSelector(context, ref, selectedType),

              const SizedBox(height: 24),

              // Content based on selection
              if (selectedType == ParamType.params) ...[
                _buildSectionTitle(context, 'Query Parameters'),
                const SizedBox(height: 16),
                _buildParamsSection(context, ref, currentRequest.queryParams),
              ] else ...[
                _buildSectionTitle(context, 'Request Headers'),
                const SizedBox(height: 16),
                _buildHeadersSection(context, ref, currentRequest.headers),
              ],

              const SizedBox(height: 100), // Espacio extra para scroll
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlSection(BuildContext context, String completeUrl) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request URL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxHeight: 120, // Altura máxima de 120px
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: SelectableText(
                completeUrl.isEmpty ? 'No URL specified' : completeUrl,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: completeUrl.isEmpty
                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    WidgetRef ref,
    ParamType selectedType,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeTab(
              context: context,
              ref: ref,
              title: 'Query Parameters',
              icon: Icons.tune,
              type: ParamType.params,
              isSelected: selectedType == ParamType.params,
              isLeft: true,
            ),
          ),
          Expanded(
            child: _buildTypeTab(
              context: context,
              ref: ref,
              title: 'Headers',
              icon: Icons.http,
              type: ParamType.headers,
              isSelected: selectedType == ParamType.headers,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required ParamType type,
    required bool isSelected,
    required bool isLeft,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isLeft ? 11 : 0),
        bottomLeft: Radius.circular(isLeft ? 11 : 0),
        topRight: Radius.circular(!isLeft ? 11 : 0),
        bottomRight: Radius.circular(!isLeft ? 11 : 0),
      ),
      child: InkWell(
        onTap: () {
          // Cancelar edición al cambiar de tab
          ref.read(editingParameterProvider.notifier).state = null;
          ref.read(selectedParamTypeProvider.notifier).state = type;
        },
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 11 : 0),
          bottomLeft: Radius.circular(isLeft ? 11 : 0),
          topRight: Radius.circular(!isLeft ? 11 : 0),
          bottomRight: Radius.circular(!isLeft ? 11 : 0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildParamsSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> params,
  ) {
    return Column(
      children: [
        // Add new parameter inputs
        _buildAddParameterForm(context, ref, true),

        const SizedBox(height: 16),

        // Existing parameters
        if (params.isNotEmpty) ...[
          ...params.entries.map(
            (entry) => _buildExistingParameter(
              context,
              ref,
              entry.key,
              entry.value,
              true,
            ),
          ),
        ] else
          _buildEmptyState(context, 'No query parameters added yet'),
      ],
    );
  }

  Widget _buildHeadersSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> headers,
  ) {
    return Column(
      children: [
        // Add new header inputs
        _buildAddParameterForm(context, ref, false),

        const SizedBox(height: 16),

        // Existing headers
        if (headers.isNotEmpty) ...[
          ...headers.entries.map(
            (entry) => _buildExistingParameter(
              context,
              ref,
              entry.key,
              entry.value,
              false,
            ),
          ),
        ] else
          _buildEmptyState(context, 'No headers added yet'),
      ],
    );
  }

  Widget _buildAddParameterForm(
    BuildContext context,
    WidgetRef ref,
    bool isParam,
  ) {
    final theme = Theme.of(context);
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New ${isParam ? 'Parameter' : 'Header'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (isParam)
            // Para query parameters - comportamiento original
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: keyController,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: valueController,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      final key = keyController.text.trim();
                      final value = valueController.text.trim();

                      if (key.isNotEmpty && value.isNotEmpty) {
                        final encodedValue = encodeValue(value);
                        ref
                            .read(currentRequestProvider.notifier)
                            .addQueryParam(key, encodedValue);
                        keyController.clear();
                        valueController.clear();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            // Para headers - nuevo comportamiento con dropdowns
            _buildHeaderForm(context, ref, keyController, valueController, theme),
        ],
      ),
    );
  }

  Widget _buildHeaderForm(
    BuildContext context,
    WidgetRef ref,
    TextEditingController keyController,
    TextEditingController valueController,
    ThemeData theme,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildHeaderKeyField(
                keyController,
                theme,
                onKeyChanged: (value) {
                  setState(() {
                    // Trigger rebuild to show/hide value dropdown
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildHeaderValueField(
                keyController.text,
                valueController,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  final key = keyController.text.trim();
                  final value = valueController.text.trim();

                  if (key.isNotEmpty && value.isNotEmpty) {
                    ref
                        .read(currentRequestProvider.notifier)
                        .addHeader(key, value);
                    keyController.clear();
                    valueController.clear();
                    setState(() {}); // Rebuild to hide value dropdown
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderKeyField(
    TextEditingController controller,
    ThemeData theme, {
    required ValueChanged<String> onKeyChanged,
  }) {
    return TextField(
      controller: controller,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: onKeyChanged,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Header Key',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
        suffixIcon: PopupMenuButton<String>(
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onSelected: (String value) {
            controller.text = value;
            onKeyChanged(value);
          },
          itemBuilder: (BuildContext context) {
            return header_constants.headers.map((String header) {
              return PopupMenuItem<String>(
                value: header,
                child: Text(header),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderValueField(
    String currentKey,
    TextEditingController controller,
    ThemeData theme,
  ) {
    final hasDropdown = header_constants.genericsHeaders.containsKey(currentKey);
    final values = hasDropdown ? header_constants.genericsHeaders[currentKey]! : <String>[];

    return TextField(
      controller: controller,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Header Value',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
        suffixIcon: hasDropdown
            ? PopupMenuButton<String>(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onSelected: (String value) {
                  controller.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return values.map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildExistingParameter(
    BuildContext context,
    WidgetRef ref,
    String key,
    String value,
    bool isParam,
  ) {
    final theme = Theme.of(context);
    final editingKey = ref.watch(editingParameterProvider);
    final isEditing = editingKey == key;

    // Decodificar el valor para mostrarlo legible al usuario
    final displayValue = isParam ? decodeValue(value) : value;

    if (isEditing) {
      return _buildEditingParameter(context, ref, key, displayValue, isParam);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Botón editar
          Material(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                ref.read(editingParameterProvider.notifier).state = key;
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón eliminar
          Material(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                if (isParam) {
                  ref
                      .read(currentRequestProvider.notifier)
                      .removeQueryParam(key);
                } else {
                  ref.read(currentRequestProvider.notifier).removeHeader(key);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.delete_outline, color: Colors.red, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingParameter(
    BuildContext context,
    WidgetRef ref,
    String originalKey,
    String decodedValue,
    bool isParam,
  ) {
    final theme = Theme.of(context);
    final keyController = TextEditingController(text: originalKey);
    final valueController = TextEditingController(text: decodedValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editing ${isParam ? 'Parameter' : 'Header'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (isParam)
            // Para query parameters - comportamiento original
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: keyController,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: valueController,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón guardar
                Material(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      final newKey = keyController.text.trim();
                      final newValue = valueController.text.trim();

                      if (newKey.isNotEmpty && newValue.isNotEmpty) {
                        final encodedValue = encodeValue(newValue);
                        ref
                            .read(currentRequestProvider.notifier)
                            .removeQueryParam(originalKey);
                        ref
                            .read(currentRequestProvider.notifier)
                            .addQueryParam(newKey, encodedValue);

                        // Salir del modo edición
                        ref.read(editingParameterProvider.notifier).state = null;
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón cancelar
                Material(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      ref.read(editingParameterProvider.notifier).state = null;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            )
          else
            // Para headers - nuevo comportamiento con dropdowns
            _buildEditHeaderForm(context, ref, originalKey, keyController, valueController, theme),
        ],
      ),
    );
  }

  Widget _buildEditHeaderForm(
    BuildContext context,
    WidgetRef ref,
    String originalKey,
    TextEditingController keyController,
    TextEditingController valueController,
    ThemeData theme,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildEditHeaderKeyField(
                keyController,
                theme,
                onKeyChanged: (value) {
                  setState(() {
                    // Trigger rebuild to show/hide value dropdown
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildEditHeaderValueField(
                keyController.text,
                valueController,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            // Botón guardar
            Material(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  final newKey = keyController.text.trim();
                  final newValue = valueController.text.trim();

                  if (newKey.isNotEmpty && newValue.isNotEmpty) {
                    ref
                        .read(currentRequestProvider.notifier)
                        .removeHeader(originalKey);
                    ref
                        .read(currentRequestProvider.notifier)
                        .addHeader(newKey, newValue);

                    // Salir del modo edición
                    ref.read(editingParameterProvider.notifier).state = null;
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón cancelar
            Material(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  ref.read(editingParameterProvider.notifier).state = null;
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditHeaderKeyField(
    TextEditingController controller,
    ThemeData theme, {
    required ValueChanged<String> onKeyChanged,
  }) {
    return TextField(
      controller: controller,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: onKeyChanged,
      decoration: InputDecoration(
        filled: true,
        labelText: 'Header Key',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
        suffixIcon: PopupMenuButton<String>(
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onSelected: (String value) {
            controller.text = value;
            onKeyChanged(value);
          },
          itemBuilder: (BuildContext context) {
            return header_constants.headers.map((String header) {
              return PopupMenuItem<String>(
                value: header,
                child: Text(header),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildEditHeaderValueField(
    String currentKey,
    TextEditingController controller,
    ThemeData theme,
  ) {
    final hasDropdown = header_constants.genericsHeaders.containsKey(currentKey);
    final values = hasDropdown ? header_constants.genericsHeaders[currentKey]! : <String>[];

    return TextField(
      controller: controller,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        filled: true,
        labelText: 'Header Value',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
        suffixIcon: hasDropdown
            ? PopupMenuButton<String>(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onSelected: (String value) {
                  controller.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return values.map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => context.go(RouterPath.home),
      icon: const Icon(Icons.arrow_back),
    );
  }
}
