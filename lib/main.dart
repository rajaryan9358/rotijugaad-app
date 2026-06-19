import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/providers/auth_provider.dart';
import 'package:rotijugaad/auth/screens/welcome_screen.dart';
import 'package:rotijugaad/applicants/providers/applicants_provider.dart';
import 'package:rotijugaad/candidates/providers/candidates_provider.dart';
import 'package:rotijugaad/masters/providers/masters_provider.dart';
import 'package:rotijugaad/network/network_status_provider.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/stories/providers/stories_provider.dart';
import 'package:rotijugaad/jobs/providers/jobs_provider.dart';
import 'package:rotijugaad/container/screens/no_internet_screen.dart';
import 'package:rotijugaad/settings/providers/app_settings_provider.dart';
import 'package:rotijugaad/theme/theme_controller.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/settings/providers/language_provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import 'package:rotijugaad/deeplinks/deep_link_pending.dart';
import 'package:rotijugaad/notifications/notification_service.dart';
import 'package:rotijugaad/network/api_service.dart';
import 'package:rotijugaad/auth/utils/logout_manager.dart';
import 'package:rotijugaad/navigation/app_navigator.dart';
import 'package:rotijugaad/users/services/users_service.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/theme/scaled_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SharedPrefUtils.init();
  await NotificationService.init();

  ApiService.onForcedLogout = ({required String code, String? message}) async {
    // Best-effort: if we cannot reach a BuildContext, at least clear local auth.
    final ctx = AppNavigator.context;
    if (ctx == null) {
      await SharedPrefUtils.clear();
      return;
    }

    await LogoutManager.logoutToAuthScreen(ctx);
  };

  final storedLang = SharedPrefUtils.readStr(
    SharedPrefUtils.APP_LANGUAGE,
  ).trim().toLowerCase();
  final startLocale = storedLang == 'hi'
      ? const Locale('hi')
      : const Locale('en');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeController()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider.value(value: NetworkStatusProvider.instance),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => MastersProvider()),
          ChangeNotifierProvider(create: (_) => EmployeesProvider()),
          ChangeNotifierProvider(create: (_) => EmployersProvider()),
          ChangeNotifierProvider(create: (_) => StoriesProvider()),
          ChangeNotifierProvider(create: (_) => JobsProvider()),
          ChangeNotifierProvider(create: (_) => ApplicantsProvider()),
          ChangeNotifierProvider(create: (_) => CandidatesProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  final UsersService _usersService = UsersService();
  StreamSubscription<Uri>? _sub;
  bool _isSyncingLastActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    _syncLastActive();
  }

  int? _currentUserId() {
    if (!SharedPrefUtils.readBool(SharedPrefUtils.AUTH_LOGGED_IN)) {
      return null;
    }

    final user = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final raw = user?['id'] ?? user?['userId'];
    if (raw is int && raw > 0) return raw;
    final parsed = int.tryParse(raw?.toString() ?? '');
    return (parsed != null && parsed > 0) ? parsed : null;
  }

  Future<void> _syncLastActive() async {
    if (_isSyncingLastActive) return;

    final userId = _currentUserId();
    if (userId == null) return;

    _isSyncingLastActive = true;
    try {
      final result = await _usersService.updateLastActiveAt(userId);
      switch (result) {
        case Success(value: final payload):
          final user = payload['user'];
          if (user is Map<String, dynamic>) {
            await SharedPrefUtils.saveJson(
              SharedPrefUtils.AUTH_USER_JSON,
              user,
            );
          }
          break;
        case Failure():
          break;
      }
    } catch (_) {
      // Best-effort only.
    } finally {
      _isSyncingLastActive = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // ignore: discarded_futures
      _syncLastActive();
    }
  }

  Future<void> _initDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await DeepLinkPending.storeFromUri(initial);
      }
    } catch (_) {}

    if (!mounted) return;

    void tryConsumePending() {
      final ctx = AppNavigator.context;
      if (ctx == null) return;
      // ignore: unawaited_futures
      DeepLinkPending.consumeAndNavigate(
        ctx,
        navigator: AppNavigator.navKey.currentState,
      );
    }

    // Attempt once after first frame so Navigator/Overlay exist.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      tryConsumePending();
    });

    _sub = _appLinks.uriLinkStream.listen((uri) {
      // ignore: unawaited_futures
      () async {
        await DeepLinkPending.storeFromUri(uri);
        if (!mounted) return;
        tryConsumePending();
      }();
    }, onError: (_) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isOffline = context.watch<NetworkStatusProvider>().isOffline;
    final language = context.watch<LanguageProvider>();

    final desiredLocale = language.isHindi
        ? const Locale('hi')
        : const Locale('en');

    // Keep EasyLocalization locale in sync with provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLocale = context.locale;
      if (currentLocale.languageCode != desiredLocale.languageCode) {
        context.setLocale(desiredLocale);
      }
    });

    return MaterialApp(
      title: 'Roti Jugaad',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navKey,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        if (isOffline) {
          return const NoInternetScreen();
        }
        return ScaledTheme(child: child ?? const SizedBox.shrink());
      },
      home: WelcomeScreen(),
    );
  }
}
