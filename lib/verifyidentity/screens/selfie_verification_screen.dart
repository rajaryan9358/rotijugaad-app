import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/widgets/app_loading_indicator.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class SelfieVerificationScreen extends StatefulWidget {
  final int employeeId;

  const SelfieVerificationScreen({super.key, required this.employeeId});

  @override
  State<StatefulWidget> createState() => _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cams = [];
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _isInit = false;
  bool _isUploading = false;
  bool _flash = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cams.isEmpty) return;
      _initController(_cams[_cameraIndex]);
    }
  }

  Future<void> _init() async {
    try {
      _cams = await availableCameras();
      if (_cams.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('verify.identity.unable_access_camera'.tr()),
            ),
          );
        }
        return;
      }

      final frontIndex = _cams.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _cameraIndex = frontIndex >= 0 ? frontIndex : 0;
      await _initController(_cams[_cameraIndex]);
      setState(() => _isInit = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('verify.identity.unable_access_camera'.tr())),
        );
      }
    }
  }

  Future<void> _initController(CameraDescription cam) async {
    final ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = ctrl;
    await ctrl.initialize();
    if (mounted) setState(() {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _captureAndUpload() async {
    if (_isUploading) return;
    if (!(_controller?.value.isInitialized ?? false)) return;

    setState(() {
      _isUploading = true;
      _flash = true;
    });

    Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _flash = false);
    });

    try {
      final pic = await _controller!.takePicture();
      final file = File(pic.path);

      final updated = await context.read<EmployeesProvider>().uploadSelfie(
        employeeId: widget.employeeId,
        file: file,
      );

      if (!mounted) return;

      if (updated == null) {
        final msg =
            context.read<EmployeesProvider>().lastError?.message ??
            'verify.identity.failed_document_upload'.tr();
        _snack(msg);
        setState(() => _isUploading = false);
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('Capture/upload error: $e');
      if (mounted) {
        _snack('verify.identity.unable_capture_selfie'.tr());
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _isInit && (_controller?.value.isInitialized == true);

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.spacing.md),
                  Text(
                    'verify.identity.capture_selfie_title'.tr(),
                    style: context.text.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  Text(
                    'verify.identity.capture_selfie_desc'.tr(),
                    style: context.text.bodyMedium,
                  ),
                  Expanded(
                    child: Center(
                      child: ready
                          ? _CircularPreview(controller: _controller!)
                          : const AppLoadingIndicator.page(),
                    ),
                  ),
                  Center(
                    child: IconButton(
                      onPressed: (!ready || _isUploading)
                          ? null
                          : _captureAndUpload,
                      icon: Image.asset('assets/images/img_capture.png'),
                    ),
                  ),
                  SizedBox(height: context.spacing.sm),
                ],
              ),
            ),
            IgnorePointer(
              ignoring: !_flash,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: _flash ? 1 : 0,
                child: Container(color: Colors.white),
              ),
            ),
            if (_isUploading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: AppLoadingIndicator.page(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircularPreview extends StatelessWidget {
  final CameraController controller;

  const _CircularPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final size = controller.value.previewSize;
    if (size == null) {
      return const SizedBox.shrink();
    }

    const diameter = 300.0;
    const borderWidth = 2.0;
    final borderColor = Colors.white.withValues(alpha: 0.85);

    final portraitAR = size.height / size.width;

    Widget preview = FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        height: diameter,
        width: diameter * portraitAR,
        child: CameraPreview(controller),
      ),
    );

    if (controller.description.lensDirection == CameraLensDirection.front) {
      preview = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
        child: preview,
      );
    }

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        color: cs.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(child: preview),
    );
  }
}
