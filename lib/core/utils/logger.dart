import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class Log {
  Log._();

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      dev.log('\x1B[34m[$tag] $message\x1B[0m', name: tag);
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    dev.log('\x1B[32m[$tag] $message\x1B[0m', name: tag);
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    dev.log('\x1B[33m[$tag] $message\x1B[0m', name: tag);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    dev.log(
      '\x1B[31m[$tag] $message\x1B[0m',
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
