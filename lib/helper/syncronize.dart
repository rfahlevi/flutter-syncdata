// ignore_for_file: avoid_print

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class SyncData {
  static Future<bool> hasInternetConnection() async {
    // CONNECT TO INTERNET?
    if (await InternetConnection().hasInternetAccess) {
      return true;
    } else {
      return false;
    }
  }
}
