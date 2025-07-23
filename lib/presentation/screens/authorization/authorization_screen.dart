import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_client_http/presentation/router/router_path.dart';
import 'package:open_client_http/presentation/widget/widgets.dart';

class AuthorizationScreen extends ConsumerWidget {
  const AuthorizationScreen({super.key});

  static const String name = "authorization_screen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarCustom(
        titleText: 'Authorization',
        leading: _buildLeading(context),
      ),
      drawer: const DrawerCustom(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Authorization Methods',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Configure authentication methods for your requests',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
