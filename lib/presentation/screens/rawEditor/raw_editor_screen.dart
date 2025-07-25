import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/helpers/json_duplicate_keys_checker.dart';
import 'package:open_client_http/presentation/provider/providers.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:open_client_http/presentation/widget/widgets.dart';

class RawEditorScreen extends ConsumerStatefulWidget {
  const RawEditorScreen({super.key});

  static const String name = "raw_editor_screen";

  @override
  ConsumerState<RawEditorScreen> createState() => _RawEditorScreenState();
}

class _RawEditorScreenState extends ConsumerState<RawEditorScreen> {
  late TextEditingController _textController;
  bool _isValidJson = false;
  bool _hasContent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    // Inicializar el controller con el contenido actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentBody = ref.read(currentRawBodyProvider);
      _textController.text = currentBody;
      _validateJson(currentBody);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _validateJson(String text) {
    String trimmedText = text.trim();

    setState(() {
      _hasContent = trimmedText.isNotEmpty;
    });

    if (trimmedText.isEmpty) {
      setState(() {
        _isValidJson = false;
      });
      return;
    }

    try {
      // Intentar decodificar el JSON
      final tempEnv = <String, String>{};

      trimmedText = _replaceVariablesWithRandomKeys(trimmedText, tempEnv);

      final decoded = jsonDecode(trimmedText);

      if (JsonDuplicateKeyChecker(trimmedText).hasDuplicateKeys()) {
        setState(() {
          _isValidJson = false;
          _errorMessage = 'The JSON has duplicate keys';
        });
        return;
      }

      trimmedText = _replaceRandomKeysWithVariables(trimmedText, tempEnv);

      // Verificar que sea un objeto o array válido
      if (decoded is Map || decoded is List) {
        setState(() {
          _isValidJson = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isValidJson = false;
          _errorMessage = 'The JSON is not valid';
        });
      }
    } catch (e) {
      setState(() {
        _isValidJson = false;
        _errorMessage = 'The JSON is not valid';
      });
    }
  }

  void _insertText(String text) {
    final currentPosition = _textController.selection.start;
    final currentText = _textController.text;

    if (currentPosition == -1) {
      // Si no hay selección, insertar al final
      _textController.text = currentText + text;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    } else {
      // Insertar en la posición del cursor
      final newText =
          currentText.substring(0, currentPosition) +
          text +
          currentText.substring(currentPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentPosition + text.length),
      );
    }

