import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String url;
  final String successPath;
  final String cancelPath;

  const CheckoutWebViewScreen({
    super.key,
    required this.url,
    this.successPath = 'subscription-success',
    this.cancelPath = 'subscription-plans',
  });

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  bool _handledResult = false;

  void _setLoading(bool value) {
    if (!mounted || _isLoading == value) return;
    setState(() => _isLoading = value);
  }

  void _markLoaded() {
    _hasLoadedOnce = true;
    _setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            // Stripe checkout triggers many internal navigations; only show
            // the loader for the first page load.
            if (!_hasLoadedOnce) _setLoading(true);
          },
          onProgress: (progress) {
            if (progress >= 100) _markLoaded();
          },
          onPageFinished: (_) => _markLoaded(),
          onNavigationRequest: (request) {
            _handleRedirect(request.url);
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _handleRedirect(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isAppRedirect(Uri uri) {
    final webHost = Uri.tryParse(ApiConstants.webBaseUrl)?.host;
    return webHost != null && uri.host == webHost;
  }

  void _handleRedirect(String url) {
    if (_handledResult || !mounted) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !_isAppRedirect(uri)) return;

    final path = uri.path.toLowerCase();
    if (path.contains(widget.successPath.toLowerCase())) {
      _handledResult = true;
      _onSuccess();
      return;
    }

    if (path.contains(widget.cancelPath.toLowerCase())) {
      _handledResult = true;
      _onCancel();
    }
  }

  void _onSuccess() {
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _onCancel() {
    if (!mounted) return;
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back(result: false);
      },
      title: AppStrings.checkout,
      child: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
        ],
      ),
    );
  }
}
