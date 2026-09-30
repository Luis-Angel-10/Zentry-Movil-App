import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/features/home/home_page.dart';
import 'package:Zentry/features/auth/login_page.dart';
import 'package:Zentry/core/navigation/app_navigator.dart';
import 'package:Zentry/core/network/api_client.dart';
import 'package:Zentry/core/network/token_storage.dart';
import 'package:Zentry/core/providers/locale_provider.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/collaboration_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/creative_challenge_controller.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/core/providers/follow_controller.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';
import 'package:Zentry/core/providers/portfolio_controller.dart';
import 'package:Zentry/core/providers/posts_controller.dart';
import 'package:Zentry/core/providers/streak_controller.dart';
import 'package:Zentry/core/providers/virtual_pet_controller.dart';
import 'package:Zentry/core/providers/wallet_controller.dart';
import 'package:Zentry/core/services/fcm_service.dart';
import 'package:Zentry/core/services/notification_service.dart';
import 'package:Zentry/theme/theme_controller.dart';
import 'package:Zentry/theme/app_theme.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient.instance.init();
  await TokenStorage.instance.warmUp();

  runApp(const MyApp());
}

class _FallbackLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  const _FallbackLocalizationsDelegate(this._delegate, this._fallbackLocale);

  final LocalizationsDelegate<T> _delegate;
  final Locale _fallbackLocale;

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'nah' || _delegate.isSupported(locale);

  @override
  Future<T> load(Locale locale) {
    final effectiveLocale = locale.languageCode == 'nah'
        ? _fallbackLocale
        : locale;
    return _delegate.load(effectiveLocale);
  }

  @override
  bool shouldReload(_FallbackLocalizationsDelegate<T> old) => false;
}

const _kFrameworkFallbackLocale = Locale('es', 'MX');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => EngagementController()),
        ChangeNotifierProvider(create: (_) => PostsController()),
        ChangeNotifierProvider(create: (_) => CommunityController()),
        ChangeNotifierProvider(create: (_) => FollowController()),
        ChangeNotifierProvider(create: (_) => PortfolioController()),
        ChangeNotifierProvider(create: (_) => CollaborationController()),
        ChangeNotifierProvider(create: (_) => CreativeChallengeController()),
        ChangeNotifierProvider(create: (_) => NotificationsController()),
        ChangeNotifierProvider(create: (_) => VirtualPetController()),
        ChangeNotifierProvider(create: (_) => StreakController()),
        ChangeNotifierProvider(create: (_) => WalletController()),
      ],
      child: const ZentryApp(),
    );
  }
}

class ZentryApp extends StatefulWidget {
  const ZentryApp({super.key});

  @override
  State<ZentryApp> createState() => _ZentryAppState();
}

