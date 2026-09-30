// Test de la corrección de video en tablets Huawei (Kirin, decoders
// limitados): `ZentryVideoDecoderCoordinator` debe garantizar que dos
// tareas de inicialización de video NUNCA se ejecuten solapadas, sin
// importar si la primera tarda, falla o tiene éxito.

import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/core/video/zentry_video_decoder_coordinator.dart';

void main() {
  group('ZentryVideoDecoderCoordinator.runExclusive', () {
    test(
      'dos tareas nunca se ejecutan al mismo tiempo (se serializan)',
      () async {
        final coordinator = ZentryVideoDecoderCoordinator.instance;
        final events = <String>[];

        final first = coordinator.runExclusive(() async {
          events.add('A-start');
          await Future.delayed(const Duration(milliseconds: 50));
          events.add('A-end');
          return 'A';
        });
        final second = coordinator.runExclusive(() async {
          events.add('B-start');
          await Future.delayed(const Duration(milliseconds: 10));
          events.add('B-end');
          return 'B';
        });

        final results = await Future.wait([first, second]);

        expect(results, ['A', 'B']);
        // B nunca debe empezar antes de que A termine — si estuvieran
        // solapadas, 'B-start' aparecería antes de 'A-end'.
        expect(events, ['A-start', 'A-end', 'B-start', 'B-end']);
      },
    );

    test('si una tarea falla, no bloquea a la siguiente en la cola', () async {
      final coordinator = ZentryVideoDecoderCoordinator.instance;
      final events = <String>[];

      Object? caught;
      final failing = () async {
        try {
          await coordinator.runExclusive<void>(() async {
            events.add('fail-start');
            throw Exception('decoder init failed');
          });
        } catch (e) {
          caught = e;
        }
      }();

      final after = coordinator.runExclusive(() async {
        events.add('after-start');
        return 'after';
      });

      await failing;
      final afterResult = await after;

      expect(caught, isNotNull);
      expect(afterResult, 'after');
      expect(events, ['fail-start', 'after-start']);
    });

    test('tareas encoladas conservan su orden de llegada (FIFO)', () async {
      final coordinator = ZentryVideoDecoderCoordinator.instance;
      final order = <int>[];

      final tasks = List.generate(5, (i) {
        return coordinator.runExclusive(() async {
          order.add(i);
        });
      });

      await Future.wait(tasks);
      expect(order, [0, 1, 2, 3, 4]);
    });
  });
}
