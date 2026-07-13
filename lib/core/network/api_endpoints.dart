class ApiEndpoints {
  ApiEndpoints._();

  static const String login = 'login';
  static const String registerProvider = 'user/register/provider';
  static const String verifyOtp = 'verify-otp';
  static const String resendVerification = 'resend-verification';
  static const String logout = 'logout';
  static const String forgotPassword = 'forgot-password';
  static const String verifyResetOtp = 'verify-reset-otp';
  static const String resetPassword = 'reset-password';
  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String queries = 'queries';
  static const String communityPosts = 'community/posts';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String serviceTypes = 'service-type/types';
  static const String providerServices = 'provider-services/services';
  static const String providerServicesList = 'provider-services/provider';
  static const String providerBookings = 'bookings/provider';

  static String providerService(String serviceId) => 'provider-services/$serviceId';
  static String product(String productId) => 'products/$productId';
  static String ownerProducts(String ownerId) => 'products/owner/$ownerId';

  static String notificationRead(String id) => 'notifications/$id/read';
  static String postComments(String postId) =>
      'community/posts/$postId/comments';
  static String postReactions(String postId) =>
      'community/posts/$postId/reactions';
  static String quickProvider(String providerId) =>
      'provider-services/quick-provider/$providerId';
}
