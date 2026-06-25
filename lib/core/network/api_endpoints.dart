class ApiEndpoints {
  ApiEndpoints._();

  static const String login = 'login';
  static const String logout = 'logout';
  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String queries = 'queries';
  static const String communityPosts = 'community/posts';
  static const String products = 'products';

  static String ownerProducts(String ownerId) => 'products/owner/$ownerId';

  static String notificationRead(String id) => 'notifications/$id/read';
  static String postComments(String postId) =>
      'community/posts/$postId/comments';
  static String postReactions(String postId) =>
      'community/posts/$postId/reactions';
  static String quickProvider(String providerId) =>
      'provider-services/quick-provider/$providerId';
}
