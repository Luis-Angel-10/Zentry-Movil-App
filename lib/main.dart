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
import 'package:Zentry/core/providers/virtual_pet_controller.dart';
import 'package:Zentry/core/services/notification_service.dart';
import 'package:Zentry/theme/theme_controller.dart';
import 'package:Zentry/theme/app_theme.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cliente HTTP y almacenamiento seguro del JWT listos antes de arrancar la UI.
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

class _ZentryAppState extends State<ZentryApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

    engagementController.notifications = notificationsController;
    postsController.notifications = notificationsController;
    communityController.notifications = notificationsController;
    collaborationController.notifications = notificationsController;

    // Cuando el backend invalida la sesión (401/403), limpiar y volver al login.
    ApiClient.instance.onSessionInvalid = authController.handleSessionInvalid;

    await Future.wait([
      themeController.load(),
      localeProvider.load(),
      authController.load(),
      engagementController.load(),
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

    // Lectura del feed real (no bloquea el arranque: si el backend no responde
    // se conserva el feed local y `feedError` queda disponible para la UI).
    unawaited(postsController.syncFromBackend());

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
