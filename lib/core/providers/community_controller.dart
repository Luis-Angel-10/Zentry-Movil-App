import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Zentry/core/models/app_user.dart';
import 'package:Zentry/core/models/backend/community_response.dart';
import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/network/api_exception.dart';
import 'package:Zentry/core/network/communities_api.dart';
import 'package:Zentry/core/providers/notifications_controller.dart';

class CommunityController extends ChangeNotifier {
  static const _communitiesKey = 'communities_data';
  static const _membersKey = 'community_members_data';
  static const _requestsKey = 'community_join_requests_data';

  NotificationsController? notifications;
  final CommunitiesApi _api = CommunitiesApi.instance;

  // ══════════════════════════════════════════════════════════════════════
  //  COMUNIDADES REALES DEL BACKEND (`/api/core/communities`) — Fase 2
  //
  //  Fuente de verdad para cualquier comunidad creada/consultada desde esta
  //  fase en adelante: sobrevive cierre de app, reinstalación y cambio de
  //  dispositivo porque vive en Postgres, no en SharedPreferences.
  //
  //  `communities`/`memberships`/`joinRequests` de abajo (el sistema local
  //  original, con privacidad/moderadores/aprobación de ingreso — conceptos
  //  que el backend NO tiene) se conserva sin borrar por si queda algún dato
  //  de sesiones anteriores, pero ninguna pantalla nueva lo alimenta ya.
  // ══════════════════════════════════════════════════════════════════════
  final List<CommunityResponse> backendCommunities = [];
  bool communitiesLoading = false;
  String? communitiesError;
  bool communitiesLoaded = false;

  CommunityResponse? selectedCommunity;
  bool selectedCommunityLoading = false;
  String? selectedCommunityError;

  final Set<String> _joinInFlight = {};

  Future<void> loadBackendCommunities({String? search}) async {
    communitiesLoading = true;
    communitiesError = null;
    notifyListeners();
    try {
      final result = await _api.getCommunities(search: search, size: 50);
      backendCommunities
        ..clear()
        ..addAll(result.items);
      communitiesLoaded = true;
      for (final c in result.items) {
        _communityNameCache[c.id] = c.nombre;
      }
    } on ApiException catch (e) {
      communitiesError = e.message;
    } finally {
      communitiesLoading = false;
      notifyListeners();
    }
  }

  /// Comunidades a las que el usuario autenticado REALMENTE pertenece.
  ///
  /// CORRECCIÓN: la pestaña "Comunidades" del perfil mostraba
  /// "Aún no perteneces a ninguna comunidad" incluso cuando el usuario sí
  /// era miembro, porque leía de `myCommunities()` (sistema local legado de
  /// abajo, que ninguna pantalla nueva alimenta — ver su doc-comment). El
  /// backend no tiene un endpoint dedicado "mis comunidades"
  /// (confirmado por lectura de `CommunityController.java`): `GET
  /// /api/core/communities` devuelve TODAS las comunidades con `isJoined`
  /// calculado por-usuario, así que "las mías" se obtiene filtrando esa
  /// misma lista ya cargada — sin inventar ni duplicar un endpoint nuevo.
  ///
  /// LIMITACIÓN documentada: si hay más de 50 comunidades en total (tamaño
  /// de página usado en `loadBackendCommunities`), una comunidad unida que
  /// quedó fuera de esa página no aparecería aquí — el backend no expone
  /// paginación completa "sólo las mías" para evitarlo. No aplica con el
  /// volumen de datos actual.
  List<CommunityResponse> get backendMyCommunities =>
      backendCommunities.where((c) => c.isJoined).toList();

  final Map<int, String> _communityNameCache = {};

  /// Nombre de una comunidad por id, para mostrar "publicó en `<comunidad>`"
  /// en el feed. `PostResponse.communityId` es sólo el id numérico (el
  /// backend NO incluye `communityName` en ese DTO — confirmado por
  /// lectura de `PostResponse.java`), así que Flutter debe resolverlo por
  /// separado. Se cachea porque el mismo id se repite en muchos posts.
  String? communityNameFor(int id) => _communityNameCache[id];

  final Set<int> _communityNameLookupInFlight = {};

  /// Resuelve y cachea el nombre de una comunidad si todavía no se conoce
  /// (p. ej. porque no estaba entre las primeras 50 de
  /// `loadBackendCommunities`). Notifica una sola vez al terminar.
  Future<void> ensureCommunityName(int id) async {
    if (_communityNameCache.containsKey(id) ||
        _communityNameLookupInFlight.contains(id)) {
      return;
    }
    _communityNameLookupInFlight.add(id);
    try {
      final community = await _api.getCommunity(id.toString());
      _communityNameCache[id] = community.nombre;
      notifyListeners();
    } on ApiException {
      // Sin nombre disponible: el feed simplemente no muestra la línea de
      // comunidad para este post en vez de inventar un nombre.
    } finally {
      _communityNameLookupInFlight.remove(id);
    }
  }

