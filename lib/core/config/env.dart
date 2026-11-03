import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tstore/core/utils/logger.dart';

class Env {
  Env._();

  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      Log.info('Environment variables loaded successfully.');
    } catch (e) {
      Log.warning('Could not load .env file, using default fallback environment variables: $e');
    }
  }

  static String get apiBaseUrl => _isInitialized ? dotenv.get('API_BASE_URL', fallback: 'MOCK') : 'MOCK';
  static int get apiTimeoutMs => int.parse(_isInitialized ? dotenv.get('API_TIMEOUT_MS', fallback: '15000') : '15000');
  static int get offlineSyncIntervalSec => int.parse(_isInitialized ? dotenv.get('OFFLINE_SYNC_INTERVAL_SEC', fallback: '30') : '30');
  static String get appName => _isInitialized ? dotenv.get('APP_NAME', fallback: 'TStore') : 'TStore';
  static String get appVersion => _isInitialized ? dotenv.get('APP_VERSION', fallback: '1.0.0') : '1.0.0';

  static bool get isMock => apiBaseUrl.toUpperCase() == 'MOCK';
}
