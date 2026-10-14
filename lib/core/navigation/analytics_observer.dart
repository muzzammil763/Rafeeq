import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/providers.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/current_route_provider.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  final WidgetRef _ref;
  final String? _initialScreenName;
  String? _pendingRouteName;
  bool _routeUpdateScheduled = false;

  AnalyticsNavigatorObserver(this._ref, {String? initialScreenName})
    : _initialScreenName = initialScreenName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) print("Navigated to ${route.settings.name}");
    _trackScreen(route);
    _setCurrentRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackScreen(newRoute);
      _setCurrentRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _trackScreen(previousRoute);
      _setCurrentRoute(previousRoute);
    }
  }

  void _setCurrentRoute(Route<dynamic> route) {
    _pendingRouteName = route.settings.name;
    if (_routeUpdateScheduled) return;

    _routeUpdateScheduled = true;
    scheduleMicrotask(() {
      _routeUpdateScheduled = false;
      final routeName = _pendingRouteName;
      _pendingRouteName = null;
      _ref.read(currentRouteNameProvider.notifier).state = routeName;
    });
  }

  void _trackScreen(Route<dynamic> route) {
    final routeName = route.settings.name;
    final name = AnalyticsScreenNames.fromRouteName(
      routeName,
      defaultRouteScreenName: _initialScreenName,
    );
    if (name != null && name.isNotEmpty) {
      if (kDebugMode) print('Analytics screen: $name');
      final analytics = _ref.read(analyticsProvider);
      analytics?.logScreenView(screenName: name);
    }
  }
}
