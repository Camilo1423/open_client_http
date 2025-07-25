import 'package:flutter/material.dart';
import 'package:open_client_http/presentation/router/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/config/config.dart';
import 'package:open_client_http/presentation/provider/providers.dart';
import 'package:open_client_http/data/datasources/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar la base de datos
  await DatabaseService().initDatabase();
  
  runApp(const ProviderScope(child: Root()));
}

class Root extends ConsumerWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(changeThemeProvider);
    
    return theme.when(
      loading: () {
        // Mientras carga, usa el tema del sistema para evitar parpadeo
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final isDark = brightness == Brightness.dark;
        return MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          theme: AppTheme(isDarkMode: isDark).theme,
        );
      },
      error: (error, stack) {
        // En caso de error, usa tema claro por defecto
        return MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          theme: AppTheme(isDarkMode: false).theme,
        );
      },
      data: (themeData) {
        return MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          theme: AppTheme(isDarkMode: themeData.$2).theme,
        );
      },
    );
  }
}
