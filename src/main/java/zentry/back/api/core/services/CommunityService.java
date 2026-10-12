package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import zentry.back.api.core.models.User;
import zentry.back.api.core.dtos.CommunityRequest;
import zentry.back.api.core.dtos.CommunityResponse;
import zentry.back.api.core.dtos.PostRequest;
import zentry.back.api.core.dtos.PostResponse;
import zentry.back.api.core.models.Community;
import zentry.back.api.core.models.CommunityMember;
import zentry.back.api.core.repositories.CommunityMemberRepository;
import zentry.back.api.core.repositories.CommunityRepository;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.mappers.CoreMappers;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.*;

@Service
@SuppressWarnings("null")
public class CommunityService {

    private final CommunityRepository repo;
    private final CommunityMemberRepository memberRepo;
    private final UserRepository userRepo;
    private final PostService postService;
    private final GamificationEventService gamificationEventService;

    public CommunityService(CommunityRepository repo, CommunityMemberRepository memberRepo, UserRepository userRepo,
                             PostService postService, GamificationEventService gamificationEventService) {
        this.repo = repo;
        this.memberRepo = memberRepo;
        this.userRepo = userRepo;
        this.postService = postService;
        this.gamificationEventService = gamificationEventService;
    }

    public Page<CommunityResponse> list(String search, Pageable pageable, String currentUserEmail) {
        Page<Community> page;
        if (search != null && !search.isBlank()) {
            page = repo.findSearch(search.trim(), pageable);
        } else {
            page = repo.findAll(pageable);
        }

        User currentUser = currentUserEmail != null ? userRepo.findByEmail(currentUserEmail).orElse(null) : null;
        return page.map(c -> enrichResponse(c, currentUser));
    }

    public CommunityResponse getById(Integer id) {
        Community entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Comunidad no encontrada"));
        return enrichResponse(entity, null);
    }

    public CommunityResponse getByIdentifier(String identifier, String currentUserEmail) {
        if (identifier == null || identifier.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Identificador de comunidad vacío");
        }
        Community entity = findEntityByIdentifier(identifier);
        User currentUser = currentUserEmail != null ? userRepo.findByEmail(currentUserEmail).orElse(null) : null;
        return enrichResponse(entity, currentUser);
    }

    public CommunityResponse create(String userEmail, CommunityRequest request) {
        User creator = userRepo.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        String slug = request.getSlug();
        if (slug == null || slug.isBlank()) {
            slug = generateSlug(request.getNombre());
        }

        Community entity = Community.builder()
                .nombre(request.getNombre())
                .slug(slug)
                .descripcion(request.getDescripcion())
                .categoria(request.getCategoria())
                .avatarUrl(request.getAvatarUrl())
                .bannerUrl(request.getBannerUrl())
                .imageUrl(request.getAvatarUrl() != null ? request.getAvatarUrl() : request.getBannerUrl())
                .rules(request.getRules() != null ? request.getRules() : new ArrayList<>())
                .creatorId(creator.getId())
                .ownerUsername(creator.getHandle())
                .build();
        
        Community savedCommunity = repo.save(entity);

        CommunityMember founder = CommunityMember.builder()
                .communityId(savedCommunity.getId())
                .userId(creator.getId())
                .role("ADMIN")
                .joinedAt(LocalDateTime.now())
                .build();
        
        memberRepo.save(founder);
        return enrichResponse(savedCommunity, creator);
    }

    public CommunityResponse updateConfig(String identifier, String userEmail, CommunityRequest request, MultipartFile avatar, MultipartFile banner) {
        User user = userRepo.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        Community entity = findEntityByIdentifier(identifier);

        boolean isOwner = (entity.getOwnerUsername() != null && (entity.getOwnerUsername().equalsIgnoreCase(user.getHandle()) || entity.getOwnerUsername().equalsIgnoreCase(user.getEmail())))
                || (entity.getCreatorId() != null && entity.getCreatorId().equals(user.getId()));

        if (!isOwner) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos de administrador para modificar esta comunidad");
        }

        if (request != null) {
            if (request.getNombre() != null && !request.getNombre().isBlank()) {
                entity.setNombre(request.getNombre());
            }
            if (request.getDescripcion() != null) {
                entity.setDescripcion(request.getDescripcion());
            }
            if (request.getRules() != null) {
                entity.setRules(request.getRules());
            }
            if (request.getAvatarUrl() != null) {
                entity.setAvatarUrl(request.getAvatarUrl());
            }
            if (request.getBannerUrl() != null) {
                entity.setBannerUrl(request.getBannerUrl());
            }
        }

        if (avatar != null && !avatar.isEmpty()) {
            String avatarFilename = saveImage(avatar, entity.getSlug(), "avatar");
            entity.setAvatarUrl("/uploads/communities/" + avatarFilename);
            entity.setImageUrl("/uploads/communities/" + avatarFilename);
        }

