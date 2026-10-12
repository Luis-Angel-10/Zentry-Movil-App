package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.ForumThreadRequest;
import zentry.back.api.core.dtos.ForumThreadResponse;
import zentry.back.api.core.models.ForumThread;
import zentry.back.api.core.models.Profile;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.CommunityRepository;
import zentry.back.api.core.repositories.ForumReplyRepository;
import zentry.back.api.core.repositories.ForumThreadRepository;
import zentry.back.api.core.repositories.ProfileRepository;
import zentry.back.api.core.repositories.UserRepository;

import java.time.LocalDateTime;

@Service
public class ForumThreadService {

    private final ForumThreadRepository repo;
    private final ForumReplyRepository replyRepo;
    private final CommunityRepository communityRepo;
    private final UserRepository userRepo;
    private final ProfileRepository profileRepo;

    public ForumThreadService(ForumThreadRepository repo, ForumReplyRepository replyRepo, CommunityRepository communityRepo,
                               UserRepository userRepo, ProfileRepository profileRepo) {
        this.repo = repo;
        this.replyRepo = replyRepo;
        this.communityRepo = communityRepo;
        this.userRepo = userRepo;
        this.profileRepo = profileRepo;
    }

    private User resolveUser(String identifier) {
        if (identifier == null || identifier.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
        }
        return userRepo.findByUsernameOrEmail(identifier, identifier)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
    }

    public Page<ForumThreadResponse> listByCommunity(Integer communityId, Pageable pageable) {
        return repo.findByCommunityIdOrderByUpdatedAtDesc(communityId, pageable).map(this::toResponse);
    }

    public ForumThreadResponse getById(Integer id) {
        ForumThread entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Hilo no encontrado"));
        return toResponse(entity);
    }

    public ForumThreadResponse create(String identifier, ForumThreadRequest request) {
        User author = resolveUser(identifier);

        if (!communityRepo.existsById(request.getCommunityId())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Comunidad no encontrada");
        }

        LocalDateTime now = LocalDateTime.now();
        ForumThread entity = ForumThread.builder()
                .communityId(request.getCommunityId())
                .authorUserId(author.getId())
                .title(request.getTitle())
                .content(request.getContent())
                .createdAt(now)
                .updatedAt(now)
                .build();

        return toResponse(repo.save(entity));
    }

    public void delete(Integer id, String identifier) {
        User user = resolveUser(identifier);
        ForumThread entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Hilo no encontrado"));

        if (!entity.getAuthorUserId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No puedes eliminar el hilo de otro usuario");
        }

        replyRepo.deleteByThreadId(id);
        repo.delete(entity);
    }

    void touchUpdatedAt(Integer threadId) {
        repo.findById(threadId).ifPresent(thread -> {
            thread.setUpdatedAt(LocalDateTime.now());
            repo.save(thread);
        });
    }

    private ForumThreadResponse toResponse(ForumThread entity) {
        User author = userRepo.findById(entity.getAuthorUserId()).orElse(new User());
        Profile profile = profileRepo.findByUserId(entity.getAuthorUserId()).orElse(null);
        long repliesCount = replyRepo.countByThreadId(entity.getId());

        return ForumThreadResponse.builder()
                .id(entity.getId())
                .communityId(entity.getCommunityId())
                .authorUserId(entity.getAuthorUserId())
                .authorUsername(author.getHandle())
                .authorAvatarUrl(profile != null ? profile.getAvatarUrl() : null)
                .title(entity.getTitle())
                .content(entity.getContent())
                .repliesCount((int) repliesCount)
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}
