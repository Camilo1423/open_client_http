import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/presentation/config/config.dart';
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
        appBar: AppBarCustom(titleText: 'New request'),
        drawer: const DrawerCustom(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [_requestWidget(context, ref)],
          ),
        ),
      ),
    );
  }

  Widget _requestWidget(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          _buildDropdown(context, ref), // Sin Expanded para tamaño fijo
          const SizedBox(width: 5),
          Expanded(
            child: _buildInput(),
          ), // El input toma todo el espacio restante
        ],
      ),
    );
  }

  Widget _buildInput() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        hintText: 'Type your request',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: 48, // Altura fija más compacta
      constraints: const BoxConstraints(maxWidth: 100), // Ancho máximo
      child: CustomDropdown<String>(
        items: httpMethod,
        initialItem: httpMethod[0],
        onChanged: (value) {},
        decoration: CustomDropdownDecoration(
          closedBorder: Border.all(color: theme.colorScheme.outline),
          closedBorderRadius: BorderRadius.circular(8),
          closedSuffixIcon: const SizedBox.shrink(),
          expandedBorder: Border.all(color: theme.colorScheme.outline),
          expandedBorderRadius: BorderRadius.circular(8),
          expandedSuffixIcon: const SizedBox.shrink(),
          closedFillColor: theme.colorScheme.surface,
          expandedFillColor: theme.colorScheme.surface,
        ),
        closedHeaderPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        headerBuilder: (context, selectedItem, enabled) {
          return Text(
            selectedItem,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          );
        },
        listItemBuilder: (context, item, isSelected, onItemSelect) {
          return Text(
            item,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }
}
