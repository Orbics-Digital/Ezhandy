class SubscriptionCheckoutResult {
  final String url;
  final String? sessionId;

  const SubscriptionCheckoutResult({
    required this.url,
    this.sessionId,
  });

  factory SubscriptionCheckoutResult.fromJson(Map<String, dynamic> json) {
    final url = json['url']?.toString().trim() ?? '';
    if (url.isEmpty) {
      throw const FormatException('Checkout response did not include a url');
    }

    return SubscriptionCheckoutResult(
      url: url,
      sessionId: json['sessionId']?.toString(),
    );
  }
}
