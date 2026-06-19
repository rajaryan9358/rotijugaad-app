import 'dart:async';

import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CashfreeCheckoutResult {
  final String orderId;
  final bool didFinish;
  final String? errorMessage;

  const CashfreeCheckoutResult({
    required this.orderId,
    required this.didFinish,
    this.errorMessage,
  });
}

class CashfreeCheckoutService {
  final CFPaymentGatewayService _gateway = CFPaymentGatewayService();
  Completer<CashfreeCheckoutResult>? _completer;
  String? _activeOrderId;

  CashfreeCheckoutService() {
    _gateway.setCallback(_verifyPayment, _onError);
  }

  Future<CashfreeCheckoutResult> startCheckout({
    required String orderId,
    required String paymentSessionId,
    required String environment,
  }) async {
    if (_completer != null && !(_completer?.isCompleted ?? true)) {
      throw CFException('A payment is already in progress');
    }

    _activeOrderId = orderId;
    _completer = Completer<CashfreeCheckoutResult>();

    try {
      final session = CFSessionBuilder()
          .setEnvironment(_resolveEnvironment(environment))
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final payment = CFWebCheckoutPaymentBuilder().setSession(session).build();

      _gateway.doPayment(payment);
    } on CFException catch (e) {
      _complete(
        CashfreeCheckoutResult(
          orderId: orderId,
          didFinish: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      _complete(
        CashfreeCheckoutResult(
          orderId: orderId,
          didFinish: false,
          errorMessage: e.toString(),
        ),
      );
    }

    return _completer!.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => CashfreeCheckoutResult(
        orderId: orderId,
        didFinish: false,
        errorMessage: 'Payment confirmation timed out',
      ),
    );
  }

  CFEnvironment _resolveEnvironment(String environment) {
    return environment.trim().toUpperCase() == 'PRODUCTION'
        ? CFEnvironment.PRODUCTION
        : CFEnvironment.SANDBOX;
  }

  void _verifyPayment(String orderId) {
    _complete(CashfreeCheckoutResult(orderId: orderId, didFinish: true));
  }

  void _onError(CFErrorResponse errorResponse, String orderId) {
    _complete(
      CashfreeCheckoutResult(
        orderId: orderId,
        didFinish: false,
        errorMessage: errorResponse.getMessage(),
      ),
    );
  }

  void _complete(CashfreeCheckoutResult result) {
    final completer = _completer;
    if (completer == null || completer.isCompleted) return;
    _activeOrderId = null;
    completer.complete(result);
  }

  void dispose() {
    final orderId = _activeOrderId;
    _activeOrderId = null;
    if (_completer != null && !(_completer?.isCompleted ?? true)) {
      _completer!.complete(
        CashfreeCheckoutResult(
          orderId: orderId ?? '',
          didFinish: false,
          errorMessage: 'Payment was cancelled',
        ),
      );
    }
  }
}
