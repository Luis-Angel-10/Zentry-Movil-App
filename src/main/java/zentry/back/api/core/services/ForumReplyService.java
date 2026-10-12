package zentry.back.api.core.services;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.ForumReplyRequest;
import zentry.back.api.core.dtos.ForumReplyResponse;
import zentry.back.api.core.models.ForumReply;
import zentry.back.api.core.models.ForumThread;
import zentry.back.api.core.models.Profile;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.ForumReplyRepository;
import zentry.back.api.core.repositories.ForumThreadRepository;
import zentry.back.api.core.repositories.ProfileRepository;
import zentry.back.api.core.repositories.UserRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ForumReplyService {

    private final ForumReplyRepository repo;
    private final ForumThreadRepository threadRepo;
    private final UserRepository userRepo;
    private final ProfileRepository profileRepo;
    private final ForumThreadService forumThreadService;

    public ForumReplyService(ForumReplyRepository repo, ForumThreadRepository threadRepo, UserRepository userRepo,
                              ProfileRepository profileRepo, ForumThreadService forumThreadService) {
        this.repo = repo;
        this.threadRepo = threadRepo;
        this.userRepo = userRepo;
        this.profileRepo = profileRepo;
        this.forumThreadService = forumThreadService;
    }

    private User resolveUser(String identifier) {
        if (identifier == null || identifier.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
        }
        return userRepo.findByUsernameOrEmail(identifier, identifier)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
    }

    public List<ForumReplyResponse> listByThread(Integer threadId) {
        return repo.findByThreadIdOrderByCreatedAtAsc(threadId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public ForumReplyResponse create(Integer threadId, String identifier, ForumReplyRequest request) {
        User author = resolveUser(identifier);

        ForumThread thread = threadRepo.findById(threadId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Hilo no encontrado"));

        ForumReply entity = ForumReply.builder()
                .threadId(thread.getId())
                .authorUserId(author.getId())
                .content(request.getContent())
                .createdAt(LocalDateTime.now())
                .build();

        ForumReply saved = repo.save(entity);
        forumThreadService.touchUpdatedAt(threadId);

        return toResponse(saved);
    }

    public void delete(Integer id, String identifier) {
        User user = resolveUser(identifier);
        ForumReply entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Respuesta no encontrada"));

        if (!entity.getAuthorUserId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No puedes eliminar la respuesta de otro usuario");
        }

        repo.delete(entity);
    }

    private ForumReplyResponse toResponse(ForumReply entity) {
        User author = userRepo.findById(entity.getAuthorUserId()).orElse(new User());
        Profile profile = profileRepo.findByUserId(entity.getAuthorUserId()).orElse(null);

        return ForumReplyResponse.builder()
                .id(entity.getId())
                .threadId(entity.getThreadId())
                .authorUserId(entity.getAuthorUserId())
                .authorUsername(author.getHandle())
                .authorAvatarUrl(profile != null ? profile.getAvatarUrl() : null)
                .content(entity.getContent())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
