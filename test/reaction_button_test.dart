// ReactionButton reemplazó al AnimatedLikeButton (ahora eliminado) en el feed
// real. Estos tests cubren el contrato que el backend puede sostener hoy
// (like/unlike booleano real) y el comportamiento puramente visual del
// selector de 6 reacciones (Fase 10-11 del reporte: sólo ❤️ persiste de
// verdad, el resto es local).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/features/home/widgets/reaction_button.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

/// `ReactionButton`/`_ReactionOption` resuelven las etiquetas de tooltip vía
/// `AppLocalizations.of(context)`, así que el `MaterialApp` de prueba
/// necesita los delegates reales (un `MaterialApp` sin ellos deja ese
/// `.of(context)` en null y el widget revienta al abrir el selector).
///
/// El selector flotante se abre hacia ARRIBA del botón (igual que en el feed
/// real, donde el botón siempre tiene la imagen/texto del post encima). Se
/// deja hueco arriba para reproducir esa posición realista — con el botón
/// pegado al borde superior del viewport (y=0) el selector renderizaría
/// fuera de pantalla, algo que no ocurre en la app real.
Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.only(top: 300), child: child),
    ),
  );
}

void main() {
  testWidgets(
    'toque rápido alterna el like real con la reacción predeterminada (❤️)',
    (tester) async {
      bool? lastToggle;
      var likedCallbackCount = 0;

      await tester.pumpWidget(
        _wrap(
          ReactionButton(
            likes: 10,
            initialLiked: false,
            onToggle: (v) => lastToggle = v,
            onLiked: () => likedCallbackCount++,
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      await tester.tap(find.byType(ReactionButton));
      await tester.pumpAndSettle();

      expect(lastToggle, isTrue);
      expect(likedCallbackCount, 1);
      expect(find.text('❤️'), findsOneWidget);

      // Tocar de nuevo quita el like (mismo contrato que el corazón anterior).
      await tester.tap(find.byType(ReactionButton));
      await tester.pumpAndSettle();
      expect(lastToggle, isFalse);
      expect(likedCallbackCount, 1); // onLiked NO se llama al quitar el like.
    },
  );

  testWidgets('pulsación prolongada muestra las 6 reacciones de Zentry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const ReactionButton(likes: 0, initialLiked: false)),
    );

    await tester.longPress(find.byType(ReactionButton));
    await tester.pumpAndSettle();

    for (final reaction in kZentryReactions) {
      expect(find.text(reaction.emoji), findsOneWidget);
    }
  });

  testWidgets(
    'elegir una reacción del selector la muestra en el botón y notifica onToggle(true)',
    (tester) async {
      bool? lastToggle;
      await tester.pumpWidget(
        _wrap(
          ReactionButton(
            likes: 0,
            initialLiked: false,
            onToggle: (v) => lastToggle = v,
          ),
        ),
      );

      await tester.longPress(find.byType(ReactionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🔥'));
      await tester.pumpAndSettle();

      expect(lastToggle, isTrue);
      // El selector se cerró (sólo queda el emoji elegido, en el botón).
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('👍'), findsNothing);
    },
  );

  testWidgets('tocar fuera del selector lo cierra sin cambiar el estado', (
    tester,
  ) async {
    bool toggled = false;
    await tester.pumpWidget(
      _wrap(
        ReactionButton(
          likes: 0,
          initialLiked: false,
          onToggle: (_) => toggled = true,
        ),
      ),
    );

    await tester.longPress(find.byType(ReactionButton));
    await tester.pumpAndSettle();
    expect(find.text('🎨'), findsOneWidget);

    await tester.tapAt(const Offset(300, 500));
    await tester.pumpAndSettle();

    expect(find.text('🎨'), findsNothing);
    expect(toggled, isFalse);
  });

  testWidgets(
    'elegir la misma reacción activa la quita (permite deseleccionar)',
    (tester) async {
      bool? lastToggle;
      await tester.pumpWidget(
        _wrap(
          ReactionButton(
            likes: 0,
            initialLiked: true,
            onToggle: (v) => lastToggle = v,
          ),
        ),
      );

      // initialLiked=true pero con el emoji predeterminado (❤️).
      await tester.longPress(find.byType(ReactionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('❤️').last);
      await tester.pumpAndSettle();

      expect(lastToggle, isFalse);
    },
  );
}
