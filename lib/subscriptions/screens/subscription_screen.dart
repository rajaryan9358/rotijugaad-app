import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../common/dialogs/primary_dialog.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../employees/providers/employees_provider.dart';
import '../../employers/providers/employers_provider.dart';
import '../../common/widgets/toolbar.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../screens/payment_history_screen.dart';
import '../services/cashfree_checkout_service.dart';
import '../services/subscriptions_service.dart';
import '../widgets/subscription_item.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionsService _service = SubscriptionsService();
  final CashfreeCheckoutService _checkoutService = CashfreeCheckoutService();

  bool _isLoading = false;
  CustomException? _error;
  Map<String, dynamic>? _data;
  int? _buyingPlanId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _checkoutService.dispose();
    super.dispose();
  }

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return fallback;
    return int.tryParse(s) ?? fallback;
  }

  num _asNum(dynamic v, {num fallback = 0}) {
    if (v is num) return v;
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return fallback;
    return num.tryParse(s) ?? fallback;
  }

  String _asText(dynamic v) => (v ?? '').toString().trim();

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showStatusDialog(
    String message, {
    String? title,
    AppIcon icon = AppIcon.success,
    Color? iconColor,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => PrimaryDialog(
        message,
        title: title,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  Future<void> _refreshProfileData({
    required bool isEmployer,
    required int userId,
  }) async {
    if (isEmployer) {
      await context.read<EmployersProvider>().refreshEmployerDetail(userId);
      return;
    }
    await context.read<EmployeesProvider>().refreshEmployeeDetail(userId);
  }

  String _formatDate(dynamic v) {
    final raw = (v ?? '').toString().trim();
    if (raw.isEmpty) return '';

    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;

    try {
      return DateFormat('d MMM, y', context.locale.toString()).format(dt);
    } catch (_) {
      return DateFormat('d MMM, y').format(dt);
    }
  }

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    return null;
  }

  bool _hasAnyCredits(Map<String, dynamic>? credits) {
    if (credits == null) return false;
    for (final key in const ['contact', 'interest', 'ad']) {
      final bucket = _creditBucket(credits, key);
      final available = _asNum(
        bucket?['available'] ?? bucket?['remaining'] ?? bucket?['balance'],
      );
      if (available > 0) return true;
    }
    return false;
  }

  List<Map<String, dynamic>> _asMapList(dynamic v) {
    if (v is List) {
      final out = <Map<String, dynamic>>[];
      for (final item in v) {
        final m = _asMap(item);
        if (m != null) out.add(m);
      }
      return out;
    }
    return const [];
  }

  Map<String, dynamic>? _creditBucket(
    Map<String, dynamic>? credits,
    String key,
  ) {
    if (credits == null) return null;
    final k = key.toLowerCase();
    return _asMap(
      credits[k] ??
          credits[key] ??
          (k == 'ad' ? credits['ads'] : null) ??
          credits['${k}_credits'] ??
          credits['${k}_credit'] ??
          (k == 'ad' ? credits['ads_credits'] ?? credits['ads_credit'] : null),
    );
  }

  String _creditLeft(Map<String, dynamic>? credits, String key) {
    final k = key.toLowerCase();
    final bucket = _creditBucket(credits, k);
    final adAvailableFallback = k == 'ad'
        ? (credits?['ads_credit'] ?? credits?['ads_credits'])
        : null;
    final available = _asNum(
      bucket?['available'] ??
          bucket?['remaining'] ??
          bucket?['balance'] ??
          adAvailableFallback ??
          credits?['${k}_credit'],
    );
    if (available == available.roundToDouble()) return available.toInt().toString();
    return available.toStringAsFixed(2);
  }

  String _creditText(Map<String, dynamic>? credits, String key) {
    final k = key.toLowerCase();
    final bucket = _creditBucket(credits, k);
    final adAvailableFallback = k == 'ad'
        ? (credits?['ads_credit'] ?? credits?['ads_credits'])
        : null;
    final adTotalFallback = k == 'ad'
        ? (credits?['total_ads_credit'] ?? credits?['total_ads_credits'])
        : null;

    final available = _asNum(
      bucket?['available'] ??
          bucket?['remaining'] ??
          bucket?['balance'] ??
          adAvailableFallback ??
          credits?['${k}_credit'],
    );
    final total = _asNum(
      bucket?['total'] ??
          bucket?['max'] ??
          adTotalFallback ??
          credits?['total_${k}_credit'] ??
          credits?['total_${k}_credits'],
    );

    String fmt(num value) {
      if (value == value.roundToDouble()) return value.toInt().toString();
      return value.toStringAsFixed(2);
    }

    return '${fmt(available)}/${fmt(total)}';
  }

  Future<Map<String, dynamic>?> _getPaymentStatus({
    required bool isEmployer,
    required int userId,
    required String orderId,
  }) async {
    final result = isEmployer
        ? await _service.getEmployerSubscriptionPaymentStatus(
            employerId: userId,
            orderId: orderId,
          )
        : await _service.getEmployeeSubscriptionPaymentStatus(
            employeeId: userId,
            orderId: orderId,
          );

    switch (result) {
      case Success(value: final value):
        return value;
      case Failure(exception: _):
        return null;
    }
  }

  Future<Map<String, dynamic>?> _pollPaymentStatus({
    required bool isEmployer,
    required int userId,
    required String orderId,
  }) async {
    final waits = <Duration>[
      Duration.zero,
      const Duration(seconds: 5),
      const Duration(seconds: 15),
    ];

    Map<String, dynamic>? latest;

    for (final wait in waits) {
      if (wait > Duration.zero) {
        await Future.delayed(wait);
        if (!mounted) return latest;
      }

      latest = await _getPaymentStatus(
        isEmployer: isEmployer,
        userId: userId,
        orderId: orderId,
      );

      final paymentStatus = _asText(
        latest?['payment_status'] ?? latest?['status'],
      ).toLowerCase();

      if (paymentStatus == 'success' || paymentStatus == 'failed') {
        return latest;
      }
    }

    return latest;
  }

  Future<void> _buyPlan(
    Map<String, dynamic> plan, {
    required bool isEmployer,
  }) async {
    final planId = _asInt(plan['id']);
    if (planId <= 0 || _buyingPlanId != null) return;

    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    int userId = isEmployer
        ? SharedPrefUtils.readInt('auth_employer_id')
        : SharedPrefUtils.readInt('auth_employee_id');

    if (userId <= 0) {
      userId = _asInt(profile?['id']);
    }

    if (userId <= 0) {
      _snack(
        isEmployer
            ? 'errors.no_employer_id'.tr()
            : 'errors.no_employee_id'.tr(),
      );
      return;
    }

    setState(() {
      _buyingPlanId = planId;
    });

    try {
      final orderResult = isEmployer
          ? await _service.buyEmployerSubscription(
              employerId: userId,
              planId: planId,
            )
          : await _service.buyEmployeeSubscription(
              employeeId: userId,
              planId: planId,
            );

      if (!mounted) return;

      switch (orderResult) {
        case Failure(exception: final e):
          _snack(e.message);
          return;
        case Success(value: final value):
          final orderId = _asText(value['order_id']);
          final paymentSessionId = _asText(value['payment_session_id']);
          final environment = _asText(value['cashfree_environment']);

          if (orderId.isEmpty || paymentSessionId.isEmpty) {
            _snack('subscriptions.payment.unable_to_start'.tr());
            return;
          }

          final checkoutResult = await _checkoutService.startCheckout(
            orderId: orderId,
            paymentSessionId: paymentSessionId,
            environment: environment,
          );

          if (!mounted) return;

          if (!checkoutResult.didFinish) {
            final errMsg = (checkoutResult.errorMessage ?? '').trim();
            final isCancelled = errMsg.toLowerCase().contains('cancel');
            if (!isCancelled && errMsg.isNotEmpty) {
              _snack(errMsg);
            }
            return;
          }

          final status = await _pollPaymentStatus(
            isEmployer: isEmployer,
            userId: userId,
            orderId: orderId,
          );

          if (!mounted) return;

          final paymentStatus = _asText(
            status?['payment_status'] ?? status?['status'],
          ).toLowerCase();
          final isPaid =
              status?['is_paid'] == true || paymentStatus == 'success';

          if (isPaid) {
            await _load();
            await _refreshProfileData(isEmployer: isEmployer, userId: userId);
            if (!mounted) return;

            await _showStatusDialog(
              'Your purchase for subscription is complete.',
              title: 'Payment successful',
              icon: AppIcon.success,
              iconColor: context.xcolors.success,
            );
            return;
          }

          if (paymentStatus == 'failed') {
            await _showStatusDialog(
              'Your payment failed, if money got deducted will be refunded in 3-4 days.',
              title: 'Payment failed',
              icon: AppIcon.rejected,
              iconColor: context.xcolors.failure,
            );
            return;
          }

          await _showStatusDialog(
            'Your payment is pending, you will be updated about payment status when it changes.',
            title: 'Payment pending',
            icon: AppIcon.profilePending,
            iconColor: context.xcolors.warning,
          );
          return;
      }
    } finally {
      if (mounted) {
        setState(() {
          _buyingPlanId = null;
        });
      }
    }
  }

  Future<void> _load() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userType = SharedPrefUtils.readStr(
      SharedPrefUtils.USER_TYPE,
    ).trim().toLowerCase();

    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

    Result<Map<String, dynamic>, CustomException> result;

    if (userType == 'employer') {
      var employerId = SharedPrefUtils.readInt('auth_employer_id');
      if (employerId <= 0) {
        employerId = _asInt(profile?['id'] ?? profile?['employerId']);
      }

      if (employerId <= 0) {
        result = Failure(
          CustomException(
            code: 'NO_EMPLOYER',
            message: 'Employer ID not found. Please sign in again.',
          ),
        );
      } else {
        result = await _service.getEmployerSubscriptions(employerId);
      }
    } else {
      var employeeId = SharedPrefUtils.readInt('auth_employee_id');
      if (employeeId <= 0) {
        employeeId = _asInt(profile?['id'] ?? profile?['employeeId']);
      }

      if (employeeId <= 0) {
        result = Failure(
          CustomException(
            code: 'NO_EMPLOYEE',
            message: 'Employee ID not found. Please sign in again.',
          ),
        );
      } else {
        result = await _service.getEmployeeSubscriptions(employeeId);
      }
    }

    if (!mounted) return;

    switch (result) {
      case Success(value: final value):
        setState(() {
          _data = value;
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _error = e;
        });
        break;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userType = SharedPrefUtils.readStr(
      SharedPrefUtils.USER_TYPE,
    ).trim().toLowerCase();
    final isEmployer = userType == 'employer';

    final isHindi = context.locale.languageCode == 'hi';

    final current = _asMap(
      _data?['current_subscription'] ?? _data?['currentSubscription'],
    );
    final activePlan = _asMap(
      _data?['active_plan'] ??
          current?['active_plan'] ??
          current?['activePlan'],
    );
    final credits = _asMap(current?['credits'] ?? _data?['credits']);

    final currentPlanName =
        (isHindi
            ? (current?['active_plan_name_hindi'] ??
                  current?['activePlanNameHindi'] ??
                  current?['active_plan']?['plan_name_hindi'] ??
                  activePlan?['plan_name_hindi'])
            : (current?['active_plan_name'] ??
                  current?['activePlanName'] ??
                  current?['active_plan']?['plan_name_english'] ??
                  activePlan?['plan_name_english'])) ??
        (current?['active_plan_name'] ??
            current?['activePlanName'] ??
            current?['active_plan']?['plan_name_english'] ??
            current?['active_plan']?['plan_name_hindi'] ??
            current?['active_plan']?['plan_name'] ??
            activePlan?['plan_name_english'] ??
            activePlan?['plan_name_hindi'] ??
            activePlan?['plan_name'] ??
            '');

    final currentPlanNameText = currentPlanName.toString().trim();

    final validTill = _formatDate(
      current?['valid_till'] ?? current?['expired_at'] ?? current?['validTill'],
    );

    final plans = _asMapList(_data?['plans'] ?? _data?['results']);

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Toolbar('subscriptions.screen.title'.tr(), () {
              Navigator.of(context).pop();
            }),
            Divider(color: context.xcolors.stroke),
            Expanded(
              child: _isLoading
                  ? const AppListShimmer(padding: EdgeInsets.only(top: 12))
                  : (_error != null)
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error?.message ?? 'common.failed_to_load'.tr(),
                              style: context.text.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.spacing.md),
                            ElevatedButton(
                              onPressed: _load,
                              child: Text('common.retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentPlanNameText.isNotEmpty
                                          ? currentPlanNameText
                                          : (_hasAnyCredits(credits) || validTill.isNotEmpty)
                                              ? 'subscriptions.free_credits'.tr()
                                              : 'subscriptions.no_active_plan'.tr(),
                                      style: context.text.bodyMedium!.copyWith(
                                        color:
                                            context.colors.onPrimaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: context.spacing.xs),
                                    if (validTill.isNotEmpty)
                                      Text(
                                        'subscriptions.valid_till'.tr(
                                          args: [validTill],
                                        ),
                                        style: context.text.bodySmall,
                                      ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PaymentHistoryScreen(),
                                      ),
                                    );
                                  },
                                  child: Text('common.view_history'.tr()),
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing.md),
                            Container(
                              decoration: BoxDecoration(
                                color: context.colors.primaryContainer,
                                border: Border.all(
                                  color: context.xcolors.stroke,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(context.radii.sm),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.spacing.md,
                                vertical: context.spacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'subscriptions.credits.contact'.tr(),
                                          style: context.text.bodySmall,
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          _creditText(credits, 'contact'),
                                          style: context.text.bodyMedium!
                                              .copyWith(
                                                color: context.colors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          'common.credits_left'.tr(args: [_creditLeft(credits, 'contact')]),
                                          style: context.text.bodySmall!.copyWith(color: context.colors.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 64,
                                    color: context.xcolors.stroke,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: !isEmployer
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'subscriptions.credits.interest'.tr(),
                                          style: context.text.bodySmall,
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          _creditText(credits, 'interest'),
                                          style: context.text.bodyMedium!
                                              .copyWith(
                                                color: context.colors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          'common.credits_left'.tr(args: [_creditLeft(credits, 'interest')]),
                                          style: context.text.bodySmall!.copyWith(color: context.colors.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isEmployer) ...[
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: context.xcolors.stroke,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'subscriptions.credits.ads'.tr(),
                                            style: context.text.bodySmall,
                                          ),
                                          SizedBox(height: context.spacing.xs),
                                          Text(
                                            _creditText(credits, 'ad'),
                                            style: context.text.bodyMedium!
                                                .copyWith(
                                                  color: context.colors.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          SizedBox(height: context.spacing.xs),
                                          Text(
                                            'common.credits_left'.tr(args: [_creditLeft(credits, 'ad')]),
                                            style: context.text.bodySmall!.copyWith(color: context.colors.secondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: context.spacing.sm),
                            if (plans.isEmpty)
                              Text(
                                'subscriptions.plans.empty'.tr(),
                                style: context.text.bodyMedium,
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: plans.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final plan = plans[index];
                                  final isActive =
                                      plan['is_current_plan'] == true ||
                                      plan['isCurrentPlan'] == true;

                                  return SubscriptionItem(
                                    plan: plan,
                                    isActive: isActive,
                                    isLoading:
                                        _buyingPlanId == _asInt(plan['id']),
                                    onPressed: () =>
                                        _buyPlan(plan, isEmployer: isEmployer),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
