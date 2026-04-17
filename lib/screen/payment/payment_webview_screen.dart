import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String? intentionId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.intentionId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            print('🔄 [PaymentWebView] Navigation Request: $url');

            // Catch success/cancel patterns early in navigation request
            if (_checkStatusAndHandle(url)) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('🌐 [PaymentWebView] Page Started: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('🌐 [PaymentWebView] Page Finished: $url');
            setState(() {
              _isLoading = false;
            });

            _checkStatusAndHandle(url);
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [PaymentWebView] Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _checkStatusAndHandle(String url) {
    if (!mounted) return false;

    // Check based on standard Paymob redirection or query parameters
    final uri = Uri.parse(url);
    final success =
        uri.queryParameters['success'] == 'true' ||
        uri.queryParameters['success'] == '1';
    final approved =
        uri.queryParameters['txn_response_code'] == 'APPROVED' ||
        uri.queryParameters['status']?.toLowerCase() == 'approved';

    // Some integrations use a 'success' part in the path or 'payment-success'
    final pathContainsSuccess =
        url.contains('success') && !url.contains('success=false');
    final pathContainsCompleted = url.contains('completed') || url.contains('done');

    print(
      '🔍 [PaymentWebView] Checking status: success=$success, approved=$approved, pathContainsSuccess=$pathContainsSuccess, pathContainsCompleted=$pathContainsCompleted',
    );

    if (success || approved || pathContainsSuccess || pathContainsCompleted) {
      print('✅ [PaymentWebView] Payment Status detected as SUCCESS');
      _handlePaymentSuccess();
      return true;
    } else if (url.contains('cancel') ||
        url.contains('payment-cancel') ||
        uri.queryParameters['success'] == 'false') {
      print('⚠️ [PaymentWebView] Payment Status detected as CANCELED');
      _handlePaymentCancel();
      return true;
    }

    print(
      'ℹ️ [PaymentWebView] Payment Status still PENDING or Unknown (URL: $url)',
    );
    return false;
  }

  void _handlePaymentSuccess() {
    // Close the WebView and return success
    Navigator.of(context).pop(true);
  }

  void _handlePaymentCancel() {
    // Close the WebView and return cancel
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lufga',
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        ],
      ),
    );
  }
}
