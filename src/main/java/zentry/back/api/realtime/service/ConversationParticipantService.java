package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.realtime.dtos.ConversationParticipantRequest;
import zentry.back.api.realtime.dtos.ConversationParticipantResponse;
import zentry.back.api.realtime.models.Conversation;
import zentry.back.api.realtime.models.ConversationParticipant;
import zentry.back.api.realtime.models.ConversationParticipant.ConversationParticipantId;
import zentry.back.api.realtime.repositories.ConversationParticipantRepository;
import zentry.back.api.realtime.repositories.ConversationRepository;
import zentry.back.api.realtime.repositories.MessageRepository;
import zentry.back.api.global.mappers;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ConversationParticipantService {

    private final ConversationParticipantRepository repo;
    private final ConversationRepository conversationRepo;
    private final MessageRepository messageRepo;
    private final UserRepository userRepo;

    public ConversationParticipantService(ConversationParticipantRepository repo, ConversationRepository conversationRepo,
                                           MessageRepository messageRepo, UserRepository userRepo) {
        this.repo = repo;
        this.conversationRepo = conversationRepo;
        this.messageRepo = messageRepo;
        this.userRepo = userRepo;
    }

    public Page<ConversationParticipantResponse> listByConversation(Integer conversationId, Integer requesterId, Pageable pageable) {
        requireParticipant(conversationId, requesterId);
        List<ConversationParticipantResponse> all = repo.findByConversationId(conversationId).stream()
                .map(mappers::toResponse)
                .collect(Collectors.toList());
        int start = Math.min((int) pageable.getOffset(), all.size());
        int end = Math.min(start + pageable.getPageSize(), all.size());
        return new PageImpl<>(all.subList(start, end), pageable, all.size());
    }

    public ConversationParticipantResponse getById(Integer conversationId, Integer userId, Integer requesterId) {
        requireParticipant(conversationId, requesterId);
        ConversationParticipant entity = repo.findById(new ConversationParticipantId(conversationId, userId))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Participante no encontrado"));
        return mappers.toResponse(entity);
    }

    @Transactional
    public ConversationParticipantResponse addParticipant(ConversationParticipantRequest request, Integer requesterId) {
        Conversation conversation = conversationRepo.findById(request.getConversationId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Conversación no encontrada"));
        if (!Boolean.TRUE.equals(conversation.getIsGroup())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No se pueden agregar participantes a una conversación directa");
        }
        requireParticipant(conversation.getId(), requesterId);

        if (!userRepo.existsById(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }

        ConversationParticipantId id = new ConversationParticipantId(conversation.getId(), request.getUserId());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El usuario ya pertenece a esta conversación");
        }

        ConversationParticipant entity = ConversationParticipant.builder()
                .conversationId(conversation.getId())
                .userId(request.getUserId())
                .role("member")
                .joinedAt(LocalDateTime.now())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    @Transactional
    public void removeParticipant(Integer conversationId, Integer userId, Integer requesterId) {
        ConversationParticipant target = repo.findById(new ConversationParticipantId(conversationId, userId))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Participante no encontrado"));

        if (!requesterId.equals(userId)) {
            ConversationParticipant requesterParticipation = repo.findByConversationIdAndUserId(conversationId, requesterId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No perteneces a esta conversación"));
            if (!"admin".equalsIgnoreCase(requesterParticipation.getRole())) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Solo un administrador del grupo puede quitar a otros participantes");
            }
        }

        repo.delete(target);

        if (repo.countByConversationId(conversationId) == 0) {
            messageRepo.deleteByConversationId(conversationId);
            conversationRepo.deleteById(conversationId);
        }
    }

    private void requireParticipant(Integer conversationId, Integer userId) {
        if (!repo.existsByConversationIdAndUserId(conversationId, userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No perteneces a esta conversación");
        }
    }
}
