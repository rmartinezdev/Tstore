import 'dart:io';
import 'package:tstore/core/utils/logger.dart';

class ConnectivityService {
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      Log.debug('Connectivity status: Disconnected (SocketException)');
      return false;
    } catch (e) {
      Log.debug('Connectivity status: Disconnected ($e)');
      return false;
    }
  }
}
