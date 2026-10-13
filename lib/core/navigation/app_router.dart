import 'package:flutter/material.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  Future<bool> maybePop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.maybePop(result);
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> replaceNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, void>(
      routeName,
      arguments: arguments,
    );
  }
}

Future<bool?> showConfirmationDialog({
  String? title,
  required String message,
  String? confirmButtonText,
}) {
  return showDialog<bool>(
    context: navigatorKey.currentContext!,
    builder: (context) {
      return AlertDialog.adaptive(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(title ?? context.loc.confirmation),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              di.appRouter.maybePop(false);
            },
            child: Text(
              context.loc.no,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              di.appRouter.maybePop(true);
            },
            child: Text(
              confirmButtonText ?? context.loc.confirm,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      );
    },
  );
}
