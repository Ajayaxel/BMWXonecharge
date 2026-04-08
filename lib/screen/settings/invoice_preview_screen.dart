import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final String filePath;
  final String invoiceNumber;

  const InvoicePreviewScreen({
    super.key,
    required this.filePath,
    required this.invoiceNumber,
  });

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            print('❌ [InvoicePreview] WebView error: ${error.description}');
            if (mounted)
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
          },
        ),
      );

    // Load the local PDF file
    final file = File(widget.filePath);
    if (file.existsSync()) {
      // Read bytes and load as data URI for maximum compatibility
      _loadPdfAsDataUri(file);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadPdfAsDataUri(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Pdf = base64Encode(bytes);
      final dataUri = 'data:application/pdf;base64,$base64Pdf';
      await _controller.loadRequest(Uri.parse(dataUri));
    } catch (e) {
      print('❌ [InvoicePreview] Error loading PDF: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.invoiceNumber.isNotEmpty
              ? widget.invoiceNumber
              : 'Invoice Preview',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.black),
            tooltip: 'Open externally',
            onPressed: () {
              // Pop back — user can use the download button on detail screen
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            _buildErrorView()
          else
            WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            Container(
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF23262F),
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading invoice...',
                      style: TextStyle(
                        color: Color(0xFF4A4D54),
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Preview PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lufga',
                color: Color(0xFF23262F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The invoice could not be displayed. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Lufga',
                color: Color(0xFF4A4D54),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23262F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
