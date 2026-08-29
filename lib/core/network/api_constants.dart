class ApiConstants {
  ApiConstants._();

  static const String apiBaseUrl = 'http://168.231.74.154:6252/api/';
  static const String webBaseUrl = 'http://168.231.74.154:3009';

  static const String marketplaceSubscriptionCheckoutSuccessPath =
      '/marketplace-subscription/checkout/success';
  static const String marketplaceSubscriptionCheckoutCancelPath =
      '/marketplace-subscription/checkout/cancel';

  static String get marketplaceSubscriptionCheckoutSuccessUrl =>
      '$webBaseUrl$marketplaceSubscriptionCheckoutSuccessPath';

  static String get marketplaceSubscriptionCheckoutCancelUrl =>
      '$webBaseUrl$marketplaceSubscriptionCheckoutCancelPath';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
}
