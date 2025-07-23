import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page<dynamic> animation(Widget child, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      name: state.name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
