import '../../network/api_client.dart';

class AppSettings {
  final String employeeSupportMobile;
  final String employeeSupportEmail;
  final String employerSupportMobile;
  final String employerSupportEmail;
  final String privacyPolicy;
  final String termsAndConditions;
  final String refundPolicy;
  final String linkedinLink;
  final String xlLink;
  final String facebookLink;
  final String instagramLink;
  final String updatedAt;

  const AppSettings({
    required this.employeeSupportMobile,
    required this.employeeSupportEmail,
    required this.employerSupportMobile,
    required this.employerSupportEmail,
    required this.privacyPolicy,
    required this.termsAndConditions,
    required this.refundPolicy,
    required this.linkedinLink,
    required this.xlLink,
    required this.facebookLink,
    required this.instagramLink,
    required this.updatedAt,
  });

  const AppSettings.empty()
    : employeeSupportMobile = '',
      employeeSupportEmail = '',
      employerSupportMobile = '',
      employerSupportEmail = '',
      privacyPolicy = '',
      termsAndConditions = '',
      refundPolicy = '',
      linkedinLink = '',
      xlLink = '',
      facebookLink = '',
      instagramLink = '',
      updatedAt = '';

  factory AppSettings.fromJson(Map<String, dynamic>? json) {
    String read(String key) => json?[key]?.toString().trim() ?? '';

    return AppSettings(
      employeeSupportMobile: read('employee_support_mobile'),
      employeeSupportEmail: read('employee_support_email'),
      employerSupportMobile: read('employer_support_mobile'),
      employerSupportEmail: read('employer_support_email'),
      privacyPolicy: read('privacy_policy'),
      termsAndConditions: read('terms_and_conditions'),
      refundPolicy: read('refund_policy'),
      linkedinLink: read('linkedin_link'),
      xlLink: read('xl_link'),
      facebookLink: read('facebook_link'),
      instagramLink: read('instagram_link'),
      updatedAt: read('updated_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_support_mobile': employeeSupportMobile,
      'employee_support_email': employeeSupportEmail,
      'employer_support_mobile': employerSupportMobile,
      'employer_support_email': employerSupportEmail,
      'privacy_policy': privacyPolicy,
      'terms_and_conditions': termsAndConditions,
      'refund_policy': refundPolicy,
      'linkedin_link': linkedinLink,
      'xl_link': xlLink,
      'facebook_link': facebookLink,
      'instagram_link': instagramLink,
      'updated_at': updatedAt,
    };
  }

  bool get isEmpty =>
      employeeSupportMobile.isEmpty &&
      employeeSupportEmail.isEmpty &&
      employerSupportMobile.isEmpty &&
      employerSupportEmail.isEmpty &&
      privacyPolicy.isEmpty &&
      termsAndConditions.isEmpty &&
      refundPolicy.isEmpty &&
      linkedinLink.isEmpty &&
      xlLink.isEmpty &&
      facebookLink.isEmpty &&
      instagramLink.isEmpty;

  String supportMobileFor(String userType) {
    return _isEmployer(userType)
        ? _fallback(employerSupportMobile, employeeSupportMobile)
        : _fallback(employeeSupportMobile, employerSupportMobile);
  }

  String supportEmailFor(String userType) {
    return _isEmployer(userType)
        ? _fallback(employerSupportEmail, employeeSupportEmail)
        : _fallback(employeeSupportEmail, employerSupportEmail);
  }

  String get resolvedPrivacyPolicy => resolveLink(privacyPolicy);
  String get resolvedTermsAndConditions => resolveLink(termsAndConditions);
  String get resolvedRefundPolicy => resolveLink(refundPolicy);
  String get resolvedLinkedinLink => resolveLink(linkedinLink);
  String get resolvedXlLink => resolveLink(xlLink);
  String get resolvedFacebookLink => resolveLink(facebookLink);
  String get resolvedInstagramLink => resolveLink(instagramLink);

  static String resolveLink(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '${ApiClient.baseUrl}$value';
    }
    if (value.contains('://')) {
      return value;
    }
    return 'https://$value';
  }

  static bool _isEmployer(String userType) {
    return userType.trim().toLowerCase() == 'employer';
  }

  static String _fallback(String primary, String secondary) {
    final a = primary.trim();
    if (a.isNotEmpty) return a;
    return secondary.trim();
  }
}