  Future<void> loadCommunityDetail(String identifier) async {
    selectedCommunityLoading = true;
    selectedCommunityError = null;
    selectedCommunity = null;
    notifyListeners();
    try {
      selectedCommunity = await _api.getCommunity(identifier);
    } on ApiException catch (e) {
      selectedCommunityError = e.message;
    } finally {
      selectedCommunityLoading = false;
      notifyListeners();
    }
  }

  /// Crea una comunidad real. Si hay imágenes locales, hace un segundo
  /// llamado (`updateCommunity` multipart) para subir avatar/banner —
  /// el backend no acepta ambas cosas en la misma llamada de creación.
  Future<CommunityResponse> createBackendCommunity({
    required String nombre,
    String? descripcion,
    String? categoria,
    List<String> rules = const [],
    String? avatarPath,
    String? bannerPath,
  }) async {
    var created = await _api.createCommunity(
      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria,
      rules: rules,
    );

    if ((avatarPath != null && avatarPath.isNotEmpty) ||
        (bannerPath != null && bannerPath.isNotEmpty)) {
      try {
        created = await _api.updateCommunity(
          created.identifier,
          avatarPath: avatarPath,
          bannerPath: bannerPath,
        );
      } on ApiException {
        // La comunidad ya existe en el servidor; si sólo falla la subida de
        // imagen no se pierde la creación, se conserva sin avatar/banner.
      }
    }

    backendCommunities.insert(0, created);
    notifyListeners();
    return created;
  }

  /// Une/desune al usuario actual de forma optimista, reconciliando siempre
  /// con la respuesta real del backend (nunca confía sólo en Flutter).
  Future<String?> toggleJoinBackend(CommunityResponse community) async {
    final identifier = community.identifier;
    if (_joinInFlight.contains(identifier)) return null;
    _joinInFlight.add(identifier);

    final wasJoined = community.isJoined;
    final optimistic = community.copyWith(
      isJoined: !wasJoined,
      membersCount: wasJoined
          ? (community.membersCount - 1).clamp(0, 1 << 31)
          : community.membersCount + 1,
    );
    _applyCommunityUpdate(optimistic);
    notifyListeners();

    try {
      final result = wasJoined
          ? await _api.leaveCommunity(identifier)
          : await _api.joinCommunity(identifier);
      _applyCommunityUpdate(result);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _applyCommunityUpdate(community);
      notifyListeners();
      return e.message;
    } finally {
      _joinInFlight.remove(identifier);
    }
  }

