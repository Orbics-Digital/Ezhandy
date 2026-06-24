class ApiEndpoints {
  ApiEndpoints._();

  static const String login = 'login';
  static const String logout = 'logout';
  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String queries = 'queries';

  static String notificationRead(String id) => 'notifications/$id/read';
  static String quickProvider(String providerId) =>
      'provider-services/quick-provider/$providerId';
}
