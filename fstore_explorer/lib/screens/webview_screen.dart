import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/history_provider.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  final String url;
  final String title;
  final String? productImage;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
    this.productImage,
  });

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  String _currentTitle = '';
  String _currentUrl = '';
  bool _hasAddedInitial = false;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _currentUrl = widget.url;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            final title = await _controller.getTitle();
            _currentTitle = title ?? widget.title;
            _currentUrl = url;

            // Add to history
            ref.read(historyProvider.notifier).addEntry(
                  url: url,
                  title: _currentTitle,
                  productImage: _hasAddedInitial ? null : widget.productImage,
                );
            _hasAddedInitial = true;
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentTitle,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _currentUrl,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
        ],
      ),
    );
  }
}