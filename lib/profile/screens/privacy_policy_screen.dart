import 'package:flutter/material.dart';

import 'legal_webview_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return const LegalWebViewScreen(
      title: 'Privacy Policy',
      pathEn: '/api/legal/privacy-en.html',
      pathHi: '/api/legal/privacy-hi.html',
    );
  }
}
