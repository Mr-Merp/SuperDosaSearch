import 'dart:io' show Platform;

const String _backendHost = '127.0.0.1';
final String apiBaseUrl = Platform.isAndroid
    ? 'http://10.0.2.2:5001'
    : 'http://$_backendHost:5001';
