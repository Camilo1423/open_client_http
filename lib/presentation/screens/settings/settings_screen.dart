import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/presentation/provider/providers.dart';
import 'package:open_client_http/presentation/widget/widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const String name = "settings_screen";

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController connectionTimeoutController;
  late TextEditingController readTimeoutController;
  late TextEditingController writeTimeoutController;

  @override
  void initState() {
    super.initState();
    connectionTimeoutController = TextEditingController();
    readTimeoutController = TextEditingController();
    writeTimeoutController = TextEditingController();
  }

  @override
  void dispose() {
    connectionTimeoutController.dispose();
    readTimeoutController.dispose();
    writeTimeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(changeThemeProvider);
    final historyCleanupState = ref.watch(historyCleanupProvider);
    final timeoutState = ref.watch(timeoutSettingsNotifierProvider);

    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        appBar: const AppBarCustom(titleText: 'Settings'),
        drawer: const DrawerCustom(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Section
              _buildSectionCard(
                title: 'Appearance',
                icon: Icons.palette_outlined,
                child: themeState.when(
                  data: (data) => _buildThemeSelector(data.$1),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // History Cleanup Section
              _buildSectionCard(
                title: 'Request History',
                icon: Icons.history,
                child: historyCleanupState.when(
                  data: (data) => _buildHistoryCleanupSelector(data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Network Timeouts Section
              _buildSectionCard(
                title: 'Network Timeouts',
                icon: Icons.timer_outlined,
                child: timeoutState.when(
                  data: (data) => _buildTimeoutSettings(data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
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

  Widget _buildThemeSelector(String currentTheme) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Theme',
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
            items: const ['light', 'dark', 'system'],
            initialItem: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(changeThemeProvider.notifier).changeTheme(value);
              }
            },
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
              final IconData icon;
              final String displayText;
              
              switch (selectedItem) {
                case 'light':
                  icon = Icons.light_mode;
                  displayText = 'Light';
                  break;
                case 'dark':
                  icon = Icons.dark_mode;
                  displayText = 'Dark';
                  break;
                case 'system':
                  icon = Icons.settings_system_daydream;
                  displayText = 'System';
                  break;
                default:
                  icon = Icons.settings_system_daydream;
                  displayText = 'System';
              }
              
              return Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 12),
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              );
            },
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              final IconData icon;
              final String displayText;
              
              switch (item) {
                case 'light':
                  icon = Icons.light_mode;
                  displayText = 'Light';
                  break;
                case 'dark':
                  icon = Icons.dark_mode;
                  displayText = 'Dark';
                  break;
                case 'system':
                  icon = Icons.settings_system_daydream;
                  displayText = 'System';
                  break;
                default:
                  icon = Icons.settings_system_daydream;
                  displayText = 'System';
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      displayText,
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

  Widget _buildHistoryCleanupSelector(HistoryCleanupOption currentOption) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clear request history',
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
          child: CustomDropdown<HistoryCleanupOption>(
            items: HistoryCleanupOption.values,
            initialItem: currentOption,
            onChanged: (value) {
              if (value != null) {
                ref.read(historyCleanupProvider.notifier).setCleanupOption(value);
              }
            },
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
              final IconData icon;
              
              switch (selectedItem) {
                case HistoryCleanupOption.never:
                  icon = Icons.block;
                  break;
                case HistoryCleanupOption.daily:
                  icon = Icons.today;
                  break;
                case HistoryCleanupOption.weekly:
                  icon = Icons.date_range;
                  break;
                case HistoryCleanupOption.monthly:
                  icon = Icons.calendar_month;
                  break;
              }
              
              return Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 12),
                  Text(
                    selectedItem.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              );
            },
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              final IconData icon;
              
              switch (item) {
                case HistoryCleanupOption.never:
                  icon = Icons.block;
                  break;
                case HistoryCleanupOption.daily:
                  icon = Icons.today;
                  break;
                case HistoryCleanupOption.weekly:
                  icon = Icons.date_range;
                  break;
                case HistoryCleanupOption.monthly:
                  icon = Icons.calendar_month;
                  break;
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      item.displayName,
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

  Widget _buildTimeoutSettings(TimeoutSettings settings) {
    // Update controllers when settings change
    if (connectionTimeoutController.text != settings.connectionTimeout.toString()) {
      connectionTimeoutController.text = settings.connectionTimeout.toString();
    }
    if (readTimeoutController.text != settings.readTimeout.toString()) {
      readTimeoutController.text = settings.readTimeout.toString();
    }
    if (writeTimeoutController.text != settings.writeTimeout.toString()) {
      writeTimeoutController.text = settings.writeTimeout.toString();
    }

    return Column(
      children: [
        _buildTimeoutInput(
          label: 'Connection Timeout (sec)',
          controller: connectionTimeoutController,
          icon: Icons.wifi,
          onChanged: (value) {
            final timeout = int.tryParse(value);
            if (timeout != null && timeout > 0) {
              ref.read(timeoutSettingsNotifierProvider.notifier)
                  .updateConnectionTimeout(timeout);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTimeoutInput(
          label: 'Read Timeout (sec)',
          controller: readTimeoutController,
          icon: Icons.download,
          onChanged: (value) {
            final timeout = int.tryParse(value);
            if (timeout != null && timeout > 0) {
              ref.read(timeoutSettingsNotifierProvider.notifier)
                  .updateReadTimeout(timeout);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTimeoutInput(
          label: 'Write Timeout (sec)',
          controller: writeTimeoutController,
          icon: Icons.upload,
          onChanged: (value) {
            final timeout = int.tryParse(value);
            if (timeout != null && timeout > 0) {
              ref.read(timeoutSettingsNotifierProvider.notifier)
                  .updateWriteTimeout(timeout);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimeoutInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            hintText: 'Enter timeout in seconds',
            suffixText: 'sec',
            suffixStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
