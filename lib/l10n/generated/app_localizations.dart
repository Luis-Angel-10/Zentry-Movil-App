import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';
import 'app_localizations_nah.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('es', 'MX'),
    Locale('nah'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In es_MX, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In es_MX, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonAccept.
  ///
  /// In es_MX, this message translates to:
  /// **'Aceptar'**
  String get commonAccept;

  /// No description provided for @commonDelete.
  ///
  /// In es_MX, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In es_MX, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In es_MX, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar'**
  String get commonSearch;

  /// No description provided for @commonSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar...'**
  String get commonSearchHint;

  /// No description provided for @commonBack.
  ///
  /// In es_MX, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In es_MX, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonConfirm.
  ///
  /// In es_MX, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In es_MX, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonReset.
  ///
  /// In es_MX, this message translates to:
  /// **'Restablecer'**
  String get commonReset;

  /// No description provided for @commonSeeMore.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver más'**
  String get commonSeeMore;

  /// No description provided for @commonSeeAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver todo'**
  String get commonSeeAll;

  /// No description provided for @commonLoading.
  ///
  /// In es_MX, this message translates to:
  /// **'Cargando...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In es_MX, this message translates to:
  /// **'Ocurrió un error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In es_MX, this message translates to:
  /// **'Listo'**
  String get commonSuccess;

  /// No description provided for @commonYes.
  ///
  /// In es_MX, this message translates to:
  /// **'Sí'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In es_MX, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonShare.
  ///
  /// In es_MX, this message translates to:
  /// **'Compartir'**
  String get commonShare;

  /// No description provided for @commonReport.
  ///
  /// In es_MX, this message translates to:
  /// **'Reportar'**
  String get commonReport;

  /// No description provided for @commonBlock.
  ///
  /// In es_MX, this message translates to:
  /// **'Bloquear'**
  String get commonBlock;

  /// No description provided for @commonFollow.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguir'**
  String get commonFollow;

  /// No description provided for @commonUnfollow.
  ///
  /// In es_MX, this message translates to:
  /// **'Dejar de seguir'**
  String get commonUnfollow;

  /// No description provided for @commonSend.
  ///
  /// In es_MX, this message translates to:
  /// **'Enviar'**
  String get commonSend;

  /// No description provided for @commonContinue.
  ///
  /// In es_MX, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonSkip.
  ///
  /// In es_MX, this message translates to:
  /// **'Omitir'**
  String get commonSkip;

  /// No description provided for @commonDone.
  ///
  /// In es_MX, this message translates to:
  /// **'Listo'**
  String get commonDone;

  /// No description provided for @commonOptions.
  ///
  /// In es_MX, this message translates to:
  /// **'Opciones'**
  String get commonOptions;

  /// No description provided for @commonSettings.
  ///
  /// In es_MX, this message translates to:
  /// **'Configuración'**
  String get commonSettings;

  /// No description provided for @commonNoResultsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No se encontraron resultados'**
  String get commonNoResultsTitle;

  /// No description provided for @commonNoResultsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Intenta con otra búsqueda.'**
  String get commonNoResultsSubtitle;

  /// No description provided for @languageScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Idioma'**
  String get languageScreenTitle;

  /// No description provided for @languageScreenHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Selecciona tu idioma'**
  String get languageScreenHeading;

  /// No description provided for @languageScreenSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Elige el idioma en el que deseas utilizar Zentry.'**
  String get languageScreenSubtitle;

  /// No description provided for @languageScreenLanguagesStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Idiomas'**
  String get languageScreenLanguagesStat;

  /// No description provided for @languageScreenCoverageStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Cobertura'**
  String get languageScreenCoverageStat;

  /// No description provided for @languageScreenCoverageValue.
  ///
  /// In es_MX, this message translates to:
  /// **'Global'**
  String get languageScreenCoverageValue;

  /// No description provided for @languageScreenSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar idioma...'**
  String get languageScreenSearchHint;

  /// No description provided for @languageScreenRecommended.
  ///
  /// In es_MX, this message translates to:
  /// **'Recomendados'**
  String get languageScreenRecommended;

  /// No description provided for @languageScreenAllLanguages.
  ///
  /// In es_MX, this message translates to:
  /// **'Todos los idiomas'**
  String get languageScreenAllLanguages;

  /// No description provided for @languageScreenEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No se encontraron idiomas'**
  String get languageScreenEmptyTitle;

  /// No description provided for @languageScreenEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Intenta con otra búsqueda.'**
  String get languageScreenEmptySubtitle;

  /// No description provided for @languageScreenReset.
  ///
  /// In es_MX, this message translates to:
  /// **'Restablecer'**
  String get languageScreenReset;

  /// No description provided for @languageScreenCurrent.
  ///
  /// In es_MX, this message translates to:
  /// **'Idioma actual'**
  String get languageScreenCurrent;

  /// No description provided for @languageScreenSpanishName.
  ///
  /// In es_MX, this message translates to:
  /// **'Español (México)'**
  String get languageScreenSpanishName;

  /// No description provided for @languageScreenSpanishNative.
  ///
  /// In es_MX, this message translates to:
  /// **'Español'**
  String get languageScreenSpanishNative;

  /// No description provided for @languageScreenNahuatlName.
  ///
  /// In es_MX, this message translates to:
  /// **'Náhuatl'**
  String get languageScreenNahuatlName;

  /// No description provided for @languageScreenNahuatlNative.
  ///
  /// In es_MX, this message translates to:
  /// **'Nāhuatl'**
  String get languageScreenNahuatlNative;

  /// No description provided for @authLoginWelcomeTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Bienvenido a Zentry'**
  String get authLoginWelcomeTitle;

  /// No description provided for @authLoginEmailHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Email'**
  String get authLoginEmailHint;

  /// No description provided for @authLoginPasswordHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Password'**
  String get authLoginPasswordHint;

  /// No description provided for @authLoginSubmitButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Iniciar sesión'**
  String get authLoginSubmitButton;

  /// No description provided for @authLoginNoAccountText.
  ///
  /// In es_MX, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get authLoginNoAccountText;

  /// No description provided for @authLoginEmailValidationError.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa un correo válido'**
  String get authLoginEmailValidationError;

  /// No description provided for @authLoginPasswordValidationError.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get authLoginPasswordValidationError;

  /// No description provided for @authLoginInvalidCredentialsError.
  ///
  /// In es_MX, this message translates to:
  /// **'Correo o contraseña incorrectos'**
  String get authLoginInvalidCredentialsError;

  /// No description provided for @authLoginUseBiometricButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Usar huella'**
  String get authLoginUseBiometricButton;

  /// No description provided for @authLoginUsePasswordButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Usar contraseña'**
  String get authLoginUsePasswordButton;

  /// No description provided for @authLoginBiometricPrompt.
  ///
  /// In es_MX, this message translates to:
  /// **'Confirma tu identidad con huella o rostro para continuar'**
  String get authLoginBiometricPrompt;

  /// No description provided for @authLoginBiometricFailedError.
  ///
  /// In es_MX, this message translates to:
  /// **'No se pudo verificar tu huella, intenta de nuevo'**
  String get authLoginBiometricFailedError;

  /// No description provided for @authRegisterHeadline.
  ///
  /// In es_MX, this message translates to:
  /// **'Configura tu perfil creativo'**
  String get authRegisterHeadline;

  /// No description provided for @authRegisterSubheading.
  ///
  /// In es_MX, this message translates to:
  /// **'Solo toma unos minutos comenzar.'**
  String get authRegisterSubheading;

  /// No description provided for @authRegisterFullNameHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Nombre completo o artístico'**
  String get authRegisterFullNameHint;

  /// No description provided for @authRegisterArtistNameHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Nombre artístico (opcional)'**
  String get authRegisterArtistNameHint;

  /// No description provided for @authRegisterUsernameHint.
  ///
  /// In es_MX, this message translates to:
  /// **'@username'**
  String get authRegisterUsernameHint;

  /// No description provided for @authRegisterEmailHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Correo electrónico'**
  String get authRegisterEmailHint;

  /// No description provided for @authRegisterPasswordHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Contraseña'**
  String get authRegisterPasswordHint;

  /// No description provided for @authRegisterDisciplineTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Selecciona tus intereses'**
  String get authRegisterDisciplineTitle;

  /// No description provided for @authRegisterDisciplineSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Elige hasta 5 categorías. Con esto personalizamos Para ti.'**
  String get authRegisterDisciplineSubtitle;

  /// No description provided for @authRegisterInterestsMaxReached.
  ///
  /// In es_MX, this message translates to:
  /// **'Ya elegiste 5 intereses, quita uno para elegir otro'**
  String get authRegisterInterestsMaxReached;

  /// No description provided for @authRegisterInterestsCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count}/5 seleccionados'**
  String authRegisterInterestsCount(int count);

  /// No description provided for @authRegisterDisciplineIllustration.
  ///
  /// In es_MX, this message translates to:
  /// **'Ilustración'**
  String get authRegisterDisciplineIllustration;

  /// No description provided for @authRegisterDisciplineMusic.
  ///
  /// In es_MX, this message translates to:
  /// **'Música'**
  String get authRegisterDisciplineMusic;

  /// No description provided for @authRegisterDisciplinePhotography.
  ///
  /// In es_MX, this message translates to:
  /// **'Fotografía'**
  String get authRegisterDisciplinePhotography;

  /// No description provided for @authRegisterDisciplineWriting.
  ///
  /// In es_MX, this message translates to:
  /// **'Escritura'**
  String get authRegisterDisciplineWriting;

  /// No description provided for @authRegisterDisciplineDesign.
  ///
  /// In es_MX, this message translates to:
  /// **'Diseño'**
  String get authRegisterDisciplineDesign;

  /// No description provided for @authRegisterDisciplineVideo.
  ///
  /// In es_MX, this message translates to:
  /// **'Video'**
  String get authRegisterDisciplineVideo;

  /// No description provided for @authRegisterDisciplineSculpture.
  ///
  /// In es_MX, this message translates to:
  /// **'Escultura'**
  String get authRegisterDisciplineSculpture;

  /// No description provided for @authRegisterDisciplineArchitecture.
  ///
  /// In es_MX, this message translates to:
  /// **'Arquitectura'**
  String get authRegisterDisciplineArchitecture;

  /// No description provided for @authRegisterDisciplinePerformance.
  ///
  /// In es_MX, this message translates to:
  /// **'Performance'**
  String get authRegisterDisciplinePerformance;

  /// No description provided for @authRegisterDisciplineOther.
  ///
  /// In es_MX, this message translates to:
  /// **'Otro'**
  String get authRegisterDisciplineOther;

  /// No description provided for @authRegisterAboutTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Sobre ti'**
  String get authRegisterAboutTitle;

  /// No description provided for @authRegisterAboutSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Escribe una pequeña descripción para tu perfil.'**
  String get authRegisterAboutSubtitle;

  /// No description provided for @authRegisterBioHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Ejemplo: Soy artista digital apasionado por crear personajes, mundos creativos y experiencias visuales únicas.'**
  String get authRegisterBioHint;

  /// No description provided for @authRegisterFinishButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Finalizar'**
  String get authRegisterFinishButton;

  /// No description provided for @authRegisterFullNameValidationError.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa tu nombre'**
  String get authRegisterFullNameValidationError;

  /// No description provided for @authRegisterUsernameValidationError.
  ///
  /// In es_MX, this message translates to:
  /// **'Mínimo 3 caracteres, sin espacios'**
  String get authRegisterUsernameValidationError;

  /// No description provided for @authRegisterEmailValidationError.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa un correo válido'**
  String get authRegisterEmailValidationError;

  /// No description provided for @authRegisterPasswordValidationError.
  ///
  /// In es_MX, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get authRegisterPasswordValidationError;

  /// No description provided for @authRegisterEmailTakenError.
  ///
  /// In es_MX, this message translates to:
  /// **'Este correo ya está registrado'**
  String get authRegisterEmailTakenError;

  /// No description provided for @authRegisterUsernameTakenError.
  ///
  /// In es_MX, this message translates to:
  /// **'Este nombre de usuario ya está en uso'**
  String get authRegisterUsernameTakenError;

  /// No description provided for @authRegisterSelectDisciplineError.
  ///
  /// In es_MX, this message translates to:
  /// **'Selecciona al menos un interés para continuar'**
  String get authRegisterSelectDisciplineError;

  /// No description provided for @authRegisterSuccessMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'Cuenta creada. Inicia sesión para continuar.'**
  String get authRegisterSuccessMessage;

  /// No description provided for @editProfileTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Editar perfil'**
  String get editProfileTitle;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Nombre'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileBioLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Info'**
  String get editProfileBioLabel;

  /// No description provided for @chatEditMessageDialogTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Editar mensaje'**
  String get chatEditMessageDialogTitle;

  /// No description provided for @chatMessageForwardedSnackbar.
  ///
  /// In es_MX, this message translates to:
  /// **'Mensaje reenviado'**
  String get chatMessageForwardedSnackbar;

  /// No description provided for @chatOnlineStatusLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'En línea'**
  String get chatOnlineStatusLabel;

  /// No description provided for @chatMessageInputHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Mensaje...'**
  String get chatMessageInputHint;

  /// No description provided for @chatTabChats.
  ///
  /// In es_MX, this message translates to:
  /// **'Chats'**
  String get chatTabChats;

  /// No description provided for @chatTabStatuses.
  ///
  /// In es_MX, this message translates to:
  /// **'Estados'**
  String get chatTabStatuses;

  /// No description provided for @chatTabCalls.
  ///
  /// In es_MX, this message translates to:
  /// **'Llamadas'**
  String get chatTabCalls;

  /// No description provided for @chatMyStatusTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Mi estado'**
  String get chatMyStatusTitle;

  /// No description provided for @chatMyStatusSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Añade una actualización'**
  String get chatMyStatusSubtitle;

  /// No description provided for @chatRecentSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Recientes'**
  String get chatRecentSectionTitle;

  /// No description provided for @chatViewedSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Vistos'**
  String get chatViewedSectionTitle;

  /// No description provided for @chatForwardActionLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Reenviar'**
  String get chatForwardActionLabel;

  /// No description provided for @chatComposerImageTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Fotos seleccionadas ({count})'**
  String chatComposerImageTitle(int count);

  /// No description provided for @chatComposerVideoTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Videos seleccionados ({count})'**
  String chatComposerVideoTitle(int count);

  /// No description provided for @chatComposerCaptionHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Agrega un pie de foto (opcional)'**
  String get chatComposerCaptionHint;

  /// No description provided for @chatComposerSendButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Enviar'**
  String get chatComposerSendButton;

  /// No description provided for @chatMediaSaveButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Guardar'**
  String get chatMediaSaveButton;

  /// No description provided for @chatMediaSavedSuccess.
  ///
  /// In es_MX, this message translates to:
  /// **'Guardado en la galería'**
  String get chatMediaSavedSuccess;

  /// No description provided for @chatMediaSaveError.
  ///
  /// In es_MX, this message translates to:
  /// **'No se pudo guardar el archivo'**
  String get chatMediaSaveError;

  /// No description provided for @chatIncomingCallLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Llamada entrante'**
  String get chatIncomingCallLabel;

  /// No description provided for @chatMissedCallLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Llamada perdida'**
  String get chatMissedCallLabel;

  /// No description provided for @chatCallingVoiceLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Llamando…'**
  String get chatCallingVoiceLabel;

  /// No description provided for @chatCallingVideoLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Videollamada…'**
  String get chatCallingVideoLabel;

  /// No description provided for @chatNoStatusesLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no hay historias recientes'**
  String get chatNoStatusesLabel;

  /// No description provided for @homeAddStoryLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu historia'**
  String get homeAddStoryLabel;

  /// No description provided for @storyVisibilityPublic.
  ///
  /// In es_MX, this message translates to:
  /// **'Público'**
  String get storyVisibilityPublic;

  /// No description provided for @storyVisibilityFollowers.
  ///
  /// In es_MX, this message translates to:
  /// **'Solo seguidores'**
  String get storyVisibilityFollowers;

  /// No description provided for @storyViewersCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count, plural, =0{Nadie ha visto esto aún} one{1 vista} other{{count} vistas}}'**
  String storyViewersCount(int count);

  /// No description provided for @storyViewersTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Quién vio tu historia'**
  String get storyViewersTitle;

  /// No description provided for @storyViewersEmpty.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún nadie ha visto esta historia'**
  String get storyViewersEmpty;

  /// No description provided for @storyReplyHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Responder a la historia…'**
  String get storyReplyHint;

  /// No description provided for @storyReplyMessagePrefix.
  ///
  /// In es_MX, this message translates to:
  /// **'Respondió a tu historia: {text}'**
  String storyReplyMessagePrefix(String text);

  /// No description provided for @storyDeleteConfirmTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Eliminar historia'**
  String get storyDeleteConfirmTitle;

  /// No description provided for @storyDeleteConfirmMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'Esta historia se eliminará para siempre. ¿Quieres continuar?'**
  String get storyDeleteConfirmMessage;

  /// No description provided for @collabActiveTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboraciones'**
  String get collabActiveTitle;

  /// No description provided for @collabActiveSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Encuentra proyectos o crea el tuyo'**
  String get collabActiveSubtitle;

  /// No description provided for @collabActiveNavDiscover.
  ///
  /// In es_MX, this message translates to:
  /// **'Descubrir'**
  String get collabActiveNavDiscover;

  /// No description provided for @collabActiveNavCollaborate.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaborar'**
  String get collabActiveNavCollaborate;

  /// No description provided for @collabActiveNavMessages.
  ///
  /// In es_MX, this message translates to:
  /// **'Mensajes'**
  String get collabActiveNavMessages;

  /// No description provided for @collabActiveNavAchievements.
  ///
  /// In es_MX, this message translates to:
  /// **'Logros'**
  String get collabActiveNavAchievements;

  /// No description provided for @collabActiveNavSubscriptions.
  ///
  /// In es_MX, this message translates to:
  /// **'Suscripciones'**
  String get collabActiveNavSubscriptions;

  /// No description provided for @collabActiveProgressLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Progreso del Proyecto'**
  String get collabActiveProgressLabel;

  /// No description provided for @collabActiveViewDetails.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver Detalles'**
  String get collabActiveViewDetails;

  /// No description provided for @collabActivePublish.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicar'**
  String get collabActivePublish;

  /// No description provided for @collabActiveCreateProject.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear Proyecto'**
  String get collabActiveCreateProject;

  /// No description provided for @collabExploreTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboraciones'**
  String get collabExploreTitle;

  /// No description provided for @collabExploreSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Encuentra proyectos o crea el tuyo'**
  String get collabExploreSubtitle;

  /// No description provided for @collabExploreTabDiscover.
  ///
  /// In es_MX, this message translates to:
  /// **'Descubrir Proyectos'**
  String get collabExploreTabDiscover;

  /// No description provided for @collabExploreTabMine.
  ///
  /// In es_MX, this message translates to:
  /// **'Mis Colaboraciones'**
  String get collabExploreTabMine;

  /// No description provided for @collabExplorePublish.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicar'**
  String get collabExplorePublish;

  /// No description provided for @collabExploreCreateProject.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear Proyecto'**
  String get collabExploreCreateProject;

  /// No description provided for @communitiesScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades'**
  String get communitiesScreenTitle;

  /// No description provided for @communitiesHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades'**
  String get communitiesHeading;

  /// No description provided for @communitiesSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Encuentra personas que comparten tus intereses'**
  String get communitiesSubtitle;

  /// No description provided for @communitiesStatCommunities.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades'**
  String get communitiesStatCommunities;

  /// No description provided for @communitiesStatTrending.
  ///
  /// In es_MX, this message translates to:
  /// **'Tendencias'**
  String get communitiesStatTrending;

  /// No description provided for @communitiesStatVerified.
  ///
  /// In es_MX, this message translates to:
  /// **'Verificadas'**
  String get communitiesStatVerified;

  /// No description provided for @communitiesStatMine.
  ///
  /// In es_MX, this message translates to:
  /// **'Mis comunidades'**
  String get communitiesStatMine;

  /// No description provided for @communitiesSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar por nombre, categoría o hashtag...'**
  String get communitiesSearchHint;

  /// No description provided for @communitiesFeaturedTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'⭐ Destacadas'**
  String get communitiesFeaturedTitle;

  /// No description provided for @communitiesSeeAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver todas'**
  String get communitiesSeeAll;

  /// No description provided for @communitiesHotBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'HOT'**
  String get communitiesHotBadge;

  /// No description provided for @communitiesMemberLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Miembro'**
  String get communitiesMemberLabel;

  /// No description provided for @communitiesJoinLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Unirse'**
  String get communitiesJoinLabel;

  /// No description provided for @communitiesEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No se encontraron comunidades'**
  String get communitiesEmptyTitle;

  /// No description provided for @communitiesEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Prueba otra búsqueda o explora nuevas categorías.'**
  String get communitiesEmptySubtitle;

  /// No description provided for @communitiesExploringSnackbar.
  ///
  /// In es_MX, this message translates to:
  /// **'Explorando nuevas comunidades...'**
  String get communitiesExploringSnackbar;

  /// No description provided for @communitiesExploreButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Explorar'**
  String get communitiesExploreButton;

  /// No description provided for @communitiesSectionMine.
  ///
  /// In es_MX, this message translates to:
  /// **'Mis comunidades'**
  String get communitiesSectionMine;

  /// No description provided for @communitiesSectionDiscover.
  ///
  /// In es_MX, this message translates to:
  /// **'Descubrir comunidades'**
  String get communitiesSectionDiscover;

  /// No description provided for @communitiesSectionRecommended.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades recomendadas'**
  String get communitiesSectionRecommended;

  /// No description provided for @communitiesSectionPopular.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades populares'**
  String get communitiesSectionPopular;

  /// No description provided for @communitiesSectionNew.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades nuevas'**
  String get communitiesSectionNew;

  /// No description provided for @communitiesSectionActive.
  ///
  /// In es_MX, this message translates to:
  /// **'Más activas'**
  String get communitiesSectionActive;

  /// No description provided for @communitiesCreateButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear comunidad'**
  String get communitiesCreateButton;

  /// No description provided for @communitiesNoneJoinedHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no te has unido a ninguna comunidad.'**
  String get communitiesNoneJoinedHint;

  /// No description provided for @communitiesPrivateBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'Privada'**
  String get communitiesPrivateBadge;

  /// No description provided for @communitiesPublicBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'Pública'**
  String get communitiesPublicBadge;

  /// No description provided for @communitiesPostsCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} publicaciones'**
  String communitiesPostsCount(int count);

  /// No description provided for @communitiesRequestPendingLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud enviada'**
  String get communitiesRequestPendingLabel;

  /// No description provided for @communitiesRequestLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitar'**
  String get communitiesRequestLabel;

  /// No description provided for @communitiesViewButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver comunidad'**
  String get communitiesViewButton;

  /// No description provided for @communityCreateTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear comunidad'**
  String get communityCreateTitle;

  /// No description provided for @communityCreateNameLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Nombre'**
  String get communityCreateNameLabel;

  /// No description provided for @communityCreateNameHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Ej. Dibujo Digital MX'**
  String get communityCreateNameHint;

  /// No description provided for @communityCreateDescriptionLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Descripción'**
  String get communityCreateDescriptionLabel;

  /// No description provided for @communityCreateDescriptionHint.
  ///
  /// In es_MX, this message translates to:
  /// **'¿De qué trata esta comunidad?'**
  String get communityCreateDescriptionHint;

  /// No description provided for @communityCreateIconLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Ícono'**
  String get communityCreateIconLabel;

  /// No description provided for @communityCreateCoverLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Portada'**
  String get communityCreateCoverLabel;

  /// No description provided for @communityCreateCategoryLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Categoría'**
  String get communityCreateCategoryLabel;

  /// No description provided for @communityCreateSubcategoryLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Subcategoría (opcional)'**
  String get communityCreateSubcategoryLabel;

  /// No description provided for @communityCreateSubcategoryNone.
  ///
  /// In es_MX, this message translates to:
  /// **'Ninguna'**
  String get communityCreateSubcategoryNone;

  /// No description provided for @communityCreateHashtagsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Hashtags'**
  String get communityCreateHashtagsLabel;

  /// No description provided for @communityCreateHashtagsHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Sepáralos con comas'**
  String get communityCreateHashtagsHint;

  /// No description provided for @communityCreatePrivacyLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Tipo de comunidad'**
  String get communityCreatePrivacyLabel;

  /// No description provided for @communityCreatePrivacyPublic.
  ///
  /// In es_MX, this message translates to:
  /// **'Pública'**
  String get communityCreatePrivacyPublic;

  /// No description provided for @communityCreatePrivacyPublicDesc.
  ///
  /// In es_MX, this message translates to:
  /// **'Cualquiera puede verla y unirse'**
  String get communityCreatePrivacyPublicDesc;

  /// No description provided for @communityCreatePrivacyPrivate.
  ///
  /// In es_MX, this message translates to:
  /// **'Privada'**
  String get communityCreatePrivacyPrivate;

  /// No description provided for @communityCreatePrivacyPrivateDesc.
  ///
  /// In es_MX, this message translates to:
  /// **'Los usuarios deben solicitar unirse'**
  String get communityCreatePrivacyPrivateDesc;

  /// No description provided for @communityCreateRulesLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Reglas (opcional)'**
  String get communityCreateRulesLabel;

  /// No description provided for @communityCreateRulesHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Normas de convivencia de la comunidad'**
  String get communityCreateRulesHint;

  /// No description provided for @communityCreateSubmitButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear comunidad'**
  String get communityCreateSubmitButton;

  /// No description provided for @communityCreateNameRequiredError.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa un nombre'**
  String get communityCreateNameRequiredError;

  /// No description provided for @communityCreateDescriptionRequiredError.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa una descripción'**
  String get communityCreateDescriptionRequiredError;

  /// No description provided for @communityCreatedSnackbar.
  ///
  /// In es_MX, this message translates to:
  /// **'¡Comunidad creada!'**
  String get communityCreatedSnackbar;

  /// No description provided for @communityDetailJoinButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Unirse'**
  String get communityDetailJoinButton;

  /// No description provided for @communityDetailRequestButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitar unirse'**
  String get communityDetailRequestButton;

  /// No description provided for @communityDetailPendingButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud pendiente'**
  String get communityDetailPendingButton;

  /// No description provided for @communityDetailLeaveButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Salir'**
  String get communityDetailLeaveButton;

  /// No description provided for @communityDetailOwnerCannotLeave.
  ///
  /// In es_MX, this message translates to:
  /// **'Eres el creador: elimina la comunidad en vez de salir.'**
  String get communityDetailOwnerCannotLeave;

  /// No description provided for @communityDetailAboutTab.
  ///
  /// In es_MX, this message translates to:
  /// **'Información'**
  String get communityDetailAboutTab;

  /// No description provided for @communityDetailPostsTab.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get communityDetailPostsTab;

  /// No description provided for @communityDetailMembersTab.
  ///
  /// In es_MX, this message translates to:
  /// **'Miembros'**
  String get communityDetailMembersTab;

  /// No description provided for @communityDetailRulesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Reglas'**
  String get communityDetailRulesTitle;

  /// No description provided for @communityDetailNoRules.
  ///
  /// In es_MX, this message translates to:
  /// **'Esta comunidad no tiene reglas específicas.'**
  String get communityDetailNoRules;

  /// No description provided for @communityDetailAdminsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Administración'**
  String get communityDetailAdminsTitle;

  /// No description provided for @communityDetailOwnerLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Creador'**
  String get communityDetailOwnerLabel;

  /// No description provided for @communityDetailModeratorLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Moderador'**
  String get communityDetailModeratorLabel;

  /// No description provided for @communityDetailMemberRoleLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Miembro'**
  String get communityDetailMemberRoleLabel;

  /// No description provided for @communityDetailMembersCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} miembros'**
  String communityDetailMembersCount(int count);

  /// No description provided for @communityDetailPostsEmpty.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no hay publicaciones en esta comunidad.'**
  String get communityDetailPostsEmpty;

  /// No description provided for @communityDetailCreatePostButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicar en la comunidad'**
  String get communityDetailCreatePostButton;

  /// No description provided for @communityDetailJoinToPost.
  ///
  /// In es_MX, this message translates to:
  /// **'Únete a la comunidad para publicar.'**
  String get communityDetailJoinToPost;

  /// No description provided for @communityDetailPrivateLocked.
  ///
  /// In es_MX, this message translates to:
  /// **'Esta comunidad es privada. Únete para ver su contenido.'**
  String get communityDetailPrivateLocked;

  /// No description provided for @communityDetailRequestsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitudes pendientes'**
  String get communityDetailRequestsTitle;

  /// No description provided for @communityDetailRequestsEmpty.
  ///
  /// In es_MX, this message translates to:
  /// **'No hay solicitudes pendientes.'**
  String get communityDetailRequestsEmpty;

  /// No description provided for @communityDetailApprove.
  ///
  /// In es_MX, this message translates to:
  /// **'Aceptar'**
  String get communityDetailApprove;

  /// No description provided for @communityDetailReject.
  ///
  /// In es_MX, this message translates to:
  /// **'Rechazar'**
  String get communityDetailReject;

  /// No description provided for @communityDetailPromote.
  ///
  /// In es_MX, this message translates to:
  /// **'Hacer moderador'**
  String get communityDetailPromote;

  /// No description provided for @communityDetailDemote.
  ///
  /// In es_MX, this message translates to:
  /// **'Quitar moderador'**
  String get communityDetailDemote;

  /// No description provided for @communityDetailRemoveMember.
  ///
  /// In es_MX, this message translates to:
  /// **'Expulsar'**
  String get communityDetailRemoveMember;

  /// No description provided for @communityDetailDeleteButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Eliminar comunidad'**
  String get communityDetailDeleteButton;

  /// No description provided for @communityDetailDeleteConfirmTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Eliminar comunidad'**
  String get communityDetailDeleteConfirmTitle;

  /// No description provided for @communityDetailDeleteConfirmMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'Esta acción no se puede deshacer. Se eliminará la comunidad para todos los miembros.'**
  String get communityDetailDeleteConfirmMessage;

  /// No description provided for @communityJoinRequestSentSnackbar.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud enviada. Un administrador la revisará.'**
  String get communityJoinRequestSentSnackbar;

  /// No description provided for @createPostTypePost.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicación'**
  String get createPostTypePost;

  /// No description provided for @createPostTypeStory.
  ///
  /// In es_MX, this message translates to:
  /// **'Historia'**
  String get createPostTypeStory;

  /// No description provided for @createPostTypeReel.
  ///
  /// In es_MX, this message translates to:
  /// **'Reel'**
  String get createPostTypeReel;

  /// No description provided for @createPostTypeDrawing.
  ///
  /// In es_MX, this message translates to:
  /// **'Dibujo'**
  String get createPostTypeDrawing;

  /// No description provided for @createPostTypeArticle.
  ///
  /// In es_MX, this message translates to:
  /// **'Artículo'**
  String get createPostTypeArticle;

  /// No description provided for @createArticleBoldTooltip.
  ///
  /// In es_MX, this message translates to:
  /// **'Negrita'**
  String get createArticleBoldTooltip;

  /// No description provided for @createArticleItalicTooltip.
  ///
  /// In es_MX, this message translates to:
  /// **'Cursiva'**
  String get createArticleItalicTooltip;

  /// No description provided for @createArticleUnderlineTooltip.
  ///
  /// In es_MX, this message translates to:
  /// **'Subrayado'**
  String get createArticleUnderlineTooltip;

  /// No description provided for @createArticleBulletTooltip.
  ///
  /// In es_MX, this message translates to:
  /// **'Lista'**
  String get createArticleBulletTooltip;

  /// No description provided for @createArticleTitleTooltip.
  ///
  /// In es_MX, this message translates to:
  /// **'Encabezado'**
  String get createArticleTitleTooltip;

  /// No description provided for @createArticleTitleHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Título de tu historia'**
  String get createArticleTitleHint;

  /// No description provided for @createArticleBodyHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Había una vez...'**
  String get createArticleBodyHint;

  /// No description provided for @createArticleWordCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} palabras'**
  String createArticleWordCount(int count);

  /// No description provided for @imageEditorTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Editar imagen'**
  String get imageEditorTitle;

  /// No description provided for @imageEditorAspectOriginal.
  ///
  /// In es_MX, this message translates to:
  /// **'Original'**
  String get imageEditorAspectOriginal;

  /// No description provided for @imageEditorBrightness.
  ///
  /// In es_MX, this message translates to:
  /// **'Brillo'**
  String get imageEditorBrightness;

  /// No description provided for @imageEditorContrast.
  ///
  /// In es_MX, this message translates to:
  /// **'Contraste'**
  String get imageEditorContrast;

  /// No description provided for @imageEditorSaturation.
  ///
  /// In es_MX, this message translates to:
  /// **'Saturación'**
  String get imageEditorSaturation;

  /// No description provided for @mediaEditButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Editar'**
  String get mediaEditButton;

  /// No description provided for @mediaTrimButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Recortar'**
  String get mediaTrimButton;

  /// No description provided for @videoTrimTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Recortar video'**
  String get videoTrimTitle;

  /// No description provided for @audioTrimTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Recortar audio'**
  String get audioTrimTitle;

  /// No description provided for @trimStartLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Inicio: {time}'**
  String trimStartLabel(String time);

  /// No description provided for @trimEndLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Fin: {time}'**
  String trimEndLabel(String time);

  /// No description provided for @petStoreSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Mascota virtual'**
  String get petStoreSectionTitle;

  /// No description provided for @petStoreSectionSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Función de prueba: adopta una mascota y cuídala desde tu perfil'**
  String get petStoreSectionSubtitle;

  /// No description provided for @petAlreadyOwnedLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Ya tienes una mascota'**
  String get petAlreadyOwnedLabel;

  /// No description provided for @petNameDialogTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Ponle un nombre'**
  String get petNameDialogTitle;

  /// No description provided for @petNameDialogHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Nombre de tu mascota'**
  String get petNameDialogHint;

  /// No description provided for @petAdoptButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Adoptar'**
  String get petAdoptButton;

  /// No description provided for @petPurchaseSuccess.
  ///
  /// In es_MX, this message translates to:
  /// **'¡Adoptaste a tu mascota!'**
  String get petPurchaseSuccess;

  /// No description provided for @petProfileSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Mascota virtual'**
  String get petProfileSectionTitle;

  /// No description provided for @petLevelLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Nivel {level}'**
  String petLevelLabel(int level);

  /// No description provided for @petHungerLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Hambre'**
  String get petHungerLabel;

  /// No description provided for @petHappinessLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Felicidad'**
  String get petHappinessLabel;

  /// No description provided for @petFeedButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Alimentar'**
  String get petFeedButton;

  /// No description provided for @petPlayButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Jugar'**
  String get petPlayButton;

  /// No description provided for @petRemoveButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Eliminar mascota'**
  String get petRemoveButton;

  /// No description provided for @petRemoveConfirmTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Eliminar mascota'**
  String get petRemoveConfirmTitle;

  /// No description provided for @petRemoveConfirmMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'¿Seguro que quieres eliminar a tu mascota? No podrás recuperarla.'**
  String get petRemoveConfirmMessage;

  /// No description provided for @petCuddleButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Mimar'**
  String get petCuddleButton;

  /// No description provided for @petDetailScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu mascota'**
  String get petDetailScreenTitle;

  /// No description provided for @petTapHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Tócala para mimarla'**
  String get petTapHint;

  /// No description provided for @petMoodEcstatic.
  ///
  /// In es_MX, this message translates to:
  /// **'Eufórico'**
  String get petMoodEcstatic;

  /// No description provided for @petMoodHappy.
  ///
  /// In es_MX, this message translates to:
  /// **'Feliz'**
  String get petMoodHappy;

  /// No description provided for @petMoodNeutral.
  ///
  /// In es_MX, this message translates to:
  /// **'Tranquilo'**
  String get petMoodNeutral;

  /// No description provided for @petMoodSad.
  ///
  /// In es_MX, this message translates to:
  /// **'Triste'**
  String get petMoodSad;

  /// No description provided for @petMoodCritical.
  ///
  /// In es_MX, this message translates to:
  /// **'Necesita atención'**
  String get petMoodCritical;

  /// No description provided for @petStageBaby.
  ///
  /// In es_MX, this message translates to:
  /// **'Cría'**
  String get petStageBaby;

  /// No description provided for @petStageYoung.
  ///
  /// In es_MX, this message translates to:
  /// **'Joven'**
  String get petStageYoung;

  /// No description provided for @petStageAdult.
  ///
  /// In es_MX, this message translates to:
  /// **'Adulto'**
  String get petStageAdult;

  /// No description provided for @petXpToNextLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{xp} XP para el siguiente nivel'**
  String petXpToNextLabel(int xp);

  /// No description provided for @petLevelUpMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'¡{name} subió a nivel {level}!'**
  String petLevelUpMessage(String name, int level);

  /// No description provided for @createRoleArtist.
  ///
  /// In es_MX, this message translates to:
  /// **'🎨 Artista'**
  String get createRoleArtist;

  /// No description provided for @createRoleMusician.
  ///
  /// In es_MX, this message translates to:
  /// **'🎵 Músico'**
  String get createRoleMusician;

  /// No description provided for @createRoleProgrammer.
  ///
  /// In es_MX, this message translates to:
  /// **'💻 Programador'**
  String get createRoleProgrammer;

  /// No description provided for @createRoleWriter.
  ///
  /// In es_MX, this message translates to:
  /// **'📝 Escritor'**
  String get createRoleWriter;

  /// No description provided for @createRoleEditor.
  ///
  /// In es_MX, this message translates to:
  /// **'🎬 Editor'**
  String get createRoleEditor;

  /// No description provided for @createRoleScreenwriter.
  ///
  /// In es_MX, this message translates to:
  /// **'🧠 Guionista'**
  String get createRoleScreenwriter;

  /// No description provided for @createPublishSuccessMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicado con éxito'**
  String get createPublishSuccessMessage;

  /// No description provided for @createPublishSuccessWithCoins.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicado con éxito · +{coins} ZCoins'**
  String createPublishSuccessWithCoins(int coins);

  /// No description provided for @createScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear'**
  String get createScreenTitle;

  /// No description provided for @createPublishButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicar'**
  String get createPublishButton;

  /// No description provided for @createTabNewPost.
  ///
  /// In es_MX, this message translates to:
  /// **'Nueva publicación'**
  String get createTabNewPost;

  /// No description provided for @createTabProject.
  ///
  /// In es_MX, this message translates to:
  /// **'Proyecto'**
  String get createTabProject;

  /// No description provided for @createTabCollaboration.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboración'**
  String get createTabCollaboration;

  /// No description provided for @createActionImage.
  ///
  /// In es_MX, this message translates to:
  /// **'Imagen'**
  String get createActionImage;

  /// No description provided for @createActionVideo.
  ///
  /// In es_MX, this message translates to:
  /// **'Video'**
  String get createActionVideo;

  /// No description provided for @createActionFile.
  ///
  /// In es_MX, this message translates to:
  /// **'Archivo'**
  String get createActionFile;

  /// No description provided for @createActionCamera.
  ///
  /// In es_MX, this message translates to:
  /// **'Cámara'**
  String get createActionCamera;

  /// No description provided for @createActionTakePhoto.
  ///
  /// In es_MX, this message translates to:
  /// **'Tomar foto'**
  String get createActionTakePhoto;

  /// No description provided for @createActionRecordVideo.
  ///
  /// In es_MX, this message translates to:
  /// **'Grabar video'**
  String get createActionRecordVideo;

  /// No description provided for @createActionSelectReel.
  ///
  /// In es_MX, this message translates to:
  /// **'Seleccionar Reel'**
  String get createActionSelectReel;

  /// No description provided for @createActionOpenCanvas.
  ///
  /// In es_MX, this message translates to:
  /// **'Abrir lienzo'**
  String get createActionOpenCanvas;

  /// No description provided for @drawingCanvasTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Lienzo'**
  String get drawingCanvasTitle;

  /// No description provided for @drawingCanvasUndo.
  ///
  /// In es_MX, this message translates to:
  /// **'Deshacer'**
  String get drawingCanvasUndo;

  /// No description provided for @drawingCanvasClear.
  ///
  /// In es_MX, this message translates to:
  /// **'Borrar todo'**
  String get drawingCanvasClear;

  /// No description provided for @drawingCanvasSave.
  ///
  /// In es_MX, this message translates to:
  /// **'Listo'**
  String get drawingCanvasSave;

  /// No description provided for @createContentGuidelineText.
  ///
  /// In es_MX, this message translates to:
  /// **'Comparte contenido creativo y respetuoso.'**
  String get createContentGuidelineText;

  /// No description provided for @createPostHint.
  ///
  /// In es_MX, this message translates to:
  /// **'¿Qué quieres compartir?'**
  String get createPostHint;

  /// No description provided for @createSectionHashtags.
  ///
  /// In es_MX, this message translates to:
  /// **'Hashtags'**
  String get createSectionHashtags;

  /// No description provided for @createProjectTitleHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Título del proyecto'**
  String get createProjectTitleHint;

  /// No description provided for @createProjectDescriptionHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Describe tu proyecto...'**
  String get createProjectDescriptionHint;

  /// No description provided for @createSectionProgress.
  ///
  /// In es_MX, this message translates to:
  /// **'Progreso'**
  String get createSectionProgress;

  /// No description provided for @createProjectProgressPercent.
  ///
  /// In es_MX, this message translates to:
  /// **'{percent}% completado'**
  String createProjectProgressPercent(int percent);

  /// No description provided for @createSectionRolesNeeded.
  ///
  /// In es_MX, this message translates to:
  /// **'Roles necesarios'**
  String get createSectionRolesNeeded;

  /// No description provided for @createSectionProjectFiles.
  ///
  /// In es_MX, this message translates to:
  /// **'Archivos del proyecto'**
  String get createSectionProjectFiles;

  /// No description provided for @createCollabSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'¿Qué estás buscando?'**
  String get createCollabSearchHint;

  /// No description provided for @createCollabDescriptionHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Describe tu colaboración...'**
  String get createCollabDescriptionHint;

  /// No description provided for @createSectionSkills.
  ///
  /// In es_MX, this message translates to:
  /// **'Habilidades'**
  String get createSectionSkills;

  /// No description provided for @createPublicCollabTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboración pública'**
  String get createPublicCollabTitle;

  /// No description provided for @createPublicCollabSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Cualquier usuario puede aplicar.'**
  String get createPublicCollabSubtitle;

  /// No description provided for @createFileSizeKb.
  ///
  /// In es_MX, this message translates to:
  /// **'{size} KB'**
  String createFileSizeKb(String size);

  /// No description provided for @createUploadFilesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Subir archivos'**
  String get createUploadFilesTitle;

  /// No description provided for @createUploadFilesSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'PDF, Word, ZIP, imágenes, videos y código.'**
  String get createUploadFilesSubtitle;

  /// No description provided for @eventsFilterAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Todos'**
  String get eventsFilterAll;

  /// No description provided for @eventsFilterToday.
  ///
  /// In es_MX, this message translates to:
  /// **'Hoy'**
  String get eventsFilterToday;

  /// No description provided for @eventsFilterWeek.
  ///
  /// In es_MX, this message translates to:
  /// **'Semana'**
  String get eventsFilterWeek;

  /// No description provided for @eventsFilterMonth.
  ///
  /// In es_MX, this message translates to:
  /// **'Mes'**
  String get eventsFilterMonth;

  /// No description provided for @eventsFilterOnline.
  ///
  /// In es_MX, this message translates to:
  /// **'Online'**
  String get eventsFilterOnline;

  /// No description provided for @eventsFilterInPerson.
  ///
  /// In es_MX, this message translates to:
  /// **'Presencial'**
  String get eventsFilterInPerson;

  /// No description provided for @eventsScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Eventos'**
  String get eventsScreenTitle;

  /// No description provided for @eventsHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Descubre eventos'**
  String get eventsHeading;

  /// No description provided for @eventsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Participa en concursos, hackathones y eventos para creadores.'**
  String get eventsSubtitle;

  /// No description provided for @eventsStatEventsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Eventos'**
  String get eventsStatEventsLabel;

  /// No description provided for @eventsStatFeaturedLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Destacados'**
  String get eventsStatFeaturedLabel;

  /// No description provided for @eventsRegisteredLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Registrado'**
  String get eventsRegisteredLabel;

  /// No description provided for @eventsStatAttendeesLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Asistentes'**
  String get eventsStatAttendeesLabel;

  /// No description provided for @eventsSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar eventos...'**
  String get eventsSearchHint;

  /// No description provided for @eventsFeaturedSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'⭐ Eventos destacados'**
  String get eventsFeaturedSectionTitle;

  /// No description provided for @eventsSeeAllButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver todos'**
  String get eventsSeeAllButton;

  /// No description provided for @eventsFeaturedBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'DESTACADO'**
  String get eventsFeaturedBadge;

  /// No description provided for @eventsJoinButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Participar'**
  String get eventsJoinButton;

  /// No description provided for @eventsEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No se encontraron eventos'**
  String get eventsEmptyTitle;

  /// No description provided for @eventsEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Intenta con otra búsqueda o cambia el filtro seleccionado.'**
  String get eventsEmptySubtitle;

  /// No description provided for @eventsEmptySnackbarMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'Explorando nuevos eventos...'**
  String get eventsEmptySnackbarMessage;

  /// No description provided for @eventsEmptyActionButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Explorar eventos'**
  String get eventsEmptyActionButton;

  /// No description provided for @exploreCategoryVisualArt.
  ///
  /// In es_MX, this message translates to:
  /// **'Arte Visual'**
  String get exploreCategoryVisualArt;

  /// No description provided for @exploreCategoryMusic.
  ///
  /// In es_MX, this message translates to:
  /// **'Música'**
  String get exploreCategoryMusic;

  /// No description provided for @exploreCategoryLiterature.
  ///
  /// In es_MX, this message translates to:
  /// **'Literatura'**
  String get exploreCategoryLiterature;

  /// No description provided for @exploreCategoryVideogames.
  ///
  /// In es_MX, this message translates to:
  /// **'Videojuegos'**
  String get exploreCategoryVideogames;

  /// No description provided for @exploreCategoryPhotography.
  ///
  /// In es_MX, this message translates to:
  /// **'Fotografía'**
  String get exploreCategoryPhotography;

  /// No description provided for @exploreCategoryDesign.
  ///
  /// In es_MX, this message translates to:
  /// **'Diseño'**
  String get exploreCategoryDesign;

  /// No description provided for @categoryDetailFilterAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Todos'**
  String get categoryDetailFilterAll;

  /// No description provided for @categoryDetailFilterPopular.
  ///
  /// In es_MX, this message translates to:
  /// **'Populares'**
  String get categoryDetailFilterPopular;

  /// No description provided for @categoryDetailFilterNew.
  ///
  /// In es_MX, this message translates to:
  /// **'Nuevos'**
  String get categoryDetailFilterNew;

  /// No description provided for @categoryDetailFilterTrending.
  ///
  /// In es_MX, this message translates to:
  /// **'Tendencias'**
  String get categoryDetailFilterTrending;

  /// No description provided for @categoryDetailFilterFollowing.
  ///
  /// In es_MX, this message translates to:
  /// **'Siguiendo'**
  String get categoryDetailFilterFollowing;

  /// No description provided for @friendsScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Amigos'**
  String get friendsScreenTitle;

  /// No description provided for @friendsHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Conecta con tu comunidad'**
  String get friendsHeading;

  /// No description provided for @friendsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Encuentra amigos, colaboradores y creadores.'**
  String get friendsSubtitle;

  /// No description provided for @friendsTabRequests.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitudes'**
  String get friendsTabRequests;

  /// No description provided for @friendsStatFavoritesLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Favoritos'**
  String get friendsStatFavoritesLabel;

  /// No description provided for @friendsStatVerifiedLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Verificados'**
  String get friendsStatVerifiedLabel;

  /// No description provided for @friendsSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar amigos...'**
  String get friendsSearchHint;

  /// No description provided for @friendsEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No se encontraron amigos'**
  String get friendsEmptyTitle;

  /// No description provided for @friendsEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Prueba con otro nombre o envía nuevas solicitudes de amistad.'**
  String get friendsEmptySubtitle;

  /// No description provided for @friendsEmptySnackbarMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar nuevos amigos'**
  String get friendsEmptySnackbarMessage;

  /// No description provided for @friendsEmptyActionButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar amigos'**
  String get friendsEmptyActionButton;

  /// No description provided for @homePageNavFeedLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Inicio'**
  String get homePageNavFeedLabel;

  /// No description provided for @homePageNavChatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Chat'**
  String get homePageNavChatLabel;

  /// No description provided for @homePageNavProfileLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Perfil'**
  String get homePageNavProfileLabel;

  /// No description provided for @likesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Likes'**
  String get likesTitle;

  /// No description provided for @likesHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Contenido que te gustó'**
  String get likesHeading;

  /// No description provided for @likesSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Todas las publicaciones que marcaste con ❤️'**
  String get likesSubtitle;

  /// No description provided for @likesFilterAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Todos'**
  String get likesFilterAll;

  /// No description provided for @likesFilterPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Posts'**
  String get likesFilterPosts;

  /// No description provided for @likesFilterReels.
  ///
  /// In es_MX, this message translates to:
  /// **'Reels'**
  String get likesFilterReels;

  /// No description provided for @likesFilterStories.
  ///
  /// In es_MX, this message translates to:
  /// **'Historias'**
  String get likesFilterStories;

  /// No description provided for @likesFilterProjects.
  ///
  /// In es_MX, this message translates to:
  /// **'Proyectos'**
  String get likesFilterProjects;

  /// No description provided for @likesSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar publicaciones...'**
  String get likesSearchHint;

  /// No description provided for @likesRemovedSnackbar.
  ///
  /// In es_MX, this message translates to:
  /// **'{title} eliminado de Likes'**
  String likesRemovedSnackbar(String title);

  /// No description provided for @likesRemoveFromSaved.
  ///
  /// In es_MX, this message translates to:
  /// **'Quitar de Guardados'**
  String get likesRemoveFromSaved;

  /// No description provided for @likesRemoveLike.
  ///
  /// In es_MX, this message translates to:
  /// **'Quitar Like'**
  String get likesRemoveLike;

  /// No description provided for @likesEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no tienes Likes'**
  String get likesEmptyTitle;

  /// No description provided for @likesEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Las publicaciones que marques con ❤️ aparecerán aquí.'**
  String get likesEmptySubtitle;

  /// No description provided for @creatorDetailFollowersLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguidores'**
  String get creatorDetailFollowersLabel;

  /// No description provided for @creatorDetailLikesLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Likes'**
  String get creatorDetailLikesLabel;

  /// No description provided for @creatorDetailPostsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Posts'**
  String get creatorDetailPostsLabel;

  /// No description provided for @creatorDetailTabPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get creatorDetailTabPosts;

  /// No description provided for @creatorDetailTabPortfolio.
  ///
  /// In es_MX, this message translates to:
  /// **'Portafolio'**
  String get creatorDetailTabPortfolio;

  /// No description provided for @creatorDetailTabCollaborations.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboraciones'**
  String get creatorDetailTabCollaborations;

  /// No description provided for @creatorDetailInProgressBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'En progreso'**
  String get creatorDetailInProgressBadge;

  /// No description provided for @profilePostsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get profilePostsLabel;

  /// No description provided for @profileFollowersLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguidores'**
  String get profileFollowersLabel;

  /// No description provided for @profileFollowingLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Siguiendo'**
  String get profileFollowingLabel;

  /// No description provided for @profileEditButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Editar perfil'**
  String get profileEditButton;

  /// No description provided for @publicProfileFollowButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguir'**
  String get publicProfileFollowButton;

  /// No description provided for @publicProfileFollowingButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Siguiendo'**
  String get publicProfileFollowingButton;

  /// No description provided for @publicProfileMessageButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Mensaje'**
  String get publicProfileMessageButton;

  /// No description provided for @publicProfileNoPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no ha publicado nada.'**
  String get publicProfileNoPosts;

  /// No description provided for @profileTabPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get profileTabPosts;

  /// No description provided for @profileTabProjects.
  ///
  /// In es_MX, this message translates to:
  /// **'Proyectos'**
  String get profileTabProjects;

  /// No description provided for @profileTabPortfolio.
  ///
  /// In es_MX, this message translates to:
  /// **'Portafolio'**
  String get profileTabPortfolio;

  /// No description provided for @profileTabCommunities.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades'**
  String get profileTabCommunities;

  /// No description provided for @profileTabAchievements.
  ///
  /// In es_MX, this message translates to:
  /// **'Logros'**
  String get profileTabAchievements;

  /// No description provided for @profileHighlightsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Destacada'**
  String get profileHighlightsLabel;

  /// No description provided for @personalizeProfileScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Personalizar perfil'**
  String get personalizeProfileScreenTitle;

  /// No description provided for @personalizeFrameTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Marco del avatar'**
  String get personalizeFrameTitle;

  /// No description provided for @personalizeBadgesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Logros destacados ({count}/{max})'**
  String personalizeBadgesTitle(int count, int max);

  /// No description provided for @personalizeBadgesSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Elige hasta 3 logros para mostrar en tu perfil'**
  String get personalizeBadgesSubtitle;

  /// No description provided for @personalizeBadgesEmpty.
  ///
  /// In es_MX, this message translates to:
  /// **'Todavía no desbloqueas logros. Consíguelos dando like, comentando o publicando.'**
  String get personalizeBadgesEmpty;

  /// No description provided for @profileMenuPersonalizeItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Personalizar perfil'**
  String get profileMenuPersonalizeItem;

  /// No description provided for @profileNoPostsYet.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no has publicado nada.'**
  String get profileNoPostsYet;

  /// No description provided for @profileNoProjectsYet.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no has creado proyectos.'**
  String get profileNoProjectsYet;

  /// No description provided for @profileNoCommunitiesYet.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no perteneces a ninguna comunidad.'**
  String get profileNoCommunitiesYet;

  /// No description provided for @profileNoAchievementsYet.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no desbloqueas logros.'**
  String get profileNoAchievementsYet;

  /// No description provided for @portfolioEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu portafolio está vacío'**
  String get portfolioEmptyTitle;

  /// No description provided for @portfolioEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Agrega tus mejores trabajos para mostrarlos aquí.'**
  String get portfolioEmptySubtitle;

  /// No description provided for @portfolioAddButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Agregar al portafolio'**
  String get portfolioAddButton;

  /// No description provided for @portfolioAddTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Agregar al portafolio'**
  String get portfolioAddTitle;

  /// No description provided for @portfolioTitleHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Título del trabajo'**
  String get portfolioTitleHint;

  /// No description provided for @portfolioTitleRequired.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa un título'**
  String get portfolioTitleRequired;

  /// No description provided for @portfolioDescriptionHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Descripción'**
  String get portfolioDescriptionHint;

  /// No description provided for @portfolioToolsHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Herramientas/tecnologías (separadas por comas)'**
  String get portfolioToolsHint;

  /// No description provided for @portfolioLinkHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Enlace externo (opcional)'**
  String get portfolioLinkHint;

  /// No description provided for @portfolioStatusConcept.
  ///
  /// In es_MX, this message translates to:
  /// **'Concepto'**
  String get portfolioStatusConcept;

  /// No description provided for @portfolioStatusInProgress.
  ///
  /// In es_MX, this message translates to:
  /// **'En progreso'**
  String get portfolioStatusInProgress;

  /// No description provided for @portfolioStatusCompleted.
  ///
  /// In es_MX, this message translates to:
  /// **'Terminado'**
  String get portfolioStatusCompleted;

  /// No description provided for @portfolioOpenLinkButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Abrir enlace'**
  String get portfolioOpenLinkButton;

  /// No description provided for @collabWantToCollabButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Quiero colaborar'**
  String get collabWantToCollabButton;

  /// No description provided for @collabRequestSentLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud enviada'**
  String get collabRequestSentLabel;

  /// No description provided for @collabRequestSentSnackbar.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu solicitud fue enviada'**
  String get collabRequestSentSnackbar;

  /// No description provided for @collabReviewRequests.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver solicitudes'**
  String get collabReviewRequests;

  /// No description provided for @collabReviewRequestsWithCount.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver solicitudes ({count})'**
  String collabReviewRequestsWithCount(int count);

  /// No description provided for @collabRequestsScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitudes de colaboración'**
  String get collabRequestsScreenTitle;

  /// No description provided for @collabRequestsEmpty.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no hay solicitudes para esta publicación.'**
  String get collabRequestsEmpty;

  /// No description provided for @collabStatusPending.
  ///
  /// In es_MX, this message translates to:
  /// **'Pendiente'**
  String get collabStatusPending;

  /// No description provided for @collabStatusAccepted.
  ///
  /// In es_MX, this message translates to:
  /// **'Aceptada'**
  String get collabStatusAccepted;

  /// No description provided for @collabStatusRejected.
  ///
  /// In es_MX, this message translates to:
  /// **'Rechazada'**
  String get collabStatusRejected;

  /// No description provided for @collabStatusCompleted.
  ///
  /// In es_MX, this message translates to:
  /// **'Finalizada'**
  String get collabStatusCompleted;

  /// No description provided for @collabAccept.
  ///
  /// In es_MX, this message translates to:
  /// **'Aceptar'**
  String get collabAccept;

  /// No description provided for @collabReject.
  ///
  /// In es_MX, this message translates to:
  /// **'Rechazar'**
  String get collabReject;

  /// No description provided for @collabMarkCompleted.
  ///
  /// In es_MX, this message translates to:
  /// **'Marcar como finalizada'**
  String get collabMarkCompleted;

  /// No description provided for @challengesTabOfficial.
  ///
  /// In es_MX, this message translates to:
  /// **'Oficiales'**
  String get challengesTabOfficial;

  /// No description provided for @challengesTabCreative.
  ///
  /// In es_MX, this message translates to:
  /// **'Creativos'**
  String get challengesTabCreative;

  /// No description provided for @challengesCreativeEmpty.
  ///
  /// In es_MX, this message translates to:
  /// **'No hay retos creativos activos por ahora.'**
  String get challengesCreativeEmpty;

  /// No description provided for @challengeCreateTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear reto'**
  String get challengeCreateTitle;

  /// No description provided for @challengeCreateButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear reto'**
  String get challengeCreateButton;

  /// No description provided for @challengeTitleHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Título del reto'**
  String get challengeTitleHint;

  /// No description provided for @challengeTitleRequired.
  ///
  /// In es_MX, this message translates to:
  /// **'Ingresa un título'**
  String get challengeTitleRequired;

  /// No description provided for @challengeDescriptionHint.
  ///
  /// In es_MX, this message translates to:
  /// **'¿En qué consiste el reto?'**
  String get challengeDescriptionHint;

  /// No description provided for @challengePersonalOption.
  ///
  /// In es_MX, this message translates to:
  /// **'Reto personal'**
  String get challengePersonalOption;

  /// No description provided for @challengeStartDateLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Inicio'**
  String get challengeStartDateLabel;

  /// No description provided for @challengeEndDateLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Fin'**
  String get challengeEndDateLabel;

  /// No description provided for @challengeRulesHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Reglas (opcional)'**
  String get challengeRulesHint;

  /// No description provided for @challengeParticipantsCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} participantes'**
  String challengeParticipantsCount(int count);

  /// No description provided for @challengeDatesRange.
  ///
  /// In es_MX, this message translates to:
  /// **'Del {start} al {end}'**
  String challengeDatesRange(String start, String end);

  /// No description provided for @challengeParticipateButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Participar'**
  String get challengeParticipateButton;

  /// No description provided for @challengeSubmitEntryButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicar mi participación'**
  String get challengeSubmitEntryButton;

  /// No description provided for @challengeEntriesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Participaciones'**
  String get challengeEntriesTitle;

  /// No description provided for @challengeEntriesEmpty.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no hay participaciones en este reto.'**
  String get challengeEntriesEmpty;

  /// No description provided for @forYouScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Para ti'**
  String get forYouScreenTitle;

  /// No description provided for @forYouCreatorsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Creadores que podrían interesarte'**
  String get forYouCreatorsTitle;

  /// No description provided for @forYouCommunitiesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades que podrían interesarte'**
  String get forYouCommunitiesTitle;

  /// No description provided for @forYouChallengesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Retos para ti'**
  String get forYouChallengesTitle;

  /// No description provided for @forYouContentTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Contenido recomendado'**
  String get forYouContentTitle;

  /// No description provided for @forYouEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Todavía no tenemos recomendaciones para ti'**
  String get forYouEmptyTitle;

  /// No description provided for @forYouEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Sigue a otros creadores, únete a comunidades y da like a publicaciones para que Para ti empiece a personalizarse.'**
  String get forYouEmptySubtitle;

  /// No description provided for @profileMenuHeaderTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Perfil'**
  String get profileMenuHeaderTitle;

  /// No description provided for @profileMenuLogout.
  ///
  /// In es_MX, this message translates to:
  /// **'Cerrar sesión'**
  String get profileMenuLogout;

  /// No description provided for @profileMenuLogoutConfirmMessage.
  ///
  /// In es_MX, this message translates to:
  /// **'¿Estás seguro de que deseas cerrar sesión?'**
  String get profileMenuLogoutConfirmMessage;

  /// No description provided for @profileMenuLogoutConfirmAction.
  ///
  /// In es_MX, this message translates to:
  /// **'Salir'**
  String get profileMenuLogoutConfirmAction;

  /// No description provided for @profileMenuSectionAccount.
  ///
  /// In es_MX, this message translates to:
  /// **'👤 Cuenta'**
  String get profileMenuSectionAccount;

  /// No description provided for @profileMenuSectionActivity.
  ///
  /// In es_MX, this message translates to:
  /// **'❤️ Actividad'**
  String get profileMenuSectionActivity;

  /// No description provided for @profileMenuSectionSocial.
  ///
  /// In es_MX, this message translates to:
  /// **'👥 Social'**
  String get profileMenuSectionSocial;

  /// No description provided for @profileMenuSectionZentry.
  ///
  /// In es_MX, this message translates to:
  /// **'💎 Zentry'**
  String get profileMenuSectionZentry;

  /// No description provided for @profileMenuSectionSettings.
  ///
  /// In es_MX, this message translates to:
  /// **'⚙ Configuración'**
  String get profileMenuSectionSettings;

  /// No description provided for @profileMenuSectionHelp.
  ///
  /// In es_MX, this message translates to:
  /// **'❓ Ayuda'**
  String get profileMenuSectionHelp;

  /// No description provided for @profileMenuEditProfileItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Editar perfil'**
  String get profileMenuEditProfileItem;

  /// No description provided for @profileMenuChangePhotoItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Cambiar foto'**
  String get profileMenuChangePhotoItem;

  /// No description provided for @profileMenuViewPublicProfileItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Ver perfil público'**
  String get profileMenuViewPublicProfileItem;

  /// No description provided for @profileMenuQrCodeItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Código QR'**
  String get profileMenuQrCodeItem;

  /// No description provided for @profileMenuLikesItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Likes'**
  String get profileMenuLikesItem;

  /// No description provided for @profileMenuSavedItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Guardados'**
  String get profileMenuSavedItem;

  /// No description provided for @profileMenuHistoryItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Historial'**
  String get profileMenuHistoryItem;

  /// No description provided for @profileMenuFriendsItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Amigos'**
  String get profileMenuFriendsItem;

  /// No description provided for @profileMenuSubscriptionItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Mi suscripción'**
  String get profileMenuSubscriptionItem;

  /// No description provided for @profileMenuBadgesItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Insignias'**
  String get profileMenuBadgesItem;

  /// No description provided for @profileMenuStatsItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Estadísticas'**
  String get profileMenuStatsItem;

  /// No description provided for @profileMenuPortfolioItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Portafolio'**
  String get profileMenuPortfolioItem;

  /// No description provided for @profileMenuThemeItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Tema'**
  String get profileMenuThemeItem;

  /// No description provided for @profileMenuLanguageItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Idioma'**
  String get profileMenuLanguageItem;

  /// No description provided for @profileMenuNotificationsItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Notificaciones'**
  String get profileMenuNotificationsItem;

  /// No description provided for @profileMenuPrivacyItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Privacidad'**
  String get profileMenuPrivacyItem;

  /// No description provided for @profileMenuSecurityItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguridad'**
  String get profileMenuSecurityItem;

  /// No description provided for @profileMenuHelpCenterItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Centro de ayuda'**
  String get profileMenuHelpCenterItem;

  /// No description provided for @profileMenuReportProblemItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Reportar un problema'**
  String get profileMenuReportProblemItem;

  /// No description provided for @profileMenuAboutItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Acerca de Zentry'**
  String get profileMenuAboutItem;

  /// No description provided for @savedScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Guardados'**
  String get savedScreenTitle;

  /// No description provided for @savedPostsSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones guardadas'**
  String get savedPostsSectionTitle;

  /// No description provided for @savedPostsEmptyHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no has guardado publicaciones. Toca el ícono de guardar en una publicación para verla aquí.'**
  String get savedPostsEmptyHint;

  /// No description provided for @savedCollectionsHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Tus colecciones'**
  String get savedCollectionsHeading;

  /// No description provided for @savedCollectionsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Organiza tus publicaciones favoritas en colecciones.'**
  String get savedCollectionsSubtitle;

  /// No description provided for @savedCollectionsStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Colecciones'**
  String get savedCollectionsStatLabel;

  /// No description provided for @savedFavoritesStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Favoritos'**
  String get savedFavoritesStatLabel;

  /// No description provided for @savedStorageStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Espacio'**
  String get savedStorageStatLabel;

  /// No description provided for @savedSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar colección...'**
  String get savedSearchHint;

  /// No description provided for @savedNewCollectionLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Nueva colección'**
  String get savedNewCollectionLabel;

  /// No description provided for @savedCollectionNameHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Nombre'**
  String get savedCollectionNameHint;

  /// No description provided for @savedCreateButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Crear'**
  String get savedCreateButton;

  /// No description provided for @savedRenameOption.
  ///
  /// In es_MX, this message translates to:
  /// **'Renombrar'**
  String get savedRenameOption;

  /// No description provided for @savedPostsCountLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} publicaciones'**
  String savedPostsCountLabel(int count);

  /// No description provided for @savedOpenButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Abrir'**
  String get savedOpenButton;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No hay colecciones'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Crea tu primera colección para organizar tus publicaciones.'**
  String get savedEmptySubtitle;

  /// No description provided for @achievementsScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Logros'**
  String get achievementsScreenTitle;

  /// No description provided for @achievementsUnlockedStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Desbloqueados'**
  String get achievementsUnlockedStat;

  /// No description provided for @achievementsProgressStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Progreso'**
  String get achievementsProgressStat;

  /// No description provided for @achievementsPointsStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Puntos'**
  String get achievementsPointsStat;

  /// No description provided for @achievementsRankStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Rango'**
  String get achievementsRankStat;

  /// No description provided for @achievementsGeneralProgressTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Progreso general'**
  String get achievementsGeneralProgressTitle;

  /// No description provided for @achievementsLike1Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Primer me gusta'**
  String get achievementsLike1Title;

  /// No description provided for @achievementsLike1Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Dale me gusta a una publicación'**
  String get achievementsLike1Desc;

  /// No description provided for @achievementsLike5Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Corazón generoso'**
  String get achievementsLike5Title;

  /// No description provided for @achievementsLike5Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Da 5 me gusta a publicaciones'**
  String get achievementsLike5Desc;

  /// No description provided for @achievementsLike25Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Fan número uno'**
  String get achievementsLike25Title;

  /// No description provided for @achievementsLike25Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Da 25 me gusta a publicaciones'**
  String get achievementsLike25Desc;

  /// No description provided for @achievementsLike100Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Coleccionista de likes'**
  String get achievementsLike100Title;

  /// No description provided for @achievementsLike100Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Da 100 me gusta a publicaciones'**
  String get achievementsLike100Desc;

  /// No description provided for @achievementsStreak3Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Racha inicial'**
  String get achievementsStreak3Title;

  /// No description provided for @achievementsStreak3Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Entra 3 días seguidos'**
  String get achievementsStreak3Desc;

  /// No description provided for @achievementsStreak7Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Semana completa'**
  String get achievementsStreak7Title;

  /// No description provided for @achievementsStreak7Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Entra 7 días seguidos'**
  String get achievementsStreak7Desc;

  /// No description provided for @achievementsStreak30Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Fiel a Zentry'**
  String get achievementsStreak30Title;

  /// No description provided for @achievementsStreak30Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Entra 30 días seguidos'**
  String get achievementsStreak30Desc;

  /// No description provided for @achievementsPosts1Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Primer trazo'**
  String get achievementsPosts1Title;

  /// No description provided for @achievementsPosts1Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Publica tu primer contenido'**
  String get achievementsPosts1Desc;

  /// No description provided for @achievementsPosts10Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Creador constante'**
  String get achievementsPosts10Title;

  /// No description provided for @achievementsPosts10Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Publica 10 veces'**
  String get achievementsPosts10Desc;

  /// No description provided for @achievementsPosts50Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Máquina creativa'**
  String get achievementsPosts50Title;

  /// No description provided for @achievementsPosts50Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Publica 50 veces'**
  String get achievementsPosts50Desc;

  /// No description provided for @achievementsComments10Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Conversador'**
  String get achievementsComments10Title;

  /// No description provided for @achievementsComments10Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Comenta 10 veces'**
  String get achievementsComments10Desc;

  /// No description provided for @achievementsComments50Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Voz de la comunidad'**
  String get achievementsComments50Title;

  /// No description provided for @achievementsComments50Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Comenta 50 veces'**
  String get achievementsComments50Desc;

  /// No description provided for @achievementsSaves10Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Curador'**
  String get achievementsSaves10Title;

  /// No description provided for @achievementsSaves10Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Guarda 10 publicaciones'**
  String get achievementsSaves10Desc;

  /// No description provided for @achievementsShares10Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Difusor'**
  String get achievementsShares10Title;

  /// No description provided for @achievementsShares10Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Comparte 10 publicaciones'**
  String get achievementsShares10Desc;

  /// No description provided for @achievementsRarityCommon.
  ///
  /// In es_MX, this message translates to:
  /// **'Común'**
  String get achievementsRarityCommon;

  /// No description provided for @achievementsRarityRare.
  ///
  /// In es_MX, this message translates to:
  /// **'Rara'**
  String get achievementsRarityRare;

  /// No description provided for @achievementsRarityEpic.
  ///
  /// In es_MX, this message translates to:
  /// **'Épica'**
  String get achievementsRarityEpic;

  /// No description provided for @achievementsRarityLegendary.
  ///
  /// In es_MX, this message translates to:
  /// **'Legendaria'**
  String get achievementsRarityLegendary;

  /// No description provided for @achievementsUnlockedBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'Desbloqueado ✔'**
  String get achievementsUnlockedBadge;

  /// No description provided for @achievementsFilterAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Todas'**
  String get achievementsFilterAll;

  /// No description provided for @achievementsFilterUnlocked.
  ///
  /// In es_MX, this message translates to:
  /// **'Desbloqueadas'**
  String get achievementsFilterUnlocked;

  /// No description provided for @achievementsFilterLocked.
  ///
  /// In es_MX, this message translates to:
  /// **'Bloqueadas'**
  String get achievementsFilterLocked;

  /// No description provided for @achievementsEmptyFilterLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'No hay logros en este filtro todavía'**
  String get achievementsEmptyFilterLabel;

  /// No description provided for @achievementsCategoryLikes.
  ///
  /// In es_MX, this message translates to:
  /// **'Me gusta'**
  String get achievementsCategoryLikes;

  /// No description provided for @achievementsCategoryStreak.
  ///
  /// In es_MX, this message translates to:
  /// **'Racha'**
  String get achievementsCategoryStreak;

  /// No description provided for @achievementsCategoryPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get achievementsCategoryPosts;

  /// No description provided for @achievementsCategoryComments.
  ///
  /// In es_MX, this message translates to:
  /// **'Comentarios'**
  String get achievementsCategoryComments;

  /// No description provided for @achievementsCategorySaves.
  ///
  /// In es_MX, this message translates to:
  /// **'Guardados'**
  String get achievementsCategorySaves;

  /// No description provided for @achievementsCategoryShares.
  ///
  /// In es_MX, this message translates to:
  /// **'Compartidos'**
  String get achievementsCategoryShares;

  /// No description provided for @achievementsRankBronze.
  ///
  /// In es_MX, this message translates to:
  /// **'Bronce'**
  String get achievementsRankBronze;

  /// No description provided for @achievementsRankSilver.
  ///
  /// In es_MX, this message translates to:
  /// **'Plata'**
  String get achievementsRankSilver;

  /// No description provided for @achievementsRankGold.
  ///
  /// In es_MX, this message translates to:
  /// **'Oro'**
  String get achievementsRankGold;

  /// No description provided for @achievementsRankPlatinum.
  ///
  /// In es_MX, this message translates to:
  /// **'Platino'**
  String get achievementsRankPlatinum;

  /// No description provided for @achievementsRankDiamond.
  ///
  /// In es_MX, this message translates to:
  /// **'Diamante'**
  String get achievementsRankDiamond;

  /// No description provided for @achievementsRankMaster.
  ///
  /// In es_MX, this message translates to:
  /// **'Maestro'**
  String get achievementsRankMaster;

  /// No description provided for @achievementsStreakSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Racha de actividad'**
  String get achievementsStreakSectionTitle;

  /// No description provided for @achievementsStreakSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Entra todos los días para mantenerla'**
  String get achievementsStreakSubtitle;

  /// No description provided for @achievementsStreakDaysLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} días seguidos'**
  String achievementsStreakDaysLabel(int count);

  /// No description provided for @achievementsStreakBestLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Récord: {count} días'**
  String achievementsStreakBestLabel(int count);

  /// No description provided for @achievementsStreakRewardLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'+{points} pts hoy'**
  String achievementsStreakRewardLabel(int points);

  /// No description provided for @achievementsStreakPointsTotalLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{points} pts de racha acumulados'**
  String achievementsStreakPointsTotalLabel(int points);

  /// No description provided for @homeStreakChipLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} días'**
  String homeStreakChipLabel(int count);

  /// No description provided for @qrScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu código QR'**
  String get qrScreenTitle;

  /// No description provided for @qrScreenSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Compártelo para que te encuentren en Zentry'**
  String get qrScreenSubtitle;

  /// No description provided for @profileStatsScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Estadísticas'**
  String get profileStatsScreenTitle;

  /// No description provided for @profileStatsWeeklyLikes.
  ///
  /// In es_MX, this message translates to:
  /// **'Me gusta dados esta semana'**
  String get profileStatsWeeklyLikes;

  /// No description provided for @profileStatsWeeklySaves.
  ///
  /// In es_MX, this message translates to:
  /// **'Guardados esta semana'**
  String get profileStatsWeeklySaves;

  /// No description provided for @profileStatsWeeklyShares.
  ///
  /// In es_MX, this message translates to:
  /// **'Compartidos esta semana'**
  String get profileStatsWeeklyShares;

  /// No description provided for @profileStatsWeeklyVisits.
  ///
  /// In es_MX, this message translates to:
  /// **'Visitas a tu perfil'**
  String get profileStatsWeeklyVisits;

  /// No description provided for @profileStatsTotalLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} esta semana'**
  String profileStatsTotalLabel(int count);

  /// No description provided for @profileStatsContentTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Rendimiento de tu contenido'**
  String get profileStatsContentTitle;

  /// No description provided for @profileStatsTotalPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get profileStatsTotalPosts;

  /// No description provided for @profileStatsTotalReactions.
  ///
  /// In es_MX, this message translates to:
  /// **'Reacciones recibidas'**
  String get profileStatsTotalReactions;

  /// No description provided for @profileStatsTotalComments.
  ///
  /// In es_MX, this message translates to:
  /// **'Comentarios recibidos'**
  String get profileStatsTotalComments;

  /// No description provided for @profileStatsTotalFollowers.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguidores'**
  String get profileStatsTotalFollowers;

  /// No description provided for @profileStatsTopContentTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Contenido con mejor rendimiento'**
  String get profileStatsTopContentTitle;

  /// No description provided for @profileStatsNoPostsYet.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no tienes publicaciones. Cuando publiques algo, verás aquí su rendimiento.'**
  String get profileStatsNoPostsYet;

  /// No description provided for @profileStatsViewsUnavailable.
  ///
  /// In es_MX, this message translates to:
  /// **'Las vistas por publicación aún no están disponibles'**
  String get profileStatsViewsUnavailable;

  /// No description provided for @homeCommentHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Escribe un comentario...'**
  String get homeCommentHint;

  /// No description provided for @streakScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Racha'**
  String get streakScreenTitle;

  /// No description provided for @streakScreenActiveToday.
  ///
  /// In es_MX, this message translates to:
  /// **'Racha encendida hoy'**
  String get streakScreenActiveToday;

  /// No description provided for @streakScreenInactiveToday.
  ///
  /// In es_MX, this message translates to:
  /// **'Da like, comenta o publica para encenderla hoy'**
  String get streakScreenInactiveToday;

  /// No description provided for @streakScreenWeekTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Actividad de la semana'**
  String get streakScreenWeekTitle;

  /// No description provided for @streakScreenExplainer.
  ///
  /// In es_MX, this message translates to:
  /// **'La racha se enciende la primera vez en el día que das like, comentas o publicas algo. Si un día pasa sin actividad, la racha se reinicia.'**
  String get streakScreenExplainer;

  /// No description provided for @challengesScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Retos'**
  String get challengesScreenTitle;

  /// No description provided for @challengesScreenSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Cumple retos semanales y gana ZCoins para la Tienda.'**
  String get challengesScreenSubtitle;

  /// No description provided for @challengeLikes15Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Repartidor de cariño'**
  String get challengeLikes15Title;

  /// No description provided for @challengeLikes15Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Da 15 me gusta esta semana'**
  String get challengeLikes15Desc;

  /// No description provided for @challengePosts3Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Creador activo'**
  String get challengePosts3Title;

  /// No description provided for @challengePosts3Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Publica 3 veces esta semana'**
  String get challengePosts3Desc;

  /// No description provided for @challengeComments5Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Conversador'**
  String get challengeComments5Title;

  /// No description provided for @challengeComments5Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Comenta 5 veces esta semana'**
  String get challengeComments5Desc;

  /// No description provided for @challengeShares5Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Difusor'**
  String get challengeShares5Title;

  /// No description provided for @challengeShares5Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Comparte 5 veces esta semana'**
  String get challengeShares5Desc;

  /// No description provided for @challengeSaves5Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Coleccionista'**
  String get challengeSaves5Title;

  /// No description provided for @challengeSaves5Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Guarda 5 publicaciones esta semana'**
  String get challengeSaves5Desc;

  /// No description provided for @challengeStreak5Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Constancia'**
  String get challengeStreak5Title;

  /// No description provided for @challengeStreak5Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Alcanza una racha de 5 días esta semana'**
  String get challengeStreak5Desc;

  /// No description provided for @challengeLikes30Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Generosidad'**
  String get challengeLikes30Title;

  /// No description provided for @challengeLikes30Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Da 30 me gusta esta semana'**
  String get challengeLikes30Desc;

  /// No description provided for @challengePosts5Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Semana productiva'**
  String get challengePosts5Title;

  /// No description provided for @challengePosts5Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Publica 5 veces esta semana'**
  String get challengePosts5Desc;

  /// No description provided for @challengeComments15Title.
  ///
  /// In es_MX, this message translates to:
  /// **'Voz activa'**
  String get challengeComments15Title;

  /// No description provided for @challengeComments15Desc.
  ///
  /// In es_MX, this message translates to:
  /// **'Comenta 15 veces esta semana'**
  String get challengeComments15Desc;

  /// No description provided for @challengeProgressLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{current}/{total} esta semana'**
  String challengeProgressLabel(int current, int total);

  /// No description provided for @challengeClaimedSnackbar.
  ///
  /// In es_MX, this message translates to:
  /// **'¡{coins} ZCoins reclamados!'**
  String challengeClaimedSnackbar(int coins);

  /// No description provided for @challengeClaimedLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Reclamado'**
  String get challengeClaimedLabel;

  /// No description provided for @challengeClaimLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Reclamar'**
  String get challengeClaimLabel;

  /// No description provided for @storeScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Tienda'**
  String get storeScreenTitle;

  /// No description provided for @storeScreenBalanceLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'ZCoins disponibles'**
  String get storeScreenBalanceLabel;

  /// No description provided for @storeScreenColorsSectionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Colores de tema'**
  String get storeScreenColorsSectionTitle;

  /// No description provided for @storeScreenColorsSectionSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Desbloquea colores premium para personalizar tu perfil y tu tema.'**
  String get storeScreenColorsSectionSubtitle;

  /// No description provided for @storeScreenOwnedLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Comprado'**
  String get storeScreenOwnedLabel;

  /// No description provided for @storeScreenPurchaseSuccess.
  ///
  /// In es_MX, this message translates to:
  /// **'¡Color desbloqueado!'**
  String get storeScreenPurchaseSuccess;

  /// No description provided for @storeScreenBuyButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Comprar'**
  String get storeScreenBuyButton;

  /// No description provided for @appearanceGoToStore.
  ///
  /// In es_MX, this message translates to:
  /// **'Ir a la Tienda de colores'**
  String get appearanceGoToStore;

  /// No description provided for @profileMenuChallengesItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Retos y desafíos'**
  String get profileMenuChallengesItem;

  /// No description provided for @profileMenuZCoinsItem.
  ///
  /// In es_MX, this message translates to:
  /// **'ZCoins: {count}'**
  String profileMenuZCoinsItem(int count);

  /// No description provided for @appearanceScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Apariencia'**
  String get appearanceScreenTitle;

  /// No description provided for @appearanceHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Personaliza Zentry'**
  String get appearanceHeading;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Haz que la aplicación se adapte a tu estilo.'**
  String get appearanceSubtitle;

  /// No description provided for @appearanceColorsStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Colores'**
  String get appearanceColorsStat;

  /// No description provided for @appearanceEffectsStat.
  ///
  /// In es_MX, this message translates to:
  /// **'Efectos'**
  String get appearanceEffectsStat;

  /// No description provided for @appearanceThemeCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Tema'**
  String get appearanceThemeCardTitle;

  /// No description provided for @appearanceThemeLight.
  ///
  /// In es_MX, this message translates to:
  /// **'Claro'**
  String get appearanceThemeLight;

  /// No description provided for @appearanceThemeDark.
  ///
  /// In es_MX, this message translates to:
  /// **'Oscuro'**
  String get appearanceThemeDark;

  /// No description provided for @appearanceThemeSystem.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguir sistema'**
  String get appearanceThemeSystem;

  /// No description provided for @appearanceAccentColorCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Color principal'**
  String get appearanceAccentColorCardTitle;

  /// No description provided for @appearancePreviewCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Vista previa'**
  String get appearancePreviewCardTitle;

  /// No description provided for @appearancePreviewName.
  ///
  /// In es_MX, this message translates to:
  /// **'Luis Martínez'**
  String get appearancePreviewName;

  /// No description provided for @appearancePreviewSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Así se verá toda la interfaz de Zentry.'**
  String get appearancePreviewSubtitle;

  /// No description provided for @appearanceAccessibilityCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Accesibilidad'**
  String get appearanceAccessibilityCardTitle;

  /// No description provided for @appearanceTextSizeLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Tamaño del texto'**
  String get appearanceTextSizeLabel;

  /// No description provided for @appearanceAnimationsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Animaciones'**
  String get appearanceAnimationsTitle;

  /// No description provided for @appearanceAnimationsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Activar animaciones de la aplicación'**
  String get appearanceAnimationsSubtitle;

  /// No description provided for @appearanceBlurTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Efecto Blur'**
  String get appearanceBlurTitle;

  /// No description provided for @appearanceBlurSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Aplicar desenfoque en paneles'**
  String get appearanceBlurSubtitle;

  /// No description provided for @appearanceRoundedCornersTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Esquinas redondeadas'**
  String get appearanceRoundedCornersTitle;

  /// No description provided for @appearanceRoundedCornersSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Aplicar bordes suaves'**
  String get appearanceRoundedCornersSubtitle;

  /// No description provided for @appearanceHeroAnimationsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Hero Animations'**
  String get appearanceHeroAnimationsTitle;

  /// No description provided for @appearanceHeroAnimationsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Animaciones entre pantallas'**
  String get appearanceHeroAnimationsSubtitle;

  /// No description provided for @appearanceInfoCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Información'**
  String get appearanceInfoCardTitle;

  /// No description provided for @appearanceCurrentThemeLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Tema actual'**
  String get appearanceCurrentThemeLabel;

  /// No description provided for @appearanceColorLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Color'**
  String get appearanceColorLabel;

  /// No description provided for @appearanceScaleLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Escala'**
  String get appearanceScaleLabel;

  /// No description provided for @notificationsScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Notificaciones'**
  String get notificationsScreenTitle;

  /// No description provided for @notificationsHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Todas tus actividades'**
  String get notificationsHeading;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Mantente al día con todo lo que ocurre en Zentry.'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsStatTotalLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Notificaciones'**
  String get notificationsStatTotalLabel;

  /// No description provided for @notificationsUnreadLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Sin leer'**
  String get notificationsUnreadLabel;

  /// No description provided for @notificationsLikesStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Likes'**
  String get notificationsLikesStatLabel;

  /// No description provided for @notificationsCommentsStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Comentarios'**
  String get notificationsCommentsStatLabel;

  /// No description provided for @notificationsSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar notificación...'**
  String get notificationsSearchHint;

  /// No description provided for @notificationsRecentActivityTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Actividad reciente'**
  String get notificationsRecentActivityTitle;

  /// No description provided for @notificationsReadLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Leída'**
  String get notificationsReadLabel;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No hay notificaciones'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Cuando recibas nuevas actividades aparecerán aquí.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsEmptyActionButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Actualizar'**
  String get notificationsEmptyActionButton;

  /// No description provided for @privacyScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Privacidad'**
  String get privacyScreenTitle;

  /// No description provided for @privacyHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Controla tu privacidad'**
  String get privacyHeading;

  /// No description provided for @privacySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Decide quién puede ver tu información y cómo interactúan contigo.'**
  String get privacySubtitle;

  /// No description provided for @privacySecurityLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguridad'**
  String get privacySecurityLabel;

  /// No description provided for @privacyProfileLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Perfil'**
  String get privacyProfileLabel;

  /// No description provided for @privacyVisibilityPublic.
  ///
  /// In es_MX, this message translates to:
  /// **'Público'**
  String get privacyVisibilityPublic;

  /// No description provided for @privacyVisibilityFollowersOnly.
  ///
  /// In es_MX, this message translates to:
  /// **'Solo seguidores'**
  String get privacyVisibilityFollowersOnly;

  /// No description provided for @privacyVisibilityPrivate.
  ///
  /// In es_MX, this message translates to:
  /// **'Privado'**
  String get privacyVisibilityPrivate;

  /// No description provided for @privacyPrivateAccountTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Cuenta privada'**
  String get privacyPrivateAccountTitle;

  /// No description provided for @privacyPrivateAccountSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Solo los seguidores aprobados podrán ver tu contenido.'**
  String get privacyPrivateAccountSubtitle;

  /// No description provided for @privacyMessagesFromFollowers.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguidores'**
  String get privacyMessagesFromFollowers;

  /// No description provided for @privacyMessagesFromNone.
  ///
  /// In es_MX, this message translates to:
  /// **'Nadie'**
  String get privacyMessagesFromNone;

  /// No description provided for @privacyActivityCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Actividad'**
  String get privacyActivityCardTitle;

  /// No description provided for @privacyShowOnlineStatusTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Mostrar estado en línea'**
  String get privacyShowOnlineStatusTitle;

  /// No description provided for @privacyShowOnlineStatusSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Permite que otros sepan cuándo estás conectado.'**
  String get privacyShowOnlineStatusSubtitle;

  /// No description provided for @privacyShowLastSeenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Mostrar última conexión'**
  String get privacyShowLastSeenTitle;

  /// No description provided for @privacyShowLastSeenSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Muestra la última vez que utilizaste Zentry.'**
  String get privacyShowLastSeenSubtitle;

  /// No description provided for @privacyShowInSearchTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Mostrar perfil en búsquedas'**
  String get privacyShowInSearchTitle;

  /// No description provided for @privacyShowInSearchSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Permite que otros encuentren tu perfil.'**
  String get privacyShowInSearchSubtitle;

  /// No description provided for @privacyTwoFactorTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Verificación en dos pasos'**
  String get privacyTwoFactorTitle;

  /// No description provided for @privacyTwoFactorSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Añade una capa adicional de seguridad.'**
  String get privacyTwoFactorSubtitle;

  /// No description provided for @privacyBlockedUsersTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Usuarios bloqueados'**
  String get privacyBlockedUsersTitle;

  /// No description provided for @privacyUsersCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} usuarios'**
  String privacyUsersCount(int count);

  /// No description provided for @privacyMutedUsersTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Usuarios silenciados'**
  String get privacyMutedUsersTitle;

  /// No description provided for @privacyResetSettingsButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Restablecer configuración'**
  String get privacyResetSettingsButton;

  /// No description provided for @securityScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguridad'**
  String get securityScreenTitle;

  /// No description provided for @securityHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'Protege tu cuenta'**
  String get securityHeading;

  /// No description provided for @securitySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Administra la seguridad de tu cuenta y controla los accesos.'**
  String get securitySubtitle;

  /// No description provided for @securityLevelHighValue.
  ///
  /// In es_MX, this message translates to:
  /// **'Alta'**
  String get securityLevelHighValue;

  /// No description provided for @securitySecurityLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguridad'**
  String get securitySecurityLabel;

  /// No description provided for @securityDevicesStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Dispositivos'**
  String get securityDevicesStatLabel;

  /// No description provided for @securityActivityStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Actividad'**
  String get securityActivityStatLabel;

  /// No description provided for @securityStatusActive.
  ///
  /// In es_MX, this message translates to:
  /// **'Activo'**
  String get securityStatusActive;

  /// No description provided for @securityStatusInactive.
  ///
  /// In es_MX, this message translates to:
  /// **'Inactivo'**
  String get securityStatusInactive;

  /// No description provided for @securityTwoFaStatLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'2FA'**
  String get securityTwoFaStatLabel;

  /// No description provided for @securityAuthenticationCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Autenticación'**
  String get securityAuthenticationCardTitle;

  /// No description provided for @securityChangePasswordTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Cambiar contraseña'**
  String get securityChangePasswordTitle;

  /// No description provided for @securityChangePasswordSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Actualiza tu contraseña periódicamente.'**
  String get securityChangePasswordSubtitle;

  /// No description provided for @securityTwoFactorTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Verificación en dos pasos'**
  String get securityTwoFactorTitle;

  /// No description provided for @securityTwoFactorSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Añade una capa extra de seguridad.'**
  String get securityTwoFactorSubtitle;

  /// No description provided for @securityPasskeysTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Llaves de acceso (Passkeys)'**
  String get securityPasskeysTitle;

  /// No description provided for @securityPasskeysSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Inicia sesión sin contraseña.'**
  String get securityPasskeysSubtitle;

  /// No description provided for @securityTrustedDevicesCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Dispositivos confiables'**
  String get securityTrustedDevicesCardTitle;

  /// No description provided for @securityCurrentDeviceBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'Actual'**
  String get securityCurrentDeviceBadge;

  /// No description provided for @securityRecentActivityCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Actividad reciente'**
  String get securityRecentActivityCardTitle;

  /// No description provided for @securityAlertsCardTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Alertas'**
  String get securityAlertsCardTitle;

  /// No description provided for @securityLoginAlertsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Alertas de inicio de sesión'**
  String get securityLoginAlertsTitle;

  /// No description provided for @securityLoginAlertsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Notificar cuando haya un nuevo acceso.'**
  String get securityLoginAlertsSubtitle;

  /// No description provided for @securitySecurityEmailsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Correos de seguridad'**
  String get securitySecurityEmailsTitle;

  /// No description provided for @securitySecurityEmailsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Recibir correos sobre cambios importantes.'**
  String get securitySecurityEmailsSubtitle;

  /// No description provided for @securityLogoutDialogTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Cerrar sesiones'**
  String get securityLogoutDialogTitle;

  /// No description provided for @securityLogoutDialogContent.
  ///
  /// In es_MX, this message translates to:
  /// **'¿Deseas cerrar sesión en todos los dispositivos?'**
  String get securityLogoutDialogContent;

  /// No description provided for @securityLogoutAllButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Cerrar todas las sesiones'**
  String get securityLogoutAllButton;

  /// No description provided for @settingsScreenSectionAppearance.
  ///
  /// In es_MX, this message translates to:
  /// **'Apariencia'**
  String get settingsScreenSectionAppearance;

  /// No description provided for @settingsScreenThemeItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Tema'**
  String get settingsScreenThemeItem;

  /// No description provided for @settingsScreenLanguageItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Idioma'**
  String get settingsScreenLanguageItem;

  /// No description provided for @settingsScreenSectionNotifications.
  ///
  /// In es_MX, this message translates to:
  /// **'Notificaciones'**
  String get settingsScreenSectionNotifications;

  /// No description provided for @settingsScreenNotificationsItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Notificaciones'**
  String get settingsScreenNotificationsItem;

  /// No description provided for @settingsScreenNotificationsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Administrar preferencias'**
  String get settingsScreenNotificationsSubtitle;

  /// No description provided for @settingsScreenPrivacyItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Privacidad'**
  String get settingsScreenPrivacyItem;

  /// No description provided for @settingsScreenPrivacySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Cuenta, mensajes y bloqueados'**
  String get settingsScreenPrivacySubtitle;

  /// No description provided for @settingsScreenBiometricAuthTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Autenticación biométrica'**
  String get settingsScreenBiometricAuthTitle;

  /// No description provided for @settingsScreenBiometricUnavailable.
  ///
  /// In es_MX, this message translates to:
  /// **'Este dispositivo no tiene huella o rostro configurado en el sistema'**
  String get settingsScreenBiometricUnavailable;

  /// No description provided for @settingsScreenSecurityItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Seguridad'**
  String get settingsScreenSecurityItem;

  /// No description provided for @settingsScreenSecuritySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Contraseña • Verificación en dos pasos'**
  String get settingsScreenSecuritySubtitle;

  /// No description provided for @settingsScreenSectionStorage.
  ///
  /// In es_MX, this message translates to:
  /// **'Almacenamiento'**
  String get settingsScreenSectionStorage;

  /// No description provided for @settingsScreenClearCacheItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Limpiar caché'**
  String get settingsScreenClearCacheItem;

  /// No description provided for @settingsScreenCacheUsedMb.
  ///
  /// In es_MX, this message translates to:
  /// **'{size} MB utilizados'**
  String settingsScreenCacheUsedMb(int size);

  /// No description provided for @settingsScreenManageStorageItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Administrar almacenamiento'**
  String get settingsScreenManageStorageItem;

  /// No description provided for @settingsScreenManageStorageSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Fotos, videos y archivos'**
  String get settingsScreenManageStorageSubtitle;

  /// No description provided for @settingsScreenSectionInfo.
  ///
  /// In es_MX, this message translates to:
  /// **'Información'**
  String get settingsScreenSectionInfo;

  /// No description provided for @settingsScreenAboutItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Acerca de Zentry'**
  String get settingsScreenAboutItem;

  /// No description provided for @settingsScreenVersionLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Versión {version}'**
  String settingsScreenVersionLabel(String version);

  /// No description provided for @settingsScreenTermsItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Términos y condiciones'**
  String get settingsScreenTermsItem;

  /// No description provided for @settingsScreenConsultLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Consultar'**
  String get settingsScreenConsultLabel;

  /// No description provided for @settingsScreenPrivacyPolicyItem.
  ///
  /// In es_MX, this message translates to:
  /// **'Política de privacidad'**
  String get settingsScreenPrivacyPolicyItem;

  /// No description provided for @settingsScreenCommunityBrand.
  ///
  /// In es_MX, this message translates to:
  /// **'Zentry Community'**
  String get settingsScreenCommunityBrand;

  /// No description provided for @settingsScreenClearCacheDialogContent.
  ///
  /// In es_MX, this message translates to:
  /// **'¿Deseas eliminar los archivos temporales?'**
  String get settingsScreenClearCacheDialogContent;

  /// No description provided for @settingsScreenSelectThemeDialogTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Seleccionar tema'**
  String get settingsScreenSelectThemeDialogTitle;

  /// No description provided for @settingsScreenThemeDarkOption.
  ///
  /// In es_MX, this message translates to:
  /// **'Oscuro'**
  String get settingsScreenThemeDarkOption;

  /// No description provided for @settingsScreenThemeLightOption.
  ///
  /// In es_MX, this message translates to:
  /// **'Claro'**
  String get settingsScreenThemeLightOption;

  /// No description provided for @settingsScreenThemeSystemOption.
  ///
  /// In es_MX, this message translates to:
  /// **'Sistema'**
  String get settingsScreenThemeSystemOption;

  /// No description provided for @settingsScreenLanguageEnglishOption.
  ///
  /// In es_MX, this message translates to:
  /// **'English'**
  String get settingsScreenLanguageEnglishOption;

  /// No description provided for @subscriptionScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Planes de Zentry'**
  String get subscriptionScreenTitle;

  /// No description provided for @subscriptionUpgradeButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Mejorar ahora 🚀'**
  String get subscriptionUpgradeButton;

  /// No description provided for @subscriptionPopularBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'🔥 Más popular'**
  String get subscriptionPopularBadge;

  /// No description provided for @subscriptionCurrentPlanButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Plan actual'**
  String get subscriptionCurrentPlanButton;

  /// No description provided for @subscriptionSelectPlanButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Elegir plan'**
  String get subscriptionSelectPlanButton;

  /// No description provided for @subscriptionPricePerMonth.
  ///
  /// In es_MX, this message translates to:
  /// **'/mes'**
  String get subscriptionPricePerMonth;

  /// No description provided for @subscriptionPlanFreeName.
  ///
  /// In es_MX, this message translates to:
  /// **'Gratis'**
  String get subscriptionPlanFreeName;

  /// No description provided for @subscriptionPlanFreeDesc.
  ///
  /// In es_MX, this message translates to:
  /// **'Comienza a crear'**
  String get subscriptionPlanFreeDesc;

  /// No description provided for @subscriptionPlanFreePrice.
  ///
  /// In es_MX, this message translates to:
  /// **'\$0'**
  String get subscriptionPlanFreePrice;

  /// No description provided for @subscriptionPlanFreeFeature1.
  ///
  /// In es_MX, this message translates to:
  /// **'Perfil básico'**
  String get subscriptionPlanFreeFeature1;

  /// No description provided for @subscriptionPlanFreeFeature2.
  ///
  /// In es_MX, this message translates to:
  /// **'5 colaboraciones'**
  String get subscriptionPlanFreeFeature2;

  /// No description provided for @subscriptionPlanFreeFeature3.
  ///
  /// In es_MX, this message translates to:
  /// **'100MB de almacenamiento'**
  String get subscriptionPlanFreeFeature3;

  /// No description provided for @subscriptionPlanProName.
  ///
  /// In es_MX, this message translates to:
  /// **'Pro'**
  String get subscriptionPlanProName;

  /// No description provided for @subscriptionPlanProDesc.
  ///
  /// In es_MX, this message translates to:
  /// **'Haz crecer tu audiencia'**
  String get subscriptionPlanProDesc;

  /// No description provided for @subscriptionPlanProPrice.
  ///
  /// In es_MX, this message translates to:
  /// **'\$9.99'**
  String get subscriptionPlanProPrice;

  /// No description provided for @subscriptionPlanProFeature1.
  ///
  /// In es_MX, this message translates to:
  /// **'Insignia verificada'**
  String get subscriptionPlanProFeature1;

  /// No description provided for @subscriptionPlanProFeature2.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboraciones ilimitadas'**
  String get subscriptionPlanProFeature2;

  /// No description provided for @subscriptionPlanProFeature3.
  ///
  /// In es_MX, this message translates to:
  /// **'5GB de almacenamiento'**
  String get subscriptionPlanProFeature3;

  /// No description provided for @subscriptionPlanProFeature4.
  ///
  /// In es_MX, this message translates to:
  /// **'Estadísticas'**
  String get subscriptionPlanProFeature4;

  /// No description provided for @subscriptionPlanProFeature5.
  ///
  /// In es_MX, this message translates to:
  /// **'Soporte prioritario'**
  String get subscriptionPlanProFeature5;

  /// No description provided for @subscriptionPlanPremiumName.
  ///
  /// In es_MX, this message translates to:
  /// **'Premium'**
  String get subscriptionPlanPremiumName;

  /// No description provided for @subscriptionPlanPremiumDesc.
  ///
  /// In es_MX, this message translates to:
  /// **'Todo el poder'**
  String get subscriptionPlanPremiumDesc;

  /// No description provided for @subscriptionPlanPremiumPrice.
  ///
  /// In es_MX, this message translates to:
  /// **'\$24.99'**
  String get subscriptionPlanPremiumPrice;

  /// No description provided for @subscriptionPlanPremiumFeature1.
  ///
  /// In es_MX, this message translates to:
  /// **'Todo lo del plan Pro'**
  String get subscriptionPlanPremiumFeature1;

  /// No description provided for @subscriptionPlanPremiumFeature2.
  ///
  /// In es_MX, this message translates to:
  /// **'50GB de almacenamiento'**
  String get subscriptionPlanPremiumFeature2;

  /// No description provided for @subscriptionPlanPremiumFeature3.
  ///
  /// In es_MX, this message translates to:
  /// **'Vende contenido'**
  String get subscriptionPlanPremiumFeature3;

  /// No description provided for @subscriptionPlanPremiumFeature4.
  ///
  /// In es_MX, this message translates to:
  /// **'Herramientas de equipo'**
  String get subscriptionPlanPremiumFeature4;

  /// No description provided for @supportScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Centro de Ayuda'**
  String get supportScreenTitle;

  /// No description provided for @supportHeading.
  ///
  /// In es_MX, this message translates to:
  /// **'¿En qué podemos ayudarte?'**
  String get supportHeading;

  /// No description provided for @supportSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Encuentra respuestas o contacta a nuestro equipo.'**
  String get supportSubtitle;

  /// No description provided for @supportSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar ayuda...'**
  String get supportSearchHint;

  /// No description provided for @supportStatArticlesValue.
  ///
  /// In es_MX, this message translates to:
  /// **'248'**
  String get supportStatArticlesValue;

  /// No description provided for @supportStatArticlesLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Artículos'**
  String get supportStatArticlesLabel;

  /// No description provided for @supportStatTicketsValue.
  ///
  /// In es_MX, this message translates to:
  /// **'12'**
  String get supportStatTicketsValue;

  /// No description provided for @supportStatTicketsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Tickets'**
  String get supportStatTicketsLabel;

  /// No description provided for @supportStatResponseValue.
  ///
  /// In es_MX, this message translates to:
  /// **'<24 h'**
  String get supportStatResponseValue;

  /// No description provided for @supportStatResponseLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Respuesta'**
  String get supportStatResponseLabel;

  /// No description provided for @supportStatSupportValue.
  ///
  /// In es_MX, this message translates to:
  /// **'24/7'**
  String get supportStatSupportValue;

  /// No description provided for @supportStatSupportLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Soporte'**
  String get supportStatSupportLabel;

  /// No description provided for @supportOptionFaqTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Preguntas frecuentes'**
  String get supportOptionFaqTitle;

  /// No description provided for @supportOptionFaqSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Resuelve tus dudas rápidamente.'**
  String get supportOptionFaqSubtitle;

  /// No description provided for @supportOptionContactTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Contactar soporte'**
  String get supportOptionContactTitle;

  /// No description provided for @supportOptionContactSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Habla directamente con nuestro equipo.'**
  String get supportOptionContactSubtitle;

  /// No description provided for @supportOptionReportBugTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Reportar un error'**
  String get supportOptionReportBugTitle;

  /// No description provided for @supportOptionReportBugSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Ayúdanos a mejorar Zentry.'**
  String get supportOptionReportBugSubtitle;

  /// No description provided for @supportOptionSuggestionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Enviar sugerencia'**
  String get supportOptionSuggestionTitle;

  /// No description provided for @supportOptionSuggestionSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Comparte tus ideas con nosotros.'**
  String get supportOptionSuggestionSubtitle;

  /// No description provided for @supportOptionPrivacyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Política de privacidad'**
  String get supportOptionPrivacyTitle;

  /// No description provided for @supportOptionPrivacySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Conoce cómo protegemos tus datos.'**
  String get supportOptionPrivacySubtitle;

  /// No description provided for @supportOptionTermsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Términos y condiciones'**
  String get supportOptionTermsTitle;

  /// No description provided for @supportOptionTermsSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Información legal de la plataforma.'**
  String get supportOptionTermsSubtitle;

  /// No description provided for @supportRecentTicketsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Tickets recientes'**
  String get supportRecentTicketsTitle;

  /// No description provided for @supportTicketStatusInReview.
  ///
  /// In es_MX, this message translates to:
  /// **'En revisión'**
  String get supportTicketStatusInReview;

  /// No description provided for @supportTicketStatusResolved.
  ///
  /// In es_MX, this message translates to:
  /// **'Resuelto'**
  String get supportTicketStatusResolved;

  /// No description provided for @supportEmptyTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'No encontramos resultados'**
  String get supportEmptyTitle;

  /// No description provided for @supportEmptySubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Prueba con otra búsqueda o explora las opciones disponibles.'**
  String get supportEmptySubtitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar categorías o disciplinas...'**
  String get exploreSearchHint;

  /// No description provided for @exploreCategoriesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Categorías'**
  String get exploreCategoriesTitle;

  /// No description provided for @exploreCategoriesSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Explora todas las disciplinas creativas de Zentry'**
  String get exploreCategoriesSubtitle;

  /// No description provided for @exploreSubcategoryCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} categorías'**
  String exploreSubcategoryCount(int count);

  /// No description provided for @exploreSearchResultsCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} resultados'**
  String exploreSearchResultsCount(int count);

  /// No description provided for @exploreCreatorResultsCount.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} perfiles'**
  String exploreCreatorResultsCount(int count);

  /// No description provided for @exploreNoSearchResults.
  ///
  /// In es_MX, this message translates to:
  /// **'No encontramos categorías con ese nombre'**
  String get exploreNoSearchResults;

  /// No description provided for @searchScreenHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Buscar en Zentry...'**
  String get searchScreenHint;

  /// No description provided for @searchTabAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Todos'**
  String get searchTabAll;

  /// No description provided for @searchTabUsers.
  ///
  /// In es_MX, this message translates to:
  /// **'Usuarios'**
  String get searchTabUsers;

  /// No description provided for @searchTabPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get searchTabPosts;

  /// No description provided for @searchTabCommunities.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades'**
  String get searchTabCommunities;

  /// No description provided for @searchTabProjects.
  ///
  /// In es_MX, this message translates to:
  /// **'Proyectos'**
  String get searchTabProjects;

  /// No description provided for @searchTabCategories.
  ///
  /// In es_MX, this message translates to:
  /// **'Categorías'**
  String get searchTabCategories;

  /// No description provided for @searchSectionUsers.
  ///
  /// In es_MX, this message translates to:
  /// **'Usuarios'**
  String get searchSectionUsers;

  /// No description provided for @searchSectionPosts.
  ///
  /// In es_MX, this message translates to:
  /// **'Publicaciones'**
  String get searchSectionPosts;

  /// No description provided for @searchSectionCommunities.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidades'**
  String get searchSectionCommunities;

  /// No description provided for @searchSectionProjects.
  ///
  /// In es_MX, this message translates to:
  /// **'Proyectos'**
  String get searchSectionProjects;

  /// No description provided for @searchSectionCategories.
  ///
  /// In es_MX, this message translates to:
  /// **'Categorías'**
  String get searchSectionCategories;

  /// No description provided for @searchNoResults.
  ///
  /// In es_MX, this message translates to:
  /// **'No encontramos resultados'**
  String get searchNoResults;

  /// No description provided for @searchEmptyHint.
  ///
  /// In es_MX, this message translates to:
  /// **'Busca usuarios, publicaciones, comunidades, proyectos, categorías o #hashtags'**
  String get searchEmptyHint;

  /// No description provided for @categoryDetailSubcategoriesTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Subcategorías'**
  String get categoryDetailSubcategoriesTitle;

  /// No description provided for @categoryDetailAllChip.
  ///
  /// In es_MX, this message translates to:
  /// **'Todas'**
  String get categoryDetailAllChip;

  /// No description provided for @categoryDetailCreatorsInLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Creadores en {subcategory}'**
  String categoryDetailCreatorsInLabel(String subcategory);

  /// No description provided for @homeRolesNeededLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Roles buscados'**
  String get homeRolesNeededLabel;

  /// No description provided for @homeCollabPublicBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboración pública'**
  String get homeCollabPublicBadge;

  /// No description provided for @homeCollabPrivateBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboración privada'**
  String get homeCollabPrivateBadge;

  /// No description provided for @homeFileSizeKb.
  ///
  /// In es_MX, this message translates to:
  /// **'{size} KB'**
  String homeFileSizeKb(String size);

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In es_MX, this message translates to:
  /// **'Marcar todas como leídas'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'No tienes notificaciones todavía'**
  String get notificationsEmptyLabel;

  /// No description provided for @notificationsAchievementUnlockedTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'¡Logro desbloqueado!'**
  String get notificationsAchievementUnlockedTitle;

  /// No description provided for @notificationsAchievementUnlockedBody.
  ///
  /// In es_MX, this message translates to:
  /// **'{title} · +{points} ZCoins'**
  String notificationsAchievementUnlockedBody(String title, int points);

  /// No description provided for @notificationsChallengeClaimedTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Reto completado'**
  String get notificationsChallengeClaimedTitle;

  /// No description provided for @notificationsChallengeClaimedBody.
  ///
  /// In es_MX, this message translates to:
  /// **'{title} · +{coins} ZCoins'**
  String notificationsChallengeClaimedBody(String title, int coins);

  /// No description provided for @notificationsLikeTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Nuevo like'**
  String get notificationsLikeTitle;

  /// No description provided for @notificationsLikeBody.
  ///
  /// In es_MX, this message translates to:
  /// **'A alguien le gustó tu publicación: \"{preview}\"'**
  String notificationsLikeBody(String preview);

  /// No description provided for @notificationsCommentTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Nuevo comentario'**
  String get notificationsCommentTitle;

  /// No description provided for @notificationsCommentBody.
  ///
  /// In es_MX, this message translates to:
  /// **'{actor} comentó: \"{comment}\"'**
  String notificationsCommentBody(String actor, String comment);

  /// No description provided for @notificationsFollowTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Nuevo seguidor'**
  String get notificationsFollowTitle;

  /// No description provided for @notificationsFollowBody.
  ///
  /// In es_MX, this message translates to:
  /// **'{actor} empezó a seguirte'**
  String notificationsFollowBody(String actor);

  /// No description provided for @notificationsCommunityJoinRequestTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud para unirse'**
  String get notificationsCommunityJoinRequestTitle;

  /// No description provided for @notificationsCommunityJoinRequestBody.
  ///
  /// In es_MX, this message translates to:
  /// **'{actor} quiere unirse a {community}'**
  String notificationsCommunityJoinRequestBody(String actor, String community);

  /// No description provided for @notificationsCommunityRequestApprovedTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud aceptada'**
  String get notificationsCommunityRequestApprovedTitle;

  /// No description provided for @notificationsCommunityRequestApprovedBody.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu solicitud para unirte a {community} fue aceptada'**
  String notificationsCommunityRequestApprovedBody(String community);

  /// No description provided for @notificationsCommunityRequestRejectedTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud rechazada'**
  String get notificationsCommunityRequestRejectedTitle;

  /// No description provided for @notificationsCommunityRequestRejectedBody.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu solicitud para unirte a {community} fue rechazada'**
  String notificationsCommunityRequestRejectedBody(String community);

  /// No description provided for @notificationsCommunityNewPostTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Nueva publicación'**
  String get notificationsCommunityNewPostTitle;

  /// No description provided for @notificationsCommunityNewPostBody.
  ///
  /// In es_MX, this message translates to:
  /// **'Hay una nueva publicación en {community}'**
  String notificationsCommunityNewPostBody(String community);

  /// No description provided for @notificationsMentionTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Te mencionaron'**
  String get notificationsMentionTitle;

  /// No description provided for @notificationsMentionBody.
  ///
  /// In es_MX, this message translates to:
  /// **'{actor} te mencionó: \"{preview}\"'**
  String notificationsMentionBody(String actor, String preview);

  /// No description provided for @notificationsCollaborationRequestTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Solicitud de colaboración'**
  String get notificationsCollaborationRequestTitle;

  /// No description provided for @notificationsCollaborationRequestBody.
  ///
  /// In es_MX, this message translates to:
  /// **'{actor} quiere colaborar en \"{title}\"'**
  String notificationsCollaborationRequestBody(String actor, String title);

  /// No description provided for @notificationsCollaborationAcceptedTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboración aceptada'**
  String get notificationsCollaborationAcceptedTitle;

  /// No description provided for @notificationsCollaborationAcceptedBody.
  ///
  /// In es_MX, this message translates to:
  /// **'Te aceptaron para colaborar en \"{title}\"'**
  String notificationsCollaborationAcceptedBody(String title);

  /// No description provided for @notificationsFilterAll.
  ///
  /// In es_MX, this message translates to:
  /// **'Todas'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterAchievements.
  ///
  /// In es_MX, this message translates to:
  /// **'Logros'**
  String get notificationsFilterAchievements;

  /// No description provided for @notificationsFilterSocial.
  ///
  /// In es_MX, this message translates to:
  /// **'Social'**
  String get notificationsFilterSocial;

  /// No description provided for @notificationsFilterCommunity.
  ///
  /// In es_MX, this message translates to:
  /// **'Comunidad'**
  String get notificationsFilterCommunity;

  /// No description provided for @notificationsFilterCollaboration.
  ///
  /// In es_MX, this message translates to:
  /// **'Colaboración'**
  String get notificationsFilterCollaboration;

  /// No description provided for @ranksScreenTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Rangos'**
  String get ranksScreenTitle;

  /// No description provided for @ranksScreenSubtitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Sube de rango acumulando puntos de logros y racha'**
  String get ranksScreenSubtitle;

  /// No description provided for @ranksScreenCountLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{count} rangos disponibles'**
  String ranksScreenCountLabel(int count);

  /// No description provided for @ranksMinPointsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Desde {points} puntos'**
  String ranksMinPointsLabel(int points);

  /// No description provided for @ranksCurrentBadge.
  ///
  /// In es_MX, this message translates to:
  /// **'Tu rango actual'**
  String get ranksCurrentBadge;

  /// No description provided for @ranksNextRankTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Progreso al siguiente rango'**
  String get ranksNextRankTitle;

  /// No description provided for @ranksPointsToNextLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'{points} puntos para {rank}'**
  String ranksPointsToNextLabel(int points, String rank);

  /// No description provided for @ranksMaxRankLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'¡Alcanzaste el rango máximo!'**
  String get ranksMaxRankLabel;

  /// No description provided for @ranksExportPdfButton.
  ///
  /// In es_MX, this message translates to:
  /// **'Exportar progreso en PDF'**
  String get ranksExportPdfButton;

  /// No description provided for @ranksPerkLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Beneficio'**
  String get ranksPerkLabel;

  /// No description provided for @ranksPerkBronze.
  ///
  /// In es_MX, this message translates to:
  /// **'Acceso a retos básicos y a la tienda de la comunidad'**
  String get ranksPerkBronze;

  /// No description provided for @ranksPerkSilver.
  ///
  /// In es_MX, this message translates to:
  /// **'Marco de perfil plateado y prioridad en soporte'**
  String get ranksPerkSilver;

  /// No description provided for @ranksPerkGold.
  ///
  /// In es_MX, this message translates to:
  /// **'Insignia dorada visible en tu perfil y comentarios'**
  String get ranksPerkGold;

  /// No description provided for @ranksPerkPlatinum.
  ///
  /// In es_MX, this message translates to:
  /// **'Destacado en el explorador de creadores'**
  String get ranksPerkPlatinum;

  /// No description provided for @ranksPerkDiamond.
  ///
  /// In es_MX, this message translates to:
  /// **'Acceso anticipado a eventos y colaboraciones exclusivas'**
  String get ranksPerkDiamond;

  /// No description provided for @ranksPerkMaster.
  ///
  /// In es_MX, this message translates to:
  /// **'Marco animado exclusivo y mención en la comunidad destacada'**
  String get ranksPerkMaster;

  /// No description provided for @ranksExportPdfSuccess.
  ///
  /// In es_MX, this message translates to:
  /// **'PDF guardado y abierto'**
  String get ranksExportPdfSuccess;

  /// No description provided for @ranksExportPdfError.
  ///
  /// In es_MX, this message translates to:
  /// **'No se pudo generar el PDF'**
  String get ranksExportPdfError;

  /// No description provided for @pdfDocTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Constancia de progreso Zentry'**
  String get pdfDocTitle;

  /// No description provided for @pdfDocGeneratedOn.
  ///
  /// In es_MX, this message translates to:
  /// **'Generado el {date}'**
  String pdfDocGeneratedOn(String date);

  /// No description provided for @pdfDocRankLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Rango actual: {rank}'**
  String pdfDocRankLabel(String rank);

  /// No description provided for @pdfDocPointsLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Puntos totales: {points}'**
  String pdfDocPointsLabel(int points);

  /// No description provided for @pdfDocAchievementsTitle.
  ///
  /// In es_MX, this message translates to:
  /// **'Logros desbloqueados'**
  String get pdfDocAchievementsTitle;

  /// No description provided for @pdfDocNoAchievements.
  ///
  /// In es_MX, this message translates to:
  /// **'Aún no has desbloqueado logros'**
  String get pdfDocNoAchievements;

  /// No description provided for @pdfDocStreakLabel.
  ///
  /// In es_MX, this message translates to:
  /// **'Racha actual: {days} días (mejor racha: {best})'**
  String pdfDocStreakLabel(int days, int best);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es', 'nah'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case 'MX':
            return AppLocalizationsEsMx();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'nah':
      return AppLocalizationsNah();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
