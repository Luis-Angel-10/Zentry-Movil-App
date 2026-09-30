// Tests de parsing puro de los DTOs del backend (sin red, sin mocks): sólo
// verifican que `fromJson` interpreta correctamente los contratos reales
// documentados en los core/dtos/*.java del backend, incluyendo los casos
// "raros" (doble clave `isFollowing`/`following`, snake_case vs camelCase)
// que ya causaron confusión en sesiones anteriores.

import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/core/models/backend/friend_user_response.dart';
import 'package:Zentry/core/models/backend/profile_response.dart';
import 'package:Zentry/core/models/backend/streak_response.dart';

void main() {
  group('StreakResponse.fromJson', () {
    test('parsea los 5 campos reales de StreakResponse', () {
      final streak = StreakResponse.fromJson({
        'userId': 12,
        'currentStreak': 5,
        'longestStreak': 9,
        'lastActivityDate': '2026-09-16',
        'activeToday': true,
      });

      expect(streak.userId, 12);
      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 9);
      expect(streak.lastActivityDate, DateTime(2026, 9, 16));
      expect(streak.activeToday, isTrue);
    });

    test('valores por defecto cuando faltan campos (racha nunca iniciada)', () {
      final streak = StreakResponse.fromJson({'userId': 3});
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.lastActivityDate, isNull);
      expect(streak.activeToday, isFalse);
    });
  });

  group('ProfileResponse.fromJson — estado de follow', () {
    test(
      'followersCount/followingCount e isFollowing=true (clave "isFollowing")',
      () {
        final profile = ProfileResponse.fromJson({
          'username': 'angelito',
          'followersCount': 42,
          'followingCount': 7,
          'isFollowing': true,
        });
        expect(profile.followersCount, 42);
        expect(profile.followingCount, 7);
        expect(profile.isFollowing, isTrue);
      },
    );

    test(
      'isFollowing=true también cuando el backend sólo manda "following"',
      () {
        final profile = ProfileResponse.fromJson({
          'username': 'angelito',
          'following': true,
        });
        expect(profile.isFollowing, isTrue);
      },
    );

    test(
      'isFollowing=false por defecto si el backend no manda ninguna de las dos claves',
      () {
        final profile = ProfileResponse.fromJson({'username': 'angelito'});
        expect(profile.isFollowing, isFalse);
        expect(profile.followersCount, isNull);
      },
    );
  });

  group('FriendUserResponse.fromJson', () {
    test(
      'acepta snake_case (formato real de /api/core/friends/suggestions)',
      () {
        final friend = FriendUserResponse.fromJson({
          'id': 7,
          'username': 'angelito',
          'name': 'Angel',
          'avatar_url': '/uploads/profiles/7.png',
          'mutual_friends_count': 3,
        });
        expect(friend.id, 7);
        expect(friend.displayName, 'Angel');
        expect(friend.mutualFriendsCount, 3);
        expect(friend.avatarUrlAbsolute, isNotNull);
      },
    );

    test('displayName cae a username si no hay name', () {
      final friend = FriendUserResponse.fromJson({
        'id': 8,
        'username': 'soloUsername',
      });
      expect(friend.displayName, 'soloUsername');
    });
  });
}
