import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/screens/language_screen.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/container/screens/main_container.dart';
import 'package:rotijugaad/container/screens/employer_container.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/settings/providers/app_settings_provider.dart';
import 'package:rotijugaad/deeplinks/deep_link_pending.dart';
import 'package:video_player/video_player.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final VideoPlayerController _videoController;
  final Completer<void> _videoCompleted = Completer<void>();
  bool _didNavigate = false;
  bool _videoReady = false;

  Future<void> _bootstrap() async {
    await Future.wait([
      context.read<MastersProvider>().loadMasters(),
      context.read<AppSettingsProvider>().loadSettings(force: true),
      _videoCompleted.future,
    ]);

    if (!mounted) return;
    if (_didNavigate) return;

    final loggedIn = SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN);
    final userType = SharedPrefUtils.readStr(SharedPrefUtils.USER_TYPE);

    // If a deeplink arrived and user is not logged in, route to signup/login.
    if (!loggedIn) {
      final pending = DeepLinkPending.read();
      final type = (pending?['type'] ?? '').toString().toLowerCase();
      if (type.isNotEmpty) {
        _didNavigate = true;
        await DeepLinkPending.consumeAndNavigate(context);
        return;
      }
    }

    if (loggedIn) {
      final isEmployer = userType.trim().toLowerCase() == 'employer';
      _didNavigate = true;
      Navigator.pushReplacement(
        context,
        AppPageRoute.slideFade(
          page: isEmployer ? EmployerContainer() : MainContainer(),
        ),
      );
      return;
    }

    _didNavigate = true;
    Navigator.pushReplacement(
      context,
      AppPageRoute.slideFade(page: LanguageScreen()),
    );
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/images/welcome.mp4');
    try {
      await _videoController.initialize();
      await _videoController.setLooping(false);
      _videoController.addListener(_handleVideoProgress);
      await _videoController.play();
      if (!mounted) return;
      setState(() {
        _videoReady = true;
      });
    } catch (_) {
      if (!_videoCompleted.isCompleted) {
        _videoCompleted.complete();
      }
    }
  }

  void _handleVideoProgress() {
    if (_videoCompleted.isCompleted) return;

    final value = _videoController.value;
    if (!value.isInitialized) return;

    final duration = value.duration;
    final position = value.position;
    if (duration <= Duration.zero) return;

    if (position >= duration - const Duration(milliseconds: 200)) {
      _videoCompleted.complete();
    }
  }

  @override
  void initState() {
    super.initState();
    _initVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _videoController.removeListener(_handleVideoProgress);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoValue = _videoController.value;
    final videoAspectRatio =
        videoValue.isInitialized && videoValue.aspectRatio > 0
        ? videoValue.aspectRatio
        : (9 / 16);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: _videoReady && videoValue.isInitialized
            ? Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: AspectRatio(
                    aspectRatio: videoAspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
            : const ColoredBox(color: Colors.white),
      ),
    );
  }
}
