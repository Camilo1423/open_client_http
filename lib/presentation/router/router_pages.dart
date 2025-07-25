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
  GoRoute(
    path: RouterPath.params,
    name: ParamsScreen.name,
    pageBuilder: (context, state) => animation(const ParamsScreen(), state),
  ),
  GoRoute(
    path: RouterPath.authorization,
    name: AuthorizationScreen.name,
    pageBuilder: (context, state) =>
        animation(const AuthorizationScreen(), state),
  ),
  GoRoute(
    path: RouterPath.rawEditor,
    name: RawEditorScreen.name,
    pageBuilder: (context, state) => animation(const RawEditorScreen(), state),
  ),
  GoRoute(
    path: RouterPath.about,
    name: AboutScreen.name,
    pageBuilder: (context, state) => animation(const AboutScreen(), state),
  ),
  GoRoute(
    path: RouterPath.renderResponse,
    name: RenderResponseScreen.name,
    pageBuilder: (context, state) =>
        animation(const RenderResponseScreen(), state),
  ),
  GoRoute(
    path: RouterPath.environments,
    name: EnviromentScreen.name,
    pageBuilder: (context, state) => animation(const EnviromentScreen(), state),
  ),
  GoRoute(
    path: RouterPath.environmentKeys,
    name: EnvironmentKeysScreen.name,
    pageBuilder: (context, state) {
      final environmentId = int.parse(state.pathParameters['environmentId']!);
      final extra = state.extra as Map<String, dynamic>?;
      final returnTo = extra?['returnTo'] as String? ?? '/';
      return animation(EnvironmentKeysScreen(environmentId: environmentId, returnTo: returnTo), state);
    },
  ),
  GoRoute(
    path: RouterPath.collections,
    name: CollectionsScreen.name,
    pageBuilder: (context, state) => animation(const CollectionsScreen(), state),
  ),
];
