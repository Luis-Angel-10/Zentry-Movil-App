package zentry.back.api.core.services;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.FriendUserResponse;
import zentry.back.api.core.dtos.SendFriendRequestDTO;
import zentry.back.api.core.dtos.UserStatsResponse;
import zentry.back.api.core.models.FriendRequest;
import zentry.back.api.core.models.Friendship;
import zentry.back.api.core.models.Profile;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.FollowRepository;
import zentry.back.api.core.repositories.FriendRequestRepository;
import zentry.back.api.core.repositories.FriendshipRepository;
import zentry.back.api.core.repositories.PostRepository;
import zentry.back.api.core.repositories.ProfileRepository;
import zentry.back.api.core.repositories.UserRepository;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@SuppressWarnings("null")
public class FriendsService {

    private final UserRepository userRepo;
    private final ProfileRepository profileRepo;
    private final FriendRequestRepository friendRequestRepo;
    private final FriendshipRepository friendshipRepo;

    private final PostRepository postRepo;
    private final FollowRepository followRepo;
    private final WalletService walletService;
    private final NotificationService notificationService;

    public FriendsService(
            UserRepository userRepo,
            ProfileRepository profileRepo,
            FriendRequestRepository friendRequestRepo,
            FriendshipRepository friendshipRepo,

            PostRepository postRepo,
            FollowRepository followRepo,
            WalletService walletService,
            NotificationService notificationService) {
        this.userRepo = userRepo;
        this.profileRepo = profileRepo;
        this.friendRequestRepo = friendRequestRepo;
        this.friendshipRepo = friendshipRepo;
        this.walletService = walletService;
        this.notificationService = notificationService;

        this.postRepo = postRepo;
        this.followRepo = followRepo;
    }

    private User resolveUser(String identifier) {
        if (identifier == null || identifier.isBlank() || "anonimo".equalsIgnoreCase(identifier)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado");
        }
        var byEmail = userRepo.findByEmail(identifier);
        if (byEmail.isPresent()) return byEmail.get();

        var byUsername = userRepo.findByUsername(identifier);
        if (byUsername.isPresent()) return byUsername.get();

        var byBoth = userRepo.findByUsernameOrEmail(identifier, identifier);
        if (byBoth.isPresent()) return byBoth.get();

        var byEmailPrefix = userRepo.findByEmailStartingWith(identifier + "@");
        if (byEmailPrefix.isPresent()) return byEmailPrefix.get();

        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
    }

    public List<FriendUserResponse> getPendingRequests(String identifier) {
        User currentUser = resolveUser(identifier);
        List<FriendRequest> requests = friendRequestRepo.findByUser2(currentUser.getId());

        return requests.stream().map(req -> {
            User sender = userRepo.findById(req.getUser1()).orElse(null);
            if (sender == null || sender.getId().equals(currentUser.getId())) return null;

            Profile profile = profileRepo.findByUserId(sender.getId()).orElse(new Profile());
            boolean isOnline = isUserOnline(sender.getId());

            return FriendUserResponse.builder()
                    .id(sender.getId())
                    .requestId(req.getId())
                    .username(sender.getHandle())
                    .name(profile.getName() != null ? profile.getName() : sender.getHandle())
                    .avatarUrl(profile.getAvatarUrl())
                    .discipline(profile.getDiscipline() != null ? profile.getDiscipline() : "Creador Digital")
                    .bio(profile.getBio())
                    .isOnline(isOnline)
                    .status(isOnline ? "online" : "offline")
                    .projectTitle("Solicitud de Amistad")
                    .build();
        }).filter(Objects::nonNull).collect(Collectors.toList());
    }

    public List<FriendUserResponse> getSentRequests(String identifier) {
        User currentUser = resolveUser(identifier);
        List<FriendRequest> requests = friendRequestRepo.findByUser1(currentUser.getId());

        return requests.stream().map(req -> {
            User target = userRepo.findById(req.getUser2()).orElse(null);
            if (target == null) return null;

            Profile profile = profileRepo.findByUserId(target.getId()).orElse(new Profile());

            return FriendUserResponse.builder()
                    .id(target.getId())
                    .requestId(req.getId())
                    .username(target.getHandle())
                    .name(profile.getName() != null ? profile.getName() : target.getHandle())
                    .avatarUrl(profile.getAvatarUrl())
                    .discipline(profile.getDiscipline() != null ? profile.getDiscipline() : "Creador Digital")
                    .status("pending")
                    .projectTitle("Solicitud enviada")
                    .build();
        }).filter(Objects::nonNull).collect(Collectors.toList());
    }

