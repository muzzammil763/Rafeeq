import 'package:flutter/foundation.dart';

class Logger {
  const Logger._();

  static void log(Object? object) {
    if (kDebugMode) {
      debugPrint(object.toString());
    }
  }
}
