class ApiEndpoints {
  ApiEndpoints._();

  static const String login = 'login';
  static const String registerProvider = 'user/register/provider';
  static const String verifyOtp = 'verify-otp';
  static const String resendVerification = 'resend-verification';
  static const String logout = 'logout';
  static const String deleteAccount = 'user/me';
  static const String forgotPassword = 'forgot-password';
  static const String verifyResetOtp = 'verify-reset-otp';
  static const String resetPassword = 'reset-password';
  static const String changePassword = 'change-password';
  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String queries = 'queries';
  static const String communityPosts = 'community/posts';
  static const String products = 'products';
  static const String categories = 'categories';

  /// Marketplace product listing subscription (separate from provider plan).
  static const String marketplaceSubscriptionStatus =
      'marketplace-subscriptions/my-status';
  static const String marketplaceSubscriptionPlans =
      'marketplace-subscriptions/plans';
  static const String marketplaceSubscriptionHistory =
      'marketplace-subscriptions/my-history';
  static const String marketplaceSubscriptionCheckout =
      'marketplace-subscriptions/create-checkout-session';
  static const String marketplaceSubscriptionVerifyCheckout =
      'marketplace-subscriptions/verify-checkout-session';

  static const String serviceTypes = 'service-type/types';
  static const String providerServices = 'provider-services/services';
  static const String providerServicesList = 'provider-services/provider';
  static const String providerBookings = 'bookings/provider';

  static String bookingDetail(String id) => 'bookings/detail/$id';
  static const String updateBookingStatus = 'bookings/booking/status';
  static const String beforeWork = 'bookings/before-work';
  static const String afterWork = 'bookings/after-work';
  static String pastWorkByService(String serviceId) =>
      'bookings/past-work/service/$serviceId';
  static const String myChats = 'live-chat/my-chats';
  static const String findOrCreateChat = 'live-chat/find-or-create';
  static const String askProRequests = 'ask-pro/requests';
  static const String askProStatus = 'ask-pro/status';
  static const String askProProviderActivateFree = 'ask-pro/provider/activate-free';
  static const String providerWallet = 'payment/provider-wallet';
  static const String providerEarnings = 'payment/provider-earnings';
  static const String paymentLogs = 'payment/logs';
  static const String activeSubscriptionPlans = 'subscription-plans/active';
  static const String createSubscriptionCheckout =
      'payment/create-subscription-checkout';
  static const String verifySubscriptionCheckout =
      'payment/verify-subscription-checkout';

  static String page(String slug) => 'pages/$slug';

  static String askProRejectRequest(String requestId) =>
      'ask-pro/requests/$requestId/reject';

  static String askProAcceptRequest(String requestId) =>
      'ask-pro/requests/$requestId/accept';

  static String chatHistory(String chatId) =>
      'live-chat/$chatId/history/chat';

  static String markChatRead(String chatId) => 'live-chat/$chatId/read';

  static String providerService(String serviceId) => 'provider-services/$serviceId';
  static String providerServiceStatus(String serviceId) =>
      'provider-services/status/$serviceId';
  static String product(String productId) => 'products/$productId';
  static String ownerProducts(String ownerId) => 'products/owner/$ownerId';
  static String bookingInvoice(int bookingId) => 'bookings/$bookingId/invoice';
  static String bookingExtraTime(int bookingId) =>
      'bookings/$bookingId/extra-time';

  static String notificationRead(String id) => 'notifications/$id/read';
  static String postComments(String postId) =>
      'community/posts/$postId/comments';
  static String postReactions(String postId) =>
      'community/posts/$postId/reactions';
  static String quickProvider(String providerId) =>
      'provider-services/quick-provider/$providerId';

  static String providerRatings(String providerId) =>
      'admin/providers/$providerId/ratings';

  static const String updateProfile = 'user/profile';
  static const String profileDetails = 'user/profile-details';
  static const String certifications = 'user/certifications';
  static String certification(String id) => 'user/certifications/$id';
}
