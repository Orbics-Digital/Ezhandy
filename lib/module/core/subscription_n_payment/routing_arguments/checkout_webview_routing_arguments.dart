class CheckoutWebViewRoutingArgument {
  final String url;
  final String? sessionId;
  final String successPath;
  final String cancelPath;

  const CheckoutWebViewRoutingArgument({
    required this.url,
    this.sessionId,
    this.successPath = 'subscription-success',
    this.cancelPath = 'subscription-plans',
  });
}
