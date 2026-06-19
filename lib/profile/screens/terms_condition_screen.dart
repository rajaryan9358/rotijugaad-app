import 'package:flutter/material.dart';

import 'legal_webview_screen.dart';

class TermsConditionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
  @override
  Widget build(BuildContext context) {
    return const LegalWebViewScreen(
      title: 'Terms and Conditions',
      pathEn: '/api/legal/terms-en.html',
      pathHi: '/api/legal/terms-hi.html',
    );
  }
}
