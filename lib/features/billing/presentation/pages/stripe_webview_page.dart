import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeFlowResult {
  const StripeFlowResult({
    this.sessionId,
    this.cancelled = false,
    this.returnedToBilling = false,
  });

  final String? sessionId;
  final bool cancelled;
  final bool returnedToBilling;

  bool get hasSessionId => sessionId != null && sessionId!.trim().isNotEmpty;
}

class StripeWebViewPage extends StatefulWidget {
  const StripeWebViewPage({
    super.key,
    required this.initialUrl,
    required this.interceptPath,
    required this.title,
  });

  final String initialUrl;
  final String interceptPath;
  final String title;

  @override
  State<StripeWebViewPage> createState() => _StripeWebViewPageState();
}

class _StripeWebViewPageState extends State<StripeWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _errorText = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            final result = _extractResult(uri);
            if (result != null) {
              Navigator.of(context).pop(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorText = error.description.isNotEmpty
                  ? error.description
                  : 'Unable to load Stripe right now.';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          if (_errorText == null) WebViewWidget(controller: _controller),
          if (_errorText != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 40,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _errorText = null;
                          _isLoading = true;
                          _progress = 0;
                        });
                        _controller.loadRequest(Uri.parse(widget.initialUrl));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                value: _progress > 0 && _progress < 1 ? _progress : null,
                minHeight: 3,
                color: AppColors.primary,
                backgroundColor: AppColors.bgSecondary,
              ),
            ),
        ],
      ),
    );
  }

  StripeFlowResult? _extractResult(Uri? uri) {
    if (uri == null) return null;
    if (!uri.path.endsWith(widget.interceptPath)) return null;

    final sessionId = uri.queryParameters['session_id'];
    final reason = uri.queryParameters['reason'];
    return StripeFlowResult(
      sessionId: sessionId,
      cancelled: reason == 'cancelled',
      returnedToBilling: true,
    );
  }
}
