class ApiConstants {
  ApiConstants._();

  static const String apiBaseUrl = 'http://168.231.74.154:6252/api/';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
}
