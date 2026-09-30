// Tests de las integraciones nuevas de la Fase 2: Comunidades reales y
// Wallet/Zentry Coins. Igual que `network_fake_test.dart`, usan un
// HttpClientAdapter FALSO (sin red real, sin servidor levantado) para
// ejercitar el camino completo API -> ApiClient.guard -> parsing/estado.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Zentry/core/models/backend/community_response.dart';
import 'package:Zentry/core/models/backend/wallet_response.dart';
import 'package:Zentry/core/network/api_client.dart';
import 'package:Zentry/core/network/communities_api.dart';
import 'package:Zentry/core/network/wallet_api.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/wallet_controller.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(dynamic body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      'content-type': ['application/json; charset=utf-8'],
    },
  );
}

void main() {
  setUpAll(() {
    ApiClient.instance.init();
  });

  group('CommunityResponse.fromJson', () {
    test('parsea los campos reales, sin privacidad/hashtags (no existen)', () {
      final community = CommunityResponse.fromJson({
        'id': 3,
        'slug': 'arte-digital',
        'nombre': 'Arte Digital',
        'descripcion': 'Para creadores visuales',
        'categoria': 'Arte',
        'creatorId': 7,
        'ownerUsername': 'angelito',
        'rules': ['Sé respetuoso', 'No spam'],
        'membersCount': 128,
        'isJoined': true,
      });

      expect(community.identifier, 'arte-digital');
      expect(community.membersCount, 128);
      expect(community.isJoined, isTrue);
      expect(community.rules, ['Sé respetuoso', 'No spam']);
    });

    test('identifier cae al id numérico si no hay slug', () {
      final community = CommunityResponse.fromJson({'id': 9, 'nombre': 'X'});
      expect(community.identifier, '9');
      expect(community.isJoined, isFalse);
      expect(community.membersCount, 0);
    });
  });

  group('WalletResponse.fromJson', () {
    test('parsea saldo y movimientos con el enum de tipo real', () {
      final wallet = WalletResponse.fromJson({
        'id': 1,
        'username': 'angelito',
        'balance': 150,
        'transactions': [
          {
            'id': 1,
            'username': 'angelito',
            'type': 'INGRESO',
            'amount': 50,
            'description': 'Recompensa de logro',
            'createdAt': '2026-09-16T10:00:00',
          },
          {'id': 2, 'username': 'angelito', 'type': 'EGRESO', 'amount': 20},
        ],
      });

      expect(wallet.balanceLabel, '150');
      expect(wallet.transactions, hasLength(2));
      expect(wallet.transactions[0].type, WalletTransactionType.ingreso);
      expect(wallet.transactions[1].type, WalletTransactionType.egreso);
    });

    test(
      'balanceLabel muestra decimales sólo cuando no es un entero exacto',
      () {
        final wallet = WalletResponse.fromJson({
          'id': 1,
          'username': 'x',
          'balance': 12.5,
        });
        expect(wallet.balanceLabel, '12.50');
      },
    );
  });

  group('CommunitiesApi contra un backend falso', () {
    test('getCommunities parsea una página real', () async {
      ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
        expect(options.uri.path, endsWith('/api/core/communities'));
        return _json({
          'content': [
            {'id': 1, 'slug': 'a', 'nombre': 'A', 'membersCount': 5},
            {'id': 2, 'slug': 'b', 'nombre': 'B', 'membersCount': 2},
          ],
          'number': 0,
          'totalPages': 1,
          'totalElements': 2,
          'last': true,
        }, 200);
      });

      final result = await CommunitiesApi.instance.getCommunities();
      expect(result.items, hasLength(2));
      expect(result.last, isTrue);
    });

    test(
      'joinCommunity llama al endpoint real y devuelve el estado nuevo',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          expect(options.uri.path, endsWith('/api/core/communities/arte/join'));
          expect(options.method, 'POST');
          return _json({
            'id': 1,
            'slug': 'arte',
            'nombre': 'Arte',
            'isJoined': true,
            'membersCount': 11,
          }, 200);
        });

        final result = await CommunitiesApi.instance.joinCommunity('arte');
        expect(result.isJoined, isTrue);
        expect(result.membersCount, 11);
      },
    );
  });

  group('CommunityController.toggleJoinBackend', () {
    test(
      'revierte el estado optimista si el backend rechaza la solicitud',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          return _json({'message': 'No se pudo unir'}, 400);
        });

        final controller = CommunityController();
        const community = CommunityResponse(
          id: 1,
          slug: 'arte',
          nombre: 'Arte',
          isJoined: false,
          membersCount: 10,
        );
        controller.backendCommunities.add(community);

        final error = await controller.toggleJoinBackend(community);

        expect(error, isNotNull);
        // Reversión: sigue sin unirse y con el contador original.
        expect(controller.backendCommunities.first.isJoined, isFalse);
        expect(controller.backendCommunities.first.membersCount, 10);
      },
    );
  });

  group('WalletApi/WalletController', () {
    test('WalletApi.getWallet parsea el saldo real', () async {
      ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
        expect(options.uri.path, endsWith('/api/core/wallet'));
        return _json({'id': 1, 'username': 'x', 'balance': 300}, 200);
      });

      final wallet = await WalletApi.instance.getWallet();
      expect(wallet.balanceLabel, '300');
    });

    test(
      'WalletController.transfer devuelve el mensaje real del backend si falla (saldo insuficiente)',
      () async {
        ApiClient.instance.dio.httpClientAdapter = _FakeAdapter((options) {
          return _json({
            'message': 'Saldo insuficiente para realizar la transferencia',
          }, 400);
        });

        final controller = WalletController();
        final error = await controller.transfer(
          recipientUsername: 'otro',
          amount: 999,
        );
        expect(error, 'Saldo insuficiente para realizar la transferencia');
      },
    );

    test(
      'WalletController.transfer rechaza montos <= 0 sin llamar al backend',
      () async {
        final controller = WalletController();
        final error = await controller.transfer(
          recipientUsername: 'otro',
          amount: 0,
        );
        expect(error, isNotNull);
        expect(controller.isLoading, isFalse);
      },
    );
  });
}
