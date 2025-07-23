import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/router/index.dart';

final appRouter = GoRouter(
  initialLocation: RouterPath.home,
  routes: [...routesPages],
);