  void _applyCommunityUpdate(CommunityResponse updated) {
    final i = backendCommunities.indexWhere((c) => c.id == updated.id);
    if (i != -1) backendCommunities[i] = updated;
    if (selectedCommunity?.id == updated.id) selectedCommunity = updated;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  SISTEMA LOCAL LEGADO (privacidad/moderadores/solicitudes de ingreso)
  //  Ver doc-comment de arriba: no lo alimenta ninguna pantalla nueva.
  // ══════════════════════════════════════════════════════════════════════

  final List<Community> communities = [];
  final List<CommunityMember> memberships = [];
  final List<CommunityJoinRequest> joinRequests = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final rawCommunities = prefs.getString(_communitiesKey);
    if (rawCommunities != null) {
      try {
        final decoded = jsonDecode(rawCommunities) as List<dynamic>;
        communities
          ..clear()
          ..addAll(
            decoded.map((e) => Community.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {}
    }

    final rawMembers = prefs.getString(_membersKey);
    if (rawMembers != null) {
      try {
        final decoded = jsonDecode(rawMembers) as List<dynamic>;
        memberships
          ..clear()
          ..addAll(
            decoded.map(
              (e) => CommunityMember.fromJson(e as Map<String, dynamic>),
            ),
          );
      } catch (_) {}
    }

    final rawRequests = prefs.getString(_requestsKey);
    if (rawRequests != null) {
      try {
        final decoded = jsonDecode(rawRequests) as List<dynamic>;
        joinRequests
          ..clear()
          ..addAll(
            decoded.map(
              (e) => CommunityJoinRequest.fromJson(e as Map<String, dynamic>),
            ),
          );
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _communitiesKey,
      jsonEncode(communities.map((c) => c.toJson()).toList()),
    );
    await prefs.setString(
      _membersKey,
      jsonEncode(memberships.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(
      _requestsKey,
      jsonEncode(joinRequests.map((r) => r.toJson()).toList()),
    );
  }

  List<CommunityMember> membersOf(String communityId) {
    final members = memberships
        .where((m) => m.communityId == communityId)
        .toList();
    members.sort((a, b) => a.role.index.compareTo(b.role.index));
    return members;
  }

  int memberCount(String communityId) =>
      memberships.where((m) => m.communityId == communityId).length;

  CommunityRole? roleOf(String communityId, int userId) {
    for (final m in memberships) {
      if (m.communityId == communityId && m.userId == userId) return m.role;
    }
    return null;
  }

  bool isMember(String communityId, int userId) =>
      roleOf(communityId, userId) != null;

  List<Community> myCommunities(int userId) {
    final ids = memberships
        .where((m) => m.userId == userId)
        .map((m) => m.communityId)
        .toSet();
    return communities.where((c) => ids.contains(c.id)).toList();
  }

  List<CommunityJoinRequest> pendingRequestsFor(String communityId) =>
      joinRequests
          .where(
            (r) =>
                r.communityId == communityId &&
                r.status == JoinRequestStatus.pending,
          )
          .toList();

  bool hasPendingRequest(String communityId, int userId) {
    return joinRequests.any(
      (r) =>
          r.communityId == communityId &&
          r.userId == userId &&
          r.status == JoinRequestStatus.pending,
    );
  }

  Future<Community> createCommunity({
    required AppUser creator,
    required String name,
    required String description,
    required String categoryName,
    required CommunityPrivacy privacy,
    String? subcategoryName,
    String? iconPath,
    String? coverPath,
    String rules = '',
    List<String> hashtags = const [],
  }) async {
    final community = Community(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      description: description.trim(),
      categoryName: categoryName,
      subcategoryName: (subcategoryName ?? '').trim().isEmpty
          ? null
          : subcategoryName!.trim(),
      creatorId: creator.id,
      creatorName: creator.displayName,
      privacy: privacy,
      iconPath: iconPath,
      coverPath: coverPath,
      rules: rules.trim(),
      hashtags: hashtags,
      createdAt: DateTime.now(),
    );

    communities.insert(0, community);
    memberships.add(
      CommunityMember(
        communityId: community.id,
        userId: creator.id,
        userName: creator.displayName,
        username: creator.username,
        photoPath: creator.photoPath,
        role: CommunityRole.owner,
        joinedAt: DateTime.now(),
      ),
    );

    notifyListeners();
    await _persist();
    return community;
  }

  Future<bool> joinOrRequest(Community community, AppUser user) async {
    if (isMember(community.id, user.id)) return true;

    if (community.privacy == CommunityPrivacy.public) {
      memberships.add(
        CommunityMember(
          communityId: community.id,
          userId: user.id,
          userName: user.displayName,
          username: user.username,
          photoPath: user.photoPath,
          role: CommunityRole.member,
          joinedAt: DateTime.now(),
        ),
      );
      notifyListeners();
      await _persist();
      return true;
    }

    if (hasPendingRequest(community.id, user.id)) return false;

    joinRequests.insert(
      0,
      CommunityJoinRequest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        communityId: community.id,
        userId: user.id,
        userName: user.displayName,
        username: user.username,
        photoPath: user.photoPath,
        status: JoinRequestStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _persist();

    notifications?.push(AppNotificationType.communityJoinRequest, {
      'actorName': user.displayName,
      'communityId': community.id,
      'communityName': community.name,
    });

    return false;
  }

  Future<void> approveRequest(CommunityJoinRequest request) async {
    final index = joinRequests.indexWhere((r) => r.id == request.id);
    if (index == -1) return;

    joinRequests[index] = joinRequests[index].copyWith(
      status: JoinRequestStatus.approved,
    );

    if (!isMember(request.communityId, request.userId)) {
      memberships.add(
        CommunityMember(
          communityId: request.communityId,
          userId: request.userId,
          userName: request.userName,
          username: request.username,
          photoPath: request.photoPath,
          role: CommunityRole.member,
          joinedAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
    await _persist();

    final community = communities.where((c) => c.id == request.communityId);
    notifications?.push(AppNotificationType.communityRequestApproved, {
      'communityId': request.communityId,
      'communityName': community.isEmpty ? '' : community.first.name,
    });
  }

  Future<void> rejectRequest(CommunityJoinRequest request) async {
    final index = joinRequests.indexWhere((r) => r.id == request.id);
    if (index == -1) return;

    joinRequests[index] = joinRequests[index].copyWith(
      status: JoinRequestStatus.rejected,
    );
    notifyListeners();
    await _persist();

    final community = communities.where((c) => c.id == request.communityId);
    notifications?.push(AppNotificationType.communityRequestRejected, {
      'communityId': request.communityId,
      'communityName': community.isEmpty ? '' : community.first.name,
    });
  }

  Future<bool> leaveCommunity(String communityId, int userId) async {
    if (roleOf(communityId, userId) == CommunityRole.owner) return false;

    memberships.removeWhere(
      (m) => m.communityId == communityId && m.userId == userId,
    );
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> setRole(
    String communityId,
    int userId,
    CommunityRole role,
  ) async {
    final index = memberships.indexWhere(
      (m) => m.communityId == communityId && m.userId == userId,
    );
    if (index == -1) return;

    memberships[index] = memberships[index].copyWith(role: role);
    notifyListeners();
    await _persist();
  }

  Future<void> removeMember(String communityId, int userId) async {
    memberships.removeWhere(
      (m) => m.communityId == communityId && m.userId == userId,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> deleteCommunity(String communityId) async {
    communities.removeWhere((c) => c.id == communityId);
    memberships.removeWhere((m) => m.communityId == communityId);
    joinRequests.removeWhere((r) => r.communityId == communityId);
    notifyListeners();
    await _persist();
  }

  Future<void> updateCommunity(Community updated) async {
    final index = communities.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;

    communities[index] = updated;
    notifyListeners();
    await _persist();
  }
}
