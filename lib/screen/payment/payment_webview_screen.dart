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
          onPageStarted: (String url) {
            print('Payment WebView URL: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('Payment WebView Finished URL: $url');
            setState(() {
              _isLoading = false;
            });

            // Check based on standard Paymob redirection or query parameters
            final uri = Uri.parse(url);
            final success = uri.queryParameters['success'] == 'true';
            final approved =
                uri.queryParameters['txn_response_code'] == 'APPROVED';
            // Some integrations use a 'success' part in the path or 'payment-success'
            final pathContainsSuccess =
                url.contains('success') || url.contains('payment-success');

            if (success || approved || pathContainsSuccess) {
              print('Payment Status: SUCCESS');
              _handlePaymentSuccess();
            } else if (url.contains('cancel') ||
                url.contains('payment-cancel')) {
              print('Payment Status: CANCELED');
              _handlePaymentCancel();
            } else {
              print('Payment Status: PENDING/UNKNOWN (Current URL: $url)');
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [PaymentWebView] Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
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
