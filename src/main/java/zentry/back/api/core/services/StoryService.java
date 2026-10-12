package zentry.back.api.core.services;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import zentry.back.api.core.dtos.StoryGroupResponse;
import zentry.back.api.core.dtos.StoryReplyRequest;
import zentry.back.api.core.dtos.StoryRequest;
import zentry.back.api.core.dtos.StoryResponse;
import zentry.back.api.core.models.*;
import zentry.back.api.core.repositories.*;
import zentry.back.api.core.mappers.CoreMappers;
import zentry.back.api.realtime.dtos.MessageRequest;
import zentry.back.api.realtime.service.ConversationService;
import zentry.back.api.realtime.service.MessageService;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StoryService {

    private final StoryRepository storyRepo;
    private final StoryViewRepository storyViewRepo;
    private final StoryLikeRepository storyLikeRepo;
    private final UserRepository userRepo;
    private final ProfileRepository profileRepo;
    private final ConversationService conversationService;
    private final MessageService messageService;

    public StoryService(
            StoryRepository storyRepo,
            StoryViewRepository storyViewRepo,
            StoryLikeRepository storyLikeRepo,
            UserRepository userRepo,
            ProfileRepository profileRepo,
            ConversationService conversationService,
            MessageService messageService) {
        this.storyRepo = storyRepo;
        this.storyViewRepo = storyViewRepo;
        this.storyLikeRepo = storyLikeRepo;
        this.userRepo = userRepo;
        this.profileRepo = profileRepo;
        this.conversationService = conversationService;
        this.messageService = messageService;
    }

    @Transactional
    public StoryResponse createStory(StoryRequest request, MultipartFile file, Integer currentUserId) {
        if (currentUserId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado");
        }
        Integer targetUserId = currentUserId;

        String mediaUrl = request.getMediaUrl();
        String mediaType = request.getMediaType() != null ? request.getMediaType().toUpperCase() : "IMAGE";

        if (file != null && !file.isEmpty()) {
            mediaUrl = saveMediaFile(file);
            String contentType = file.getContentType();
            if (contentType != null && contentType.startsWith("video/")) {
                mediaType = "VIDEO";
            } else if (contentType != null && contentType.startsWith("image/")) {
                mediaType = "IMAGE";
            }
        }

        LocalDateTime now = LocalDateTime.now();
        Story story = Story.builder()
                .userId(targetUserId)
                .mediaUrl(mediaUrl)
                .mediaType(mediaType)
                .textContent(request.getTextContent())
                .textColor(request.getTextColor() != null ? request.getTextColor() : "#ffffff")
                .background(request.getBackground())
                .fontStyle(request.getFontStyle() != null ? request.getFontStyle() : "sans")
                .caption(request.getCaption())
                .musicTitle(request.getMusicTitle())
                .musicArtist(request.getMusicArtist())
                .musicUrl(request.getMusicUrl())
                .linkUrl(request.getLinkUrl())
                .duration(request.getDuration() != null ? request.getDuration() : 5000)
                .createdAt(now)
                .expiresAt(now.plusHours(24))
                .viewCount(0)
                .likesCount(0)
                .isArchived(false)
                .build();

        Story saved = storyRepo.save(story);
        StoryResponse response = CoreMappers.toResponse(saved);
        enrichStoryResponse(response, saved, currentUserId);
        return response;
    }

    @Transactional(readOnly = true)
    public List<StoryGroupResponse> getActiveFeed(Integer currentUserId) {
        LocalDateTime now = LocalDateTime.now();
        List<Story> activeStories = storyRepo.findByExpiresAtAfterAndIsArchivedFalseOrderByCreatedAtAsc(now);

        // Group stories by userId preserving order
        Map<Integer, List<Story>> storiesByUser = activeStories.stream()
                .collect(Collectors.groupingBy(Story::getUserId, LinkedHashMap::new, Collectors.toList()));

        List<StoryGroupResponse> groups = new ArrayList<>();
        boolean currentUserHasGroup = false;

        for (Map.Entry<Integer, List<Story>> entry : storiesByUser.entrySet()) {
            Integer userId = entry.getKey();
            List<Story> userStoryList = entry.getValue();

            User user = userRepo.findById(userId).orElse(null);
            Profile profile = profileRepo.findByUserId(userId).orElse(null);

            String rawUsername = user != null && user.getHandle() != null ? user.getHandle() : "usuario_" + userId;
            String cleanUsername = rawUsername.replaceFirst("@.*", "");
            String displayName = (profile != null && profile.getName() != null && !profile.getName().isBlank())
                    ? profile.getName()
                    : cleanUsername;
            String avatarUrl = profile != null ? profile.getAvatarUrl() : null;

            String initials = displayName.length() >= 2
                    ? displayName.substring(0, 2).toUpperCase()
                    : displayName.toUpperCase();

            boolean isCurrentUser = currentUserId != null && currentUserId.equals(userId);
            if (isCurrentUser) currentUserHasGroup = true;
            boolean hasUnseen = false;
            LocalDateTime lastUpdated = userStoryList.get(userStoryList.size() - 1).getCreatedAt();

            List<StoryResponse> storyResponses = new ArrayList<>();
            for (Story s : userStoryList) {
                StoryResponse dto = CoreMappers.toResponse(s);
                enrichStoryResponse(dto, s, currentUserId);
                if (dto.getIsViewed() != null && !dto.getIsViewed()) {
                    hasUnseen = true;
                }
                storyResponses.add(dto);
            }

            StoryGroupResponse group = StoryGroupResponse.builder()
                    .userId(userId)
                    .username(cleanUsername)
                    .name(displayName)
                    .avatar(initials)
                    .avatarUrl(avatarUrl)
                    .isUser(isCurrentUser)
                    .hasUnseen(hasUnseen)
                    .lastUpdated(lastUpdated)
                    .items(storyResponses)
                    .build();

            groups.add(group);
        }

        // El usuario autenticado siempre debe ver su propio círculo, aunque no tenga
        // historias activas todavía, para poder abrir el flujo de "añadir historia".
        if (currentUserId != null && !currentUserHasGroup) {
            groups.add(buildEmptyGroupForUser(currentUserId));
        }

        // Prioritize current user's group at top
        groups.sort((a, b) -> {
            if (Boolean.TRUE.equals(a.getIsUser())) return -1;
            if (Boolean.TRUE.equals(b.getIsUser())) return 1;
            if (Boolean.TRUE.equals(a.getHasUnseen()) && !Boolean.TRUE.equals(b.getHasUnseen())) return -1;
            if (!Boolean.TRUE.equals(a.getHasUnseen()) && Boolean.TRUE.equals(b.getHasUnseen())) return 1;
            if (a.getLastUpdated() != null && b.getLastUpdated() != null) {
                return b.getLastUpdated().compareTo(a.getLastUpdated());
            }
            return 0;
        });

        return groups;
    }

    private StoryGroupResponse buildEmptyGroupForUser(Integer userId) {
        User user = userRepo.findById(userId).orElse(null);
        Profile profile = profileRepo.findByUserId(userId).orElse(null);

        String rawUsername = user != null && user.getHandle() != null ? user.getHandle() : "usuario_" + userId;
        String cleanUsername = rawUsername.replaceFirst("@.*", "");
        String displayName = (profile != null && profile.getName() != null && !profile.getName().isBlank())
                ? profile.getName()
                : cleanUsername;
        String avatarUrl = profile != null ? profile.getAvatarUrl() : null;
        String initials = displayName.length() >= 2
                ? displayName.substring(0, 2).toUpperCase()
                : displayName.toUpperCase();

        return StoryGroupResponse.builder()
                .userId(userId)
                .username(cleanUsername)
                .name(displayName)
                .avatar(initials)
                .avatarUrl(avatarUrl)
                .isUser(true)
                .hasUnseen(false)
                .lastUpdated(null)
                .items(new ArrayList<>())
                .build();
    }

    @Transactional(readOnly = true)
    public List<StoryResponse> getUserStories(Integer userId, Integer currentUserId) {
        LocalDateTime now = LocalDateTime.now();
        List<Story> stories = storyRepo.findByUserIdAndExpiresAtAfterAndIsArchivedFalseOrderByCreatedAtAsc(userId, now);
        return stories.stream().map(s -> {
            StoryResponse dto = CoreMappers.toResponse(s);
            enrichStoryResponse(dto, s, currentUserId);
            return dto;
        }).collect(Collectors.toList());
    }

    @Transactional
    public boolean viewStory(Integer storyId, Integer currentUserId) {
        Story story = storyRepo.findById(storyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Historia no encontrada"));

        if (currentUserId != null) {
            boolean alreadyViewed = storyViewRepo.existsByStoryIdAndUserId(storyId, currentUserId);
            if (!alreadyViewed) {
                StoryView view = StoryView.builder()
                        .storyId(storyId)
                        .userId(currentUserId)
                        .viewedAt(LocalDateTime.now())
                        .build();
                storyViewRepo.save(view);

                story.setViewCount((story.getViewCount() != null ? story.getViewCount() : 0) + 1);
                storyRepo.save(story);
                return true;
            }
        }
        return false;
    }

    @Transactional
    public boolean toggleLike(Integer storyId, Integer currentUserId) {
        if (currentUserId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado");
        }

        Story story = storyRepo.findById(storyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Historia no encontrada"));

        boolean alreadyLiked = storyLikeRepo.existsByStoryIdAndUserId(storyId, currentUserId);
        if (alreadyLiked) {
            storyLikeRepo.deleteByStoryIdAndUserId(storyId, currentUserId);
            story.setLikesCount(Math.max(0, (story.getLikesCount() != null ? story.getLikesCount() : 1) - 1));
            storyRepo.save(story);
            return false;
        } else {
            StoryLike like = StoryLike.builder()
                    .storyId(storyId)
                    .userId(currentUserId)
                    .createdAt(LocalDateTime.now())
                    .build();
            storyLikeRepo.save(like);

            story.setLikesCount((story.getLikesCount() != null ? story.getLikesCount() : 0) + 1);
            storyRepo.save(story);
            return true;
        }
    }

    @Transactional
    public void replyToStory(Integer storyId, Integer currentUserId, StoryReplyRequest request) {
        if (currentUserId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado");
        }

        Story story = storyRepo.findById(storyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Historia no encontrada"));

        if (story.getUserId().equals(currentUserId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No puedes responder a tu propia historia");
        }

        var conversation = conversationService.startDirect(currentUserId, story.getUserId());

        String preview = story.getCaption() != null && !story.getCaption().isBlank()
                ? story.getCaption()
                : ("TEXT".equalsIgnoreCase(story.getMediaType()) ? story.getTextContent() : "tu historia");

        MessageRequest messageRequest = MessageRequest.builder()
                .conversationId(conversation.getId())
                .content("↩️ " + (preview != null ? "\"" + preview + "\": " : "") + request.getContent())
                .type("story")
                .build();

        messageService.create(messageRequest, currentUserId);
    }

    @Transactional
    public void deleteStory(Integer storyId, Integer currentUserId) {
        Story story = storyRepo.findById(storyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Historia no encontrada"));

        if (currentUserId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado");
        }
        if (!story.getUserId().equals(currentUserId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permiso para eliminar esta historia");
        }

        story.setIsArchived(true);
        storyRepo.save(story);
    }

    private void enrichStoryResponse(StoryResponse dto, Story entity, Integer currentUserId) {
        User user = userRepo.findById(entity.getUserId()).orElse(null);
        Profile profile = profileRepo.findByUserId(entity.getUserId()).orElse(null);

        if (user != null) {
            String rawUsername = user.getHandle() != null ? user.getHandle() : "usuario_" + entity.getUserId();
            dto.setUsername(rawUsername.replaceFirst("@.*", ""));
        }
        if (profile != null) {
            dto.setName(profile.getName());
            dto.setAvatarUrl(profile.getAvatarUrl());
        }

        if (currentUserId != null) {
            dto.setIsViewed(storyViewRepo.existsByStoryIdAndUserId(entity.getId(), currentUserId));
            dto.setIsLiked(storyLikeRepo.existsByStoryIdAndUserId(entity.getId(), currentUserId));
        } else {
            dto.setIsViewed(false);
            dto.setIsLiked(false);
        }
    }

    private String saveMediaFile(MultipartFile file) {
        try {
            Path uploadDir = Paths.get("uploads", "stories");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            String extension = ".jpg";
            String originalFilename = file.getOriginalFilename();
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            String fileName = UUID.randomUUID().toString() + extension;
            Path targetPath = uploadDir.resolve(fileName);

            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            return "/uploads/stories/" + fileName;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "No se pudo guardar el archivo de la historia: " + e.getMessage(), e);
        }
    }
}
