// Tests de la Fase 3B (multimedia del feed + sincronización de historias):
// parsing de contratos reales del backend (sin red) y de la lógica pura de
// agrupación/"visto por" de historias, que ya causó un bug sutil durante el
// desarrollo (comparar displayName vs username) y conviene cubrir para que
// no vuelva a colarse.

import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/core/models/backend/post_response.dart';
import 'package:Zentry/core/models/backend/story_response.dart';
import 'package:Zentry/core/providers/posts_controller.dart';

void main() {
  group('PostResponse.fromJson — multimedia (Fase 3B)', () {
    test('parsea mediaUrls con varias imágenes y las resuelve a absolutas', () {
      final post = PostResponse.fromJson({
        'id': 1,
        'mediaUrls': [
          'http://api.zentry.test/uploads/a.jpg',
          'http://api.zentry.test/uploads/b.jpg',
          'http://api.zentry.test/uploads/c.jpg',
        ],
      });

      expect(post.mediaUrls.length, 3);
      expect(post.mediaUrlsAbsolute, [
        'http://api.zentry.test/uploads/a.jpg',
        'http://api.zentry.test/uploads/b.jpg',
        'http://api.zentry.test/uploads/c.jpg',
      ]);
    });

    test(
      'post sin mediaUrls (legacy, una sola imagen) deja la lista vacía',
      () {
        final post = PostResponse.fromJson({
          'id': 2,
          'image_url': 'http://api.zentry.test/uploads/single.jpg',
        });

        expect(post.mediaUrls, isEmpty);
        expect(
          post.imageUrlAbsolute,
          'http://api.zentry.test/uploads/single.jpg',
        );
      },
    );

    test('contentType de video no depende de la cantidad de mediaUrls', () {
      final post = PostResponse.fromJson({
        'id': 3,
        'content_type': 'video',
        'image_url': 'http://api.zentry.test/uploads/clip.mp4',
      });

      expect(post.contentType, 'video');
      expect(post.imageUrlAbsolute, isNotNull);
    });
  });

  group('PostResponse.isVideoContent — corrección "videos no aparecen"', () {
    test('post sin ningún media: no es video y no crashea', () {
      final post = PostResponse.fromJson({'id': 1});
      expect(post.isVideoContent, isFalse);
      expect(post.imageUrlAbsolute, isNull);
    });

    test('post de imagen normal: no se detecta como video', () {
      final post = PostResponse.fromJson({
        'id': 2,
        'content_type': 'post',
        'image_url': 'http://api.zentry.test/uploads/foto.jpg',
      });
      expect(post.isVideoContent, isFalse);
    });

    test(
      'contentType="video" (metadata real que Flutter controla) detecta video',
      () {
        final post = PostResponse.fromJson({
          'id': 3,
          'content_type': 'video',
          'image_url': 'http://api.zentry.test/uploads/clip.mp4',
        });
        expect(post.isVideoContent, isTrue);
      },
    );

    test(
      'sin contentType, cae al fallback por extensión de la URL (post legacy/sin metadata)',
      () {
        final post = PostResponse.fromJson({
          'id': 4,
          'image_url': 'http://api.zentry.test/uploads/clip.mp4',
        });
        expect(post.contentType, isNull);
        expect(post.isVideoContent, isTrue);
      },
    );

    test('el fallback por extensión ignora mayúsculas/minúsculas', () {
      final post = PostResponse.fromJson({
        'id': 5,
        'image_url': 'http://api.zentry.test/uploads/CLIP.MP4',
      });
      expect(post.isVideoContent, isTrue);
    });

    test('el fallback por extensión ignora query params (URLs firmadas)', () {
      final post = PostResponse.fromJson({
        'id': 6,
        'image_url':
            'http://api.zentry.test/uploads/clip.mp4?token=abc123&exp=999',
      });
      expect(post.isVideoContent, isTrue);
    });

    test(
      'una URL de imagen con query params no se detecta falsamente como video',
      () {
        final post = PostResponse.fromJson({
          'id': 7,
          'image_url': 'http://api.zentry.test/uploads/foto.jpg?v=2',
        });
        expect(post.isVideoContent, isFalse);
      },
    );
  });

  group('StoryResponse / StoryGroupResponse — parsing snake_case real', () {
    test('StoryResponse.fromJson interpreta los campos del backend', () {
      final story = StoryResponse.fromJson({
        'id': 10,
        'user_id': 5,
        'media_url': '/uploads/stories/10.jpg',
        'media_type': 'IMAGE',
        'view_count': 3,
        'likes_count': 1,
        'is_viewed': true,
        'is_liked': false,
      });

      expect(story.id, 10);
      expect(story.userId, 5);
      expect(story.isVideo, isFalse);
      expect(story.viewCount, 3);
      expect(story.isViewed, isTrue);
      expect(story.mediaUrlAbsolute, isNotNull);
    });

    test('StoryGroupResponse.fromJson agrupa los items anidados', () {
      final group = StoryGroupResponse.fromJson({
        'user_id': 5,
        'username': 'angelito',
        'name': 'Angel',
        'items': [
          {'id': 10, 'user_id': 5, 'media_type': 'IMAGE'},
          {'id': 11, 'user_id': 5, 'media_type': 'VIDEO'},
        ],
      });

      expect(group.displayName, 'Angel');
      expect(group.items.length, 2);
      expect(group.items[1].isVideo, isTrue);
    });
  });

  group('PostsController.backendGroupedStories — visto por (regresión)', () {
    test(
      'allSeenBy compara con el DISPLAY NAME del viewer, no con su username',
      () {
        final controller = PostsController();
        controller.backendStoryGroups.add(
          StoryGroupResponse.fromJson({
            'user_id': 9,
            'username': 'otro_user',
            'name': 'Otro',
            'items': [
              {'id': 20, 'user_id': 9, 'is_viewed': true},
            ],
          }),
        );

        final groups = controller.backendGroupedStories(
          viewerDisplayName: 'Mi Nombre Visible',
        );

        expect(groups, hasLength(1));
        // La historia ya fue vista por el usuario actual (is_viewed=true) y
        // debe reconocerse usando exactamente el mismo displayName que se le
        // pasó a backendGroupedStories, o allSeenBy nunca daría true.
        expect(groups.first.allSeenBy('Mi Nombre Visible'), isTrue);
      },
    );

    test('firstUnseenIndexFor detecta una historia no vista', () {
      final controller = PostsController();
      controller.backendStoryGroups.add(
        StoryGroupResponse.fromJson({
          'user_id': 9,
          'username': 'otro_user',
          'items': [
            {'id': 20, 'user_id': 9, 'is_viewed': true},
            {'id': 21, 'user_id': 9, 'is_viewed': false},
          ],
        }),
      );

      final groups = controller.backendGroupedStories(viewerDisplayName: 'Yo');

      expect(groups.first.allSeenBy('Yo'), isFalse);
      expect(groups.first.firstUnseenIndexFor('Yo'), 1);
    });
  });

  group(
    'Regresión: "Bad state: No element" en la fila de historias del Home',
    () {
      // Causa raíz real (confirmada leyendo StoryService.java del backend,
      // sin modificarlo): GET /api/core/stories/feed siempre agrega un
      // grupo con items:[] para el usuario autenticado cuando éste todavía
      // no tiene ninguna historia activa propia (para que el frontend
      // pueda mostrar el círculo de "añadir historia"). `backendGroupedStories`
      // antes convertía CADA grupo recibido en un `StoryGroup`, incluido
      // ese; `home_screen.dart` llama a `group.latest` (`items.last`) para
      // cada uno, lo que lanzaba `StateError: Bad state: No element` sobre
      // ese grupo vacío en cuanto el usuario no tenía historia propia (el
      // caso más común). El fix filtra los grupos sin items en el único
      // punto de transformación hacia la UI.

      test(
        'backendStoryGroups vacío no lanza excepción y no produce grupos',
        () {
          final controller = PostsController();
          expect(
            () => controller.backendGroupedStories(viewerDisplayName: 'Yo'),
            returnsNormally,
          );
          expect(
            controller.backendGroupedStories(viewerDisplayName: 'Yo'),
            isEmpty,
          );
        },
      );

      test('un grupo con items:[] (placeholder "añadir historia" del propio '
          'usuario) se filtra y NUNCA llega a necesitar .latest', () {
        final controller = PostsController();
        controller.backendStoryGroups.add(
          StoryGroupResponse.fromJson({
            'user_id': 1,
            'username': 'yo_mismo',
            'is_user': true,
            'items': <dynamic>[], // exactamente lo que manda el backend
          }),
        );

        final groups = controller.backendGroupedStories(
          viewerDisplayName: 'Yo',
        );

        expect(groups, isEmpty);
        // Ya no hace falta llamar a `.latest` porque el grupo vacío ni
        // siquiera está en la lista — pero si por error volviera a
        // colarse, `.latest` seguiría siendo `items.last`, así que la
        // aserción real de esta prueba es que `groups` no lo contenga.
      });

      test('un grupo vacío (propio) junto con historias reales de otros '
          'usuarios: sólo las reales llegan a la UI, sin excepción', () {
        final controller = PostsController();
        controller.backendStoryGroups.addAll([
          StoryGroupResponse.fromJson({
            'user_id': 1,
            'username': 'yo_mismo',
            'is_user': true,
            'items': <dynamic>[],
          }),
          StoryGroupResponse.fromJson({
            'user_id': 2,
            'username': 'otro',
            'items': [
              {'id': 30, 'user_id': 2, 'media_type': 'IMAGE'},
            ],
          }),
        ]);

        List<dynamic> groups = [];
        expect(
          () => groups = controller.backendGroupedStories(
            viewerDisplayName: 'Yo',
          ),
          returnsNormally,
        );
        expect(groups, hasLength(1));
        expect((groups.first as StoryGroup).user, 'otro');
        // Acceder a `.latest` sobre el resultado final nunca debe lanzar.
        expect(() => (groups.first as StoryGroup).latest, returnsNormally);
      });

      test(
        'StoryGroup.allSeenBy con items vacíos no lanza (vacuamente true)',
        () {
          const group = StoryGroup(user: 'x', userId: 1, items: []);
          expect(() => group.allSeenBy('Yo'), returnsNormally);
          expect(group.allSeenBy('Yo'), isTrue);
        },
      );

      test('StoryGroup.firstUnseenIndexFor con items vacíos no lanza', () {
        const group = StoryGroup(user: 'x', userId: 1, items: []);
        expect(() => group.firstUnseenIndexFor('Yo'), returnsNormally);
        expect(group.firstUnseenIndexFor('Yo'), 0);
      });
    },
  );
}
