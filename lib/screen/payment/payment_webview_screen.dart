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
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Check if payment is successful (you may need to adjust this based on Paymob's redirect URLs)
            if (url.contains('success') || url.contains('payment-success')) {
              _handlePaymentSuccess();
            } else if (url.contains('cancel') || url.contains('payment-cancel')) {
              _handlePaymentCancel();
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
            const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