    public Map<String, Object> sendRequest(String identifier, SendFriendRequestDTO dto) {
        User sender = resolveUser(identifier);
        User target;

        if (dto.getTargetUserId() != null) {
            target = userRepo.findById(dto.getTargetUserId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario destino no encontrado"));
        } else if (dto.getTargetUsername() != null && !dto.getTargetUsername().isBlank()) {
            target = resolveUser(dto.getTargetUsername());
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Se requiere target_user_id o target_username");
        }

        if (sender.getId().equals(target.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No puedes enviarte una solicitud a ti mismo");
        }

        if (friendshipRepo.existsByUser1AndUser2(sender.getId(), target.getId()) ||
            friendshipRepo.existsByUser1AndUser2(target.getId(), sender.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Ya son amigos en la red");
        }

        if (friendRequestRepo.existsByUser1AndUser2(sender.getId(), target.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Ya has enviado una solicitud a este usuario");
        }

        if (friendRequestRepo.existsByUser1AndUser2(target.getId(), sender.getId())) {
            // El otro usuario ya le habia enviado solicitud -> Aceptar automaticamente
            FriendRequest existing = friendRequestRepo.findByUser1AndUser2(target.getId(), sender.getId()).orElse(null);
            if (existing != null) {
                return acceptRequest(existing.getId(), identifier);
            }
        }

        FriendRequest req = FriendRequest.builder()
                .user1(sender.getId())
                .user2(target.getId())
                .build();
        FriendRequest saved = friendRequestRepo.save(req);

        Profile senderProfile = profileRepo.findByUserId(sender.getId()).orElse(null);
        notificationService.notify(
                target.getId(),
                "friend_request",
                "@" + sender.getHandle() + " te envió una solicitud de amistad",
                sender.getHandle(),
                senderProfile != null ? senderProfile.getAvatarUrl() : null,
                saved.getId()
        );

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "Solicitud de amistad enviada con éxito");
        result.put("requestId", saved.getId());
        return result;
    }

    public Map<String, Object> acceptRequest(Integer requestId, String identifier) {
        User currentUser = resolveUser(identifier);

        FriendRequest req = friendRequestRepo.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Solicitud no encontrada"));

        if (!req.getUser2().equals(currentUser.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permiso para aceptar esta solicitud");
        }

        Integer friendId = req.getUser1();

        // Crear amistad bidireccional si no existe
        if (!friendshipRepo.existsByUser1AndUser2(currentUser.getId(), friendId)) {
            friendshipRepo.save(Friendship.builder().user1(currentUser.getId()).user2(friendId).build());
        }
        if (!friendshipRepo.existsByUser1AndUser2(friendId, currentUser.getId())) {
            friendshipRepo.save(Friendship.builder().user1(friendId).user2(currentUser.getId()).build());
        }

        // Eliminar solicitud y cualquier solicitud inversa pendiente
        friendRequestRepo.delete(req);
        friendRequestRepo.deleteByUser1AndUser2(friendId, currentUser.getId());
        friendRequestRepo.deleteByUser1AndUser2(currentUser.getId(), friendId);

        Profile accepterProfile = profileRepo.findByUserId(currentUser.getId()).orElse(null);
        notificationService.notify(
                friendId,
                "friend_accept",
                "@" + currentUser.getHandle() + " aceptó tu solicitud de amistad",
                currentUser.getHandle(),
                accepterProfile != null ? accepterProfile.getAvatarUrl() : null,
                currentUser.getId()
        );

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "¡Ahora son amigos!");
        return result;
    }

    public Map<String, Object> rejectRequest(Integer requestId, String identifier) {
        User currentUser = resolveUser(identifier);

        FriendRequest req = friendRequestRepo.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Solicitud no encontrada"));

        if (!req.getUser2().equals(currentUser.getId()) && !req.getUser1().equals(currentUser.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permiso para modificar esta solicitud");
        }

        Integer otherUserId = req.getUser1().equals(currentUser.getId()) ? req.getUser2() : req.getUser1();

        friendRequestRepo.delete(req);
        friendRequestRepo.deleteByUser1AndUser2(currentUser.getId(), otherUserId);
        friendRequestRepo.deleteByUser1AndUser2(otherUserId, currentUser.getId());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "Solicitud eliminada");
        return result;
    }

    public List<FriendUserResponse> getFriends(String identifier, boolean onlineOnly) {
        User currentUser = resolveUser(identifier);

        List<Friendship> friendships = friendshipRepo.findAllFriendshipsForUser(currentUser.getId());
        Set<Integer> friendIds = new HashSet<>();
        for (Friendship f : friendships) {
            if (f.getUser1().equals(currentUser.getId()) && !f.getUser2().equals(currentUser.getId())) {
                friendIds.add(f.getUser2());
            } else if (f.getUser2().equals(currentUser.getId()) && !f.getUser1().equals(currentUser.getId())) {
                friendIds.add(f.getUser1());
            }
        }

        // Si pide SOLO amigos en línea:
        if (onlineOnly) {
            if (friendIds.isEmpty()) {
                return Collections.emptyList();
            }
            return friendIds.stream()
                    .filter(id -> !id.equals(currentUser.getId()))
                    .filter(this::isUserOnline)
                    .map(id -> userRepo.findById(id).orElse(null))
                    .filter(Objects::nonNull)
                    .map(u -> mapUserToFriendResponse(u, true))
                    .collect(Collectors.toList());
        }

        // Lista general de amigos:
        if (friendIds.isEmpty()) {
            return userRepo.findAll().stream()
                    .filter(u -> !u.getId().equals(currentUser.getId()))
                    .filter(u -> !isSeedAdmin(u))
                    .limit(6)
                    .map(u -> mapUserToFriendResponse(u, false))
                    .collect(Collectors.toList());
        }

        return friendIds.stream()
                .filter(id -> !id.equals(currentUser.getId()))
                .map(id -> userRepo.findById(id).orElse(null))
                .filter(Objects::nonNull)
                .map(u -> mapUserToFriendResponse(u, true))
                .collect(Collectors.toList());
    }

    /**
     * "Personas que quizás conozcas": usuarios reales que aún no son amigos y con los
     * que no hay ninguna solicitud pendiente en ningún sentido.
     */
    public List<FriendUserResponse> getSuggestions(String identifier, int limit) {
        User currentUser = resolveUser(identifier);

        Set<Integer> excluded = new HashSet<>();
        excluded.add(currentUser.getId());

        for (Friendship f : friendshipRepo.findAllFriendshipsForUser(currentUser.getId())) {
            excluded.add(f.getUser1());
            excluded.add(f.getUser2());
        }
        for (FriendRequest r : friendRequestRepo.findByUser1(currentUser.getId())) {
            excluded.add(r.getUser2());
        }
        for (FriendRequest r : friendRequestRepo.findByUser2(currentUser.getId())) {
            excluded.add(r.getUser1());
        }

        return userRepo.findAll().stream()
                .filter(u -> !excluded.contains(u.getId()))
                .filter(u -> !isSeedAdmin(u))
                .limit(limit)
                .map(u -> mapUserToFriendResponse(u, false))
                .collect(Collectors.toList());
    }

    private boolean isSeedAdmin(User user) {
        return user != null && "admin@zentry.com".equalsIgnoreCase(user.getEmail());
    }

    public Map<String, Object> removeFriend(Integer friendId, String identifier) {
        User currentUser = resolveUser(identifier);

        friendshipRepo.deleteByUser1AndUser2(currentUser.getId(), friendId);
        friendshipRepo.deleteByUser1AndUser2(friendId, currentUser.getId());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "Amigo eliminado de la red");
        return result;
    }

    private static final java.util.concurrent.ConcurrentHashMap<Integer, Long> ACTIVE_PRESENCE = new java.util.concurrent.ConcurrentHashMap<>();

    public Map<String, Object> updatePresence(String identifier, String status) {
        User user = resolveUser(identifier);
        String finalStatus = (status != null && !status.isBlank()) ? status : "online";

        if ("offline".equalsIgnoreCase(finalStatus)) {
            ACTIVE_PRESENCE.remove(user.getId());
        } else {
            ACTIVE_PRESENCE.put(user.getId(), System.currentTimeMillis());
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("userId", user.getId());
        result.put("status", finalStatus);
        return result;
    }

    public UserStatsResponse getUserStats(String identifier) {
        User user = resolveUser(identifier);

        long postsCount = postRepo.countByUserId(user.getId());
        long followersCount = followRepo.countByFollowing(user.getId());
        long followingCount = followRepo.countByFollower(user.getId());
        long friendsCount = friendshipRepo.findAllFriendshipsForUser(user.getId()).size();

        long zentryCoins = walletService.getOrCreateWallet(user.getUsername()).getBalance().longValue();
        long coinsToday = Math.max(5, (postsCount * 5));
        long reputationScore = 50 + (postsCount * 10) + (followersCount * 5);
        zentry.back.api.core.util.RankUtil.RankInfo rankInfo = zentry.back.api.core.util.RankUtil.forScore(reputationScore);

        return UserStatsResponse.builder()
                .userId(user.getId())
                .username(user.getHandle())
                .postsCount(postsCount)
                .followersCount(followersCount)
                .followingCount(followingCount)
                .friendsCount(friendsCount)
                .zentryCoins(zentryCoins)
                .coinsToday(coinsToday)
                .reputationScore(reputationScore)
                .rank(rankInfo.name())
                .rankMinScore(rankInfo.minScore())
                .nextRankScore(rankInfo.nextThreshold())
                .build();
    }

    public boolean isUserOnline(Integer userId) {
        if (userId == null) return false;
        Long lastPing = ACTIVE_PRESENCE.get(userId);
        if (lastPing == null) return false;
        // Considerar online si se envió un ping en los últimos 45 segundos (45.000 ms)
        return (System.currentTimeMillis() - lastPing) < 45_000L;
    }

    private FriendUserResponse mapUserToFriendResponse(User user, boolean isFriend) {
        Profile profile = profileRepo.findByUserId(user.getId()).orElse(new Profile());
        boolean isOnline = isUserOnline(user.getId());

        return FriendUserResponse.builder()
                .id(user.getId())
                .username(user.getHandle())
                .name(profile.getName() != null ? profile.getName() : user.getHandle())
                .avatarUrl(profile.getAvatarUrl())
                .discipline(profile.getDiscipline() != null ? profile.getDiscipline() : "Creador Digital")
                .bio(profile.getBio())
                .isOnline(isOnline)
                .status(isOnline ? "online" : "offline")
                .projectTitle(isFriend ? "Conexión en Zentry" : "Sugerido para ti")
                .build();
    }
}
