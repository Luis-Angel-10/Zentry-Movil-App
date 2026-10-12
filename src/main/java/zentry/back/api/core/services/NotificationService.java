package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.NotificationResponse;
import zentry.back.api.core.models.Notification;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.NotificationRepository;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.mappers.CoreMappers;

import java.time.LocalDateTime;

@Service("coreNotificationService")
@SuppressWarnings("null")
public class NotificationService {

    private final NotificationRepository repo;
    private final UserRepository userRepo;

    public NotificationService(NotificationRepository repo, UserRepository userRepo) {
        this.repo = repo;
        this.userRepo = userRepo;
    }

    private User resolveUser(String identifier) {
        if (identifier == null || identifier.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
        }
        return userRepo.findByUsernameOrEmail(identifier, identifier)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
    }

    /**
     * Lista SOLO las notificaciones del usuario autenticado — nunca las de otros usuarios.
     */
    public Page<NotificationResponse> list(String identifier, Pageable pageable) {
        User user = resolveUser(identifier);
        return repo.findByUserIdOrderByCreatedAtDesc(user.getId(), pageable).map(CoreMappers::toResponse);
    }

    public void markAsRead(Integer id, String identifier) {
        User user = resolveUser(identifier);
        Notification notification = repo.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Notificación no encontrada"));
        notification.setRead(true);
        repo.save(notification);
    }

    @Transactional
    public void markAllAsRead(String identifier) {
        User user = resolveUser(identifier);
        repo.markAllAsRead(user.getId());
    }

    @Transactional
    public void clearAll(String identifier) {
        User user = resolveUser(identifier);
        repo.deleteByUserId(user.getId());
    }

    /**
     * Punto de entrada interno usado por otros servicios (likes, comentarios, seguidores,
     * solicitudes de amistad) para generar una notificación real. No se expone como
     * endpoint público: cualquier usuario podría inyectar notificaciones falsas a otros
     * si esto fuera un POST abierto.
     */
    public void notify(Integer recipientUserId, String type, String content, String sourceUsername, String sourceAvatarUrl, Integer relatedId) {
        if (recipientUserId == null) return;

        repo.save(Notification.builder()
                .userId(recipientUserId)
                .type(type)
                .content(content)
                .sourceUsername(sourceUsername)
                .sourceAvatarUrl(sourceAvatarUrl)
                .relatedId(relatedId)
                .read(false)
                .createdAt(LocalDateTime.now())
                .build());
    }
}
