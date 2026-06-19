import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../common/widgets/app_loading_indicator.dart';
import '../../common/widgets/toolbar.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../network/api_client.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../services/payment_history_service.dart';
import '../widgets/payment_history_item.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentHistoryService _service = PaymentHistoryService();

  bool _isLoading = false;
  CustomException? _error;
  List<Map<String, dynamic>> _payments = const [];

  Uri _buildUri(String endpoint) {
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final base = Uri.parse(ApiClient.baseUrl);
    final basePath = ApiClient.basePath.endsWith('/')
        ? ApiClient.basePath.substring(0, ApiClient.basePath.length - 1)
        : ApiClient.basePath;

    return base.replace(path: '$basePath$normalized');
  }

  int _asPositiveInt(dynamic v) {
    final i = _asInt(v);
    return i > 0 ? i : 0;
  }

  String _safeFileToken(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    if (cleaned.isEmpty) return 'invoice';
    return cleaned.length > 120 ? cleaned.substring(0, 120) : cleaned;
  }

  Future<Uint8List> _downloadPdf(
    Uri uri, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    final client = http.Client();
    try {
      final req = http.Request('GET', uri);
      final res = await client.send(req);

      if (res.statusCode != 200) {
        final body = await res.stream.bytesToString();
        throw Exception('HTTP_${res.statusCode}: $body');
      }

      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.contains('application/pdf')) {
        await res.stream.drain();
        throw Exception('Invoice PDF is not available. Please try again later.');
      }

      final total = res.contentLength ?? -1;
      final out = <int>[];
      var received = 0;

      await for (final chunk in res.stream) {
        out.addAll(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }

      return Uint8List.fromList(out);
    } finally {
      client.close();
    }
  }

  Future<void> _downloadAndOpenInvoice(Map<String, dynamic> payment) async {
    final paymentHistoryId = _asPositiveInt(payment['id']);
    if (paymentHistoryId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invoice not available')));
      return;
    }

    final invoiceNumber = (payment['invoice_number'] ?? 'INV-$paymentHistoryId')
        .toString();
    final uri = _buildUri(ApiClient.paymentInvoicePdf(paymentHistoryId));

    final progress = ValueNotifier<double?>(null);
    var dialogOpen = true;

    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: ValueListenableBuilder<double?>(
                  valueListenable: progress,
                  builder: (context, value, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: AppLoadingIndicator(
                            size: 56,
                            strokeWidth: 4,
                            value: value,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'common.loading'.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ).then((_) {
        dialogOpen = false;
      });
    }

    try {
      final bytes = await _downloadPdf(
        uri,
        onProgress: (received, total) {
          if (total > 0) {
            progress.value = received / total;
          } else {
            progress.value = null;
          }
        },
      );

      final dir = await getTemporaryDirectory();
      final filename = 'invoice-${_safeFileToken(invoiceNumber)}.pdf';
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes, flush: true);

      if (mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      dialogOpen = false;

      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      dialogOpen = false;

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download invoice: $e')));
    } finally {
      progress.dispose();
    }
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  List<Map<String, dynamic>> _asMapList(dynamic v) {
    if (v is List) {
      return v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
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
            message: 'errors.no_employer_id'.tr(),
          ),
        );
      } else {
        result = await _service.getEmployerPaymentHistory(employerId);
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
            message: 'errors.no_employee_id'.tr(),
          ),
        );
      } else {
        result = await _service.getEmployeePaymentHistory(employeeId);
      }
    }

    if (!mounted) return;

    switch (result) {
      case Success(value: final value):
        final results = _asMapList(value['results']);
        final payments = results
            .map((r) => r['payment'])
            .whereType<Map>()
            .map((p) => p.cast<String, dynamic>())
            .where((p) {
              final status = (p['status'] ?? p['payment_status'] ?? '')
                  .toString()
                  .trim()
                  .toLowerCase();
              return status == 'success';
            })
            .toList();

        setState(() {
          _payments = payments;
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _error = e;
          _payments = const [];
        });
        break;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Toolbar('subscriptions.payment_history.title'.tr(), () {
              Navigator.of(context).pop();
            }),
            if (_isLoading)
              const Expanded(
                child: AppListShimmer(padding: EdgeInsets.only(top: 12)),
              )
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!.message)))
            else if (_payments.isEmpty)
              Expanded(
                child: Center(
                  child: Text('subscriptions.payment_history.empty'.tr()),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return PaymentHistoryItem(
                      payment: payment,
                      onDownload: () => _downloadAndOpenInvoice(payment),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
