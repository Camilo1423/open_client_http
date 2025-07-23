import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_theme.g.dart';

@riverpod
class ChangeTheme extends _$ChangeTheme {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  Future<(String, bool)> build() async {
    final theme = await storage.read(key: 'theme');
    String resolvedTheme = theme ?? 'system';

    if (theme == null || !(theme == 'light' || theme == 'dark' || theme == 'system')) {
      // Si no hay valor o es inválido, lo reseteamos a 'system'
      await storage.write(key: 'theme', value: 'system');
      resolvedTheme = 'system';
    }

    if (resolvedTheme == 'light') {
      return ('light', false);
    } else if (resolvedTheme == 'dark') {
      return ('dark', true);
    } else {
      // resolvedTheme == 'system'
      // Necesitamos saber si el sistema está en modo oscuro o claro
      // Como no tenemos acceso directo a BuildContext aquí, usamos PlatformDispatcher
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDark = brightness == Brightness.dark;
      return ('system', isDark);
    }
  }

  Future<void> changeTheme([String? newTheme]) async {
    final currentState = await future;
    final currentTheme = currentState.$1;
    
    String nextTheme;
    if (newTheme != null) {
      nextTheme = newTheme;
    } else {
      // Ciclar entre los temas: light -> dark -> system -> light
      switch (currentTheme) {
        case 'light':
          nextTheme = 'dark';
          break;
        case 'dark':
          nextTheme = 'system';
          break;
        case 'system':
          nextTheme = 'light';
          break;
        default:
          nextTheme = 'light';
      }
    }
    
    await storage.write(key: 'theme', value: nextTheme);
    ref.invalidateSelf();
  }
}
