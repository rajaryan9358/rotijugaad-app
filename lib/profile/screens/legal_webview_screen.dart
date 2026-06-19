import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebViewScreen extends StatefulWidget {
  const LegalWebViewScreen({
    super.key,
    required this.title,
    required this.pathEn,
    required this.pathHi,
  });

  final String title;
  final String pathEn;
  final String pathHi;

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _initialized = false;

  String _buildUrlForLocale(Locale locale) {
    final lang = (locale.languageCode).toLowerCase();
    final path = lang == 'hi' ? widget.pathHi : widget.pathEn;

    final base = ApiClient.baseUrl.endsWith('/')
        ? ApiClient.baseUrl.substring(0, ApiClient.baseUrl.length - 1)
        : ApiClient.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return '$base$normalizedPath';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final url = _buildUrlForLocale(context.locale);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Toolbar(widget.title, () {
              Navigator.of(context).pop();
            }),
            Divider(color: context.xcolors.stroke),
            if (_isLoading) const LinearProgressIndicator(minHeight: 2),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