        if (banner != null && !banner.isEmpty()) {
            String bannerFilename = saveImage(banner, entity.getSlug(), "banner");
            entity.setBannerUrl("/uploads/communities/" + bannerFilename);
        }

        Community saved = repo.save(entity);
        return enrichResponse(saved, user);
    }

    public CommunityResponse joinCommunity(String identifier, String userEmail) {
        User user = userRepo.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        Community community = findEntityByIdentifier(identifier);

        boolean alreadyMember = memberRepo.existsByCommunityIdAndUserId(community.getId(), user.getId());
        if (!alreadyMember) {
            CommunityMember member = CommunityMember.builder()
                    .communityId(community.getId())
                    .userId(user.getId())
                    .role("MEMBER")
                    .joinedAt(LocalDateTime.now())
                    .build();
            memberRepo.save(member);

            gamificationEventService.recordMissionProgress(user.getId(), "visit_community", 1);
            gamificationEventService.recordAchievementProgress(user.getId(), "join_communities", 1);
        }

        return enrichResponse(community, user);
    }

    public CommunityResponse leaveCommunity(String identifier, String userEmail) {
        User user = userRepo.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        Community community = findEntityByIdentifier(identifier);

        Optional<CommunityMember> memberOpt = memberRepo.findByCommunityIdAndUserId(community.getId(), user.getId());
        memberOpt.ifPresent(memberRepo::delete);

        return enrichResponse(community, user);
    }

    public PostResponse createPostInCommunity(String identifier, String userEmail, PostRequest request) {
        Community community = findEntityByIdentifier(identifier);
        return postService.create(userEmail, request, community.getId());
    }

    public org.springframework.data.domain.Page<PostResponse> getCommunityPosts(String identifier, org.springframework.data.domain.Pageable pageable, String viewerEmail) {
        Community community = findEntityByIdentifier(identifier);
        return postService.getPostsByCommunity(community.getId(), pageable, viewerEmail);
    }

    public Map<String, Object> toggleNotifications(String identifier, String userEmail) {
        User user = userRepo.findByEmail(userEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
        Community community = findEntityByIdentifier(identifier);

        CommunityMember member = memberRepo.findByCommunityIdAndUserId(community.getId(), user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Debes ser miembro de la comunidad para gestionar sus notificaciones"));

        boolean nextValue = !Boolean.TRUE.equals(member.getNotificationsEnabled());
        member.setNotificationsEnabled(nextValue);
        memberRepo.save(member);

        Map<String, Object> response = new HashMap<>();
        response.put("communityId", community.getId());
        response.put("notificationsEnabled", nextValue);
        response.put("message", nextValue ? "Notificaciones activadas" : "Notificaciones desactivadas");
        return response;
    }

    public void delete(Integer id) {
        Community entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Comunidad no encontrada"));
        repo.delete(entity);
    }

    private CommunityResponse enrichResponse(Community community, User currentUser) {
        CommunityResponse response = CoreMappers.toResponse(community);

        Integer membersCount = memberRepo.countByCommunityId(community.getId());
        response.setMembersCount(membersCount != null ? membersCount : 0);

        if (currentUser != null) {
            boolean isJoined = memberRepo.existsByCommunityIdAndUserId(community.getId(), currentUser.getId());
            response.setIsJoined(isJoined);
        } else {
            response.setIsJoined(false);
        }

        return response;
    }

    private Community findEntityByIdentifier(String identifier) {
        try {
            Integer id = Integer.parseInt(identifier);
            Optional<Community> opt = repo.findById(id);
            if (opt.isPresent()) return opt.get();
        } catch (NumberFormatException ignored) {}

        String normalized = identifier.replace("-", " ");
        List<Community> matches = repo.findAllBySlugOrNombreMatch(identifier);
        if (!matches.isEmpty()) return matches.get(0);
        return repo.findByNombreIgnoreCase(normalized)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Comunidad no encontrada: " + identifier));
    }

    private String generateSlug(String text) {
        if (text == null || text.isBlank()) return UUID.randomUUID().toString().substring(0, 8);
        String normalized = java.text.Normalizer.normalize(text, java.text.Normalizer.Form.NFD);
        String slug = normalized.replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .toLowerCase()
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                .trim();
        return slug.isEmpty() ? UUID.randomUUID().toString().substring(0, 8) : slug;
    }

    private String saveImage(MultipartFile file, String identifier, String type) {
        try {
            Path uploadPath = Paths.get("uploads/communities");
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".jpg";
            String newFilename = identifier + "_" + type + "_" + UUID.randomUUID().toString().substring(0, 5) + extension;

            Path filePath = uploadPath.resolve(newFilename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            return newFilename;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error al guardar imagen de comunidad", e);
        }
    }
}
