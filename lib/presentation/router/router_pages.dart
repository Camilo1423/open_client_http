import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/router/router_page_animation.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:open_client_http/presentation/screens/screens.dart';

final List<GoRoute> routesPages = [
  GoRoute(
    path: RouterPath.home,
    name: HomeScreen.name,
    pageBuilder: (context, state) => animation(const HomeScreen(), state),
  ),
  GoRoute(
    path: RouterPath.configuration,
    name: SettingsScreen.name,
    pageBuilder: (context, state) => animation(const SettingsScreen(), state),
  ),
];
