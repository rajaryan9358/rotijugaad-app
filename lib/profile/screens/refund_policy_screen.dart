import 'package:flutter/material.dart';

import 'legal_webview_screen.dart';

class RefundPolicyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RefundPolicyScreenState();
}

class _RefundPolicyScreenState extends State<RefundPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return const LegalWebViewScreen(
      title: 'Refund Policy',
      pathEn: '/api/legal/refund-en.html',
      pathHi: '/api/legal/refund-hi.html',
    );
  }
}
