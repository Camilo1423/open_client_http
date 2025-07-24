import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:share_plus/share_plus.dart';

class DrawerCustom extends StatelessWidget {
  const DrawerCustom({super.key});

  // Función para compartir el link de GitHub
  void _shareGitHubLink() {
    const gitHubUrl = 'https://github.com/Camilo1423/open_client_http';
    const message = 'Check out Open Client HTTP! 🚀\n\nA professional tool for API testing.\n\n$gitHubUrl\n\n#APITesting #OpenSource #Flutter';
    
    Share.share(
      message,
      subject: 'Open Client HTTP - API Testing Tool',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).fullPath;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      width: 280,
      child: Column(
        children: [
          // Header más elegante
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.http,
                            size: 20,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Open Client HTTP',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'API Testing Tool',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menú principal
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                                _buildMenuSection(context, 'WORKSPACE'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.layers_outlined,
                  title: 'Environments',
                  isSelected: currentLocation == RouterPath.environments,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouterPath.environments);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.folder_outlined,
                  title: 'Collections',
                  isSelected: currentLocation == RouterPath.collections,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouterPath.collections);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.http_outlined,
                  title: 'Requests',
                  isSelected: currentLocation == RouterPath.requests || currentLocation == RouterPath.home,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouterPath.home);
                  },
                ),
                
                const SizedBox(height: 16),
                _buildMenuSection(context, 'TOOLS'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.code_outlined,
                  title: 'Raw Editor',
                  isSelected: currentLocation == RouterPath.rawEditor,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouterPath.rawEditor);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.share_outlined,
                  title: 'Shared',
                  isSelected: false, // Ya no se selecciona porque no navega
                  onTap: () {
                    Navigator.pop(context);
                    _shareGitHubLink();
                  },
                ),
                
                const SizedBox(height: 16),
                _buildMenuSection(context, 'SETTINGS'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'Configuration',
                  isSelected: currentLocation == RouterPath.configuration,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouterPath.configuration);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About',
                  isSelected: currentLocation == RouterPath.about,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouterPath.about);
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.verified_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'GNU - Professional Edition 2025',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