    // Actualizar el provider y validar JSON
    ref
        .read(currentRequestProvider.notifier)
        .updateRawBody(_textController.text);
    _validateJson(_textController.text);
  }

  void _beautifyJson() {
    String currentText = _textController.text.trim();

    // Verificar que no esté vacío
    if (currentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No content to format'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final tempEnv = <String, String>{};

      currentText = _replaceVariablesWithRandomKeys(currentText, tempEnv);

      // Intentar decodificar el JSON
      final jsonObject = jsonDecode(currentText);

      // Formatear con indentación
      String prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonObject);

      prettyJson = _replaceRandomKeysWithVariables(prettyJson, tempEnv);

      // Actualizar el texto del controller
      _textController.value = TextEditingValue(
        text: prettyJson,
        selection: TextSelection.collapsed(offset: prettyJson.length),
      );

      // Actualizar el provider
      ref.read(currentRequestProvider.notifier).updateRawBody(prettyJson);

      // Revalidar después del formateo
      _validateJson(prettyJson);

      // Mostrar feedback
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'JSON formatted successfully (${prettyJson.split('\n').length} lines)',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      // Mostrar error específico
      _validateJson(currentText); // Re-validar para actualizar el estado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid JSON: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _replaceVariablesWithRandomKeys(
    String currentText,
    Map<String, String> tempEnv,
  ) {
    final variableRegex = RegExp(r'\{\{([A-Z_][A-Z0-9_]*)\}\}');

    // Reemplaza cada variable {{VARIABLE_NAME}} por un valor string válido para JSON
    // Si la variable ya está envuelta en comillas, solo agrega la random key, si no, la envuelve en comillas
    currentText = currentText.replaceAllMapped(variableRegex, (match) {
      final key = match.group(1)!;
      final randomKey = 'RANDOM_KEY_${Random().nextInt(1000000)}';

      // Detectar si la variable está envuelta en comillas
      // match.start y match.end nos dan la posición de la variable en el texto original
      final start = match.start;
      final end = match.end;

      // Buscar el carácter antes y después de la variable (ignorando espacios)
      bool isWrappedInQuotes = false;
      if (start > 0 && end < currentText.length) {
        // Busca hacia atrás el primer caracter no espacio antes de start
        int i = start - 1;
        while (i >= 0 && currentText[i].trim().isEmpty) {
          i--;
        }
        final before = (i >= 0) ? currentText[i] : null;

        // Busca hacia adelante el primer caracter no espacio después de end-1
        int j = end;
        while (j < currentText.length && currentText[j].trim().isEmpty) {
          j++;
        }
        final after = (j < currentText.length) ? currentText[j] : null;

        // Si antes y después hay comillas, consideramos que está envuelta
        if (before == '"' && after == '"') {
          isWrappedInQuotes = true;
        }
      }

      if (isWrappedInQuotes) {
        // Si ya está envuelta en comillas, solo ponemos la random key
        tempEnv[randomKey] = "$key|-wrapped";
        return randomKey;
      } else {
        // Si no está envuelta, la envolvemos en comillas
        tempEnv[randomKey] = "$key|-notwrapped";
        return '"$randomKey"';
      }
    });

    return currentText;
  }

  String _replaceRandomKeysWithVariables(
    String currentText,
    Map<String, String> tempEnv,
  ) {
    // Reemplaza los random keys por las variables originales, quitando las comillas si están presentes
    for (final key in tempEnv.keys) {
      final splitKey = tempEnv[key]!.split('|-');
      final isWrapped = splitKey.length > 1 && splitKey[1] == 'wrapped';

      final variable = '{{${splitKey[0]}}}';
      // Primero reemplaza las ocurrencias con comillas
      if (isWrapped) {
        currentText = currentText.replaceAll(key, variable);
      } else {
        currentText = currentText.replaceAll('"$key"', variable);
      }
    }
    return currentText;
  }

  Widget _buildHelperButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            minimumSize: const Size(0, 36),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16),
                const SizedBox(width: 4),
              ],
              Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBarCustom(
          titleText: 'Raw Editor',
          leading: _buildLeading(context),
        ),
        body: Column(
          children: [
            // Helper buttons section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JSON Helper Tools',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildHelperButton(
                        text: 'Text',
                        onPressed: () => _insertText('"text"'),
                        icon: Icons.text_fields,
                      ),
                      _buildHelperButton(
                        text: '{}',
                        onPressed: () => _insertText('{\n  \n}'),
                        icon: Icons.data_object,
                      ),
                      _buildHelperButton(
                        text: '[]',
                        onPressed: () => _insertText('[\n  \n]'),
                        icon: Icons.data_array,
                      ),
                      _buildHelperButton(
                        text: ':',
                        onPressed: () => _insertText(': '),
                        icon: Icons.more_vert,
                      ),
                      _buildHelperButton(
                        text: 'Beauty',
                        onPressed: _beautifyJson,
                        isEnabled: _hasContent && _isValidJson,
                        icon: Icons.auto_fix_high,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Text editor section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status indicator
                    Row(
                      children: [
                        Text(
                          'Request Body',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (_hasContent) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: _isValidJson
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    )
                                  : theme.colorScheme.error.withValues(
                                      alpha: 0.1,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isValidJson
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      )
                                    : theme.colorScheme.error.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isValidJson
                                      ? Icons.check_circle
                                      : Icons.error,
                                  size: 12,
                                  color: _isValidJson
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isValidJson ? 'Valid JSON' : 'Invalid JSON',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _isValidJson
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!_hasContent) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.text_snippet_outlined,
                                  size: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Empty content',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_errorMessage != null && _hasContent) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Text area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            fontFamily: 'Courier New',
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Enter your raw request body here...\n\nExample:\n{\n  "key": "value",\n  "array": [1, 2, 3]\n}',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontFamily: 'Courier New',
                              fontWeight: FontWeight.w600,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            // Actualizar el provider en tiempo real
                            ref
                                .read(currentRequestProvider.notifier)
                                .updateRawBody(value);
                            _validateJson(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
