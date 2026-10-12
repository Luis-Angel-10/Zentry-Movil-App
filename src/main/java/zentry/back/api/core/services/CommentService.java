package zentry.back.api.core.services;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.CommentRequest;
import zentry.back.api.core.dtos.CommentResponse;
import zentry.back.api.core.models.Comment;
import zentry.back.api.core.models.Profile;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.CommentRepository;
import zentry.back.api.core.repositories.PostRepository;
import zentry.back.api.core.repositories.ProfileRepository;
import zentry.back.api.core.repositories.UserRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CommentService {

    private final CommentRepository repo;
    private final PostRepository postRepo;
    private final UserRepository userRepo;
    private final ProfileRepository profileRepo;
    private final GamificationEventService gamificationEventService;
    private final NotificationService notificationService;

    public CommentService(CommentRepository repo, PostRepository postRepo, UserRepository userRepo,
                           ProfileRepository profileRepo, GamificationEventService gamificationEventService,
                           NotificationService notificationService) {
        this.repo = repo;
        this.postRepo = postRepo;
        this.userRepo = userRepo;
        this.profileRepo = profileRepo;
        this.gamificationEventService = gamificationEventService;
        this.notificationService = notificationService;
    }

    private User resolveUser(String identifier) {
        if (identifier == null || identifier.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
        }
        return userRepo.findByUsernameOrEmail(identifier, identifier)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
    }

    public List<CommentResponse> listByPost(Integer postId) {
        return repo.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public CommentResponse create(Integer postId, String identifier, CommentRequest request) {
        User user = resolveUser(identifier);

        zentry.back.api.core.models.Post post = postRepo.findById(postId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Publicación no encontrada"));

        Comment entity = Comment.builder()
                .postId(postId)
                .userId(user.getId())
                .content(request.getContent())
                .createdAt(LocalDateTime.now())
                .build();
        Comment saved = repo.save(entity);

        gamificationEventService.recordMissionProgress(user.getId(), "comment_posts", 1);

        if (!post.getUserId().equals(user.getId())) {
            Profile commenterProfile = profileRepo.findByUserId(user.getId()).orElse(null);
            notificationService.notify(
                    post.getUserId(),
                    "comment",
                    "@" + user.getHandle() + " comentó tu publicación \"" + post.getTitle() + "\"",
                    user.getHandle(),
                    commenterProfile != null ? commenterProfile.getAvatarUrl() : null,
                    post.getId()
            );
        }

        return toResponse(saved);
    }

    public void delete(Integer id, String identifier) {
        User user = resolveUser(identifier);
        Comment entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Comentario no encontrado"));

        if (!entity.getUserId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No puedes eliminar el comentario de otro usuario");
        }
        repo.delete(entity);
    }

    private CommentResponse toResponse(Comment entity) {
        User author = userRepo.findById(entity.getUserId()).orElse(new User());
        Profile profile = profileRepo.findByUserId(entity.getUserId()).orElse(null);

        return CommentResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .authorUsername(author.getHandle())
                .authorAvatarUrl(profile != null ? profile.getAvatarUrl() : null)
                .content(entity.getContent())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