class _ZentryAppState extends State<ZentryApp> with WidgetsBindingObserver {
  bool _isLoading = true;
  DateTime? _lastResumeRefresh;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || state != AppLifecycleState.resumed || _isLoading) return;

    final now = DateTime.now();
    if (_lastResumeRefresh != null &&
        now.difference(_lastResumeRefresh!) < const Duration(seconds: 30)) {
      return;
    }
    _lastResumeRefresh = now;

    final auth = context.read<AuthController>();
    if (!auth.isLoggedIn) return;
    context.read<StreakController>().load();
    context.read<PostsController>().loadBackendStories();
  }

  Future<void> _loadInitialData() async {
    final themeController = context.read<ThemeController>();
    final localeProvider = context.read<LocaleProvider>();
    final authController = context.read<AuthController>();
    final engagementController = context.read<EngagementController>();
    final postsController = context.read<PostsController>();
    final notificationsController = context.read<NotificationsController>();
    final communityController = context.read<CommunityController>();
    final followController = context.read<FollowController>();
    final portfolioController = context.read<PortfolioController>();
    final collaborationController = context.read<CollaborationController>();
    final creativeChallengeController = context
        .read<CreativeChallengeController>();
    final virtualPetController = context.read<VirtualPetController>();
    final streakController = context.read<StreakController>();
    final walletController = context.read<WalletController>();

    engagementController.notifications = notificationsController;
    postsController.notifications = notificationsController;
    communityController.notifications = notificationsController;
    collaborationController.notifications = notificationsController;

    ApiClient.instance.onSessionInvalid = authController.handleSessionInvalid;

    // La racha real del backend alimenta los logros `streak_*` y el reto
    // semanal de racha de EngagementController (que ya no tiene contador de
    // racha propio). syncBackendStreak ignora respuestas de otra cuenta.
    void syncStreakIntoEngagement() {
      final data = streakController.data;
      if (data == null) return;
      engagementController.syncBackendStreak(
        userId: data.userId,
        currentStreak: data.currentStreak,
        longestStreak: data.longestStreak,
      );
    }

    streakController.addListener(syncStreakIntoEngagement);

    // Engagement por usuario: se carga sólo el namespace del usuario
    // autenticado (ver EngagementController.bindUser).
    Future<void> bindEngagement() async {
      await engagementController.bindUser(authController.currentUser?.id);
      syncStreakIntoEngagement();
    }

    authController.onSessionEstablished = () {
      // Racha por usuario: se descarta cualquier valor de la cuenta anterior
      // antes de pedir la del usuario que acaba de entrar.
      streakController.reset();
      unawaited(streakController.load());
      unawaited(bindEngagement());
      unawaited(walletController.load());
      unawaited(postsController.loadBackendStories());
    };

    authController.onSessionCleared = () {
      streakController.reset();
      unawaited(engagementController.bindUser(null));
    };

    await Future.wait([
      themeController.load(),
      localeProvider.load(),
      authController.load(),
      postsController.load(),
      notificationsController.load(),
      communityController.load(),
      followController.load(),
      portfolioController.load(),
      collaborationController.load(),
      creativeChallengeController.load(),
      virtualPetController.load(),
      NotificationService.instance.init(),
    ]);

    // Tras authController.load() ya se sabe qué usuario (si hay) restauró
    // sesión; antes de eso no hay namespace que cargar.
    unawaited(bindEngagement());

    unawaited(FcmService.instance.init());

    unawaited(postsController.syncFromBackend());

    unawaited(streakController.load());
    unawaited(walletController.load());
    unawaited(postsController.loadBackendStories());

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xff09090F),
          body: Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          ),
        ),
      );
    }

    return Consumer2<LocaleProvider, ThemeController>(
      builder: (context, localeProvider, themeController, child) {
        return MaterialApp(
          title: 'Zentry App',
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,

          localizationsDelegates: [
            AppLocalizations.delegate,
            const _FallbackLocalizationsDelegate<MaterialLocalizations>(
              GlobalMaterialLocalizations.delegate,
              _kFrameworkFallbackLocale,
            ),
            const _FallbackLocalizationsDelegate<WidgetsLocalizations>(
              GlobalWidgetsLocalizations.delegate,
              _kFrameworkFallbackLocale,
            ),
            const _FallbackLocalizationsDelegate<CupertinoLocalizations>(
              GlobalCupertinoLocalizations.delegate,
              _kFrameworkFallbackLocale,
            ),
          ],

          supportedLocales: AppLocalizations.supportedLocales,

          locale: localeProvider.locale,

          theme: AppTheme.light(
            themeController.accentColor,
            themeController.rounded,
          ),
          darkTheme: AppTheme.dark(
            themeController.accentColor,
            themeController.rounded,
          ),
          themeMode: themeController.themeMode,

          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(themeController.textScale),
              ),
              child: child!,
            );
          },

          home: Consumer<AuthController>(
            builder: (context, auth, _) {
              return auth.isLoggedIn ? const HomePage() : const LoginPage();
            },
          ),
        );
      },
    );
  }
}
