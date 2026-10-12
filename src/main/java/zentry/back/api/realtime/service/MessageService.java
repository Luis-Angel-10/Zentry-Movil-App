package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.MessageRequest;
import zentry.back.api.realtime.dtos.MessageResponse;
import zentry.back.api.realtime.models.Conversation;
import zentry.back.api.realtime.models.Message;
import zentry.back.api.realtime.repositories.ConversationParticipantRepository;
import zentry.back.api.realtime.repositories.ConversationRepository;
import zentry.back.api.realtime.repositories.MessageRepository;
import zentry.back.api.global.mappers;
import zentry.back.api.core.services.GamificationEventService;

import java.time.LocalDateTime;

@Service
@SuppressWarnings("null")
public class MessageService {

    private final MessageRepository repo;
    private final ConversationParticipantRepository participantRepo;
    private final ConversationRepository conversationRepo;
    private final SimpMessagingTemplate messagingTemplate;
    private final GamificationEventService gamificationEventService;

    public MessageService(MessageRepository repo, ConversationParticipantRepository participantRepo,
                           ConversationRepository conversationRepo, SimpMessagingTemplate messagingTemplate,
                           GamificationEventService gamificationEventService) {
        this.repo = repo;
        this.participantRepo = participantRepo;
        this.conversationRepo = conversationRepo;
        this.messagingTemplate = messagingTemplate;
        this.gamificationEventService = gamificationEventService;
    }

    public Page<MessageResponse> listByConversation(Integer conversationId, Integer requesterId, Pageable pageable) {
        requireParticipant(conversationId, requesterId);
        return repo.findByConversationId(conversationId, pageable).map(mappers::toResponse);
    }

    public MessageResponse getById(Integer id, Integer requesterId) {
        Message entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Message not found"));
        requireParticipant(entity.getConversationId(), requesterId);
        return mappers.toResponse(entity);
    }

    @Transactional
    public MessageResponse create(MessageRequest request, Integer senderId) {
        requireParticipant(request.getConversationId(), senderId);

        Message entity = Message.builder()
                .conversationId(request.getConversationId())
                .senderId(senderId)
                .content(request.getContent())
                .type(request.getType())
                .createdAt(LocalDateTime.now())
                .build();
        Message saved = repo.save(entity);

        Conversation conversation = conversationRepo.findById(request.getConversationId()).orElse(null);
        if (conversation != null) {
            conversation.setLastMessageAt(saved.getCreatedAt());
            conversationRepo.save(conversation);
        }

        gamificationEventService.recordMissionProgress(senderId, "send_message", 1);
        gamificationEventService.recordAchievementProgress(senderId, "send_messages", 1);

        MessageResponse response = mappers.toResponse(saved);
        messagingTemplate.convertAndSend("/topic/conversations/" + request.getConversationId(), response);
        return response;
    }

    public MessageResponse update(Integer id, MessageRequest request, Integer requesterId) {
        Message entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Message not found"));
        requireOwner(entity, requesterId);
        entity.setContent(request.getContent());
        entity.setType(request.getType());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id, Integer requesterId) {
        Message entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Message not found"));
        requireOwner(entity, requesterId);
        repo.delete(entity);
    }

    private void requireParticipant(Integer conversationId, Integer userId) {
        if (!participantRepo.existsByConversationIdAndUserId(conversationId, userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No perteneces a esta conversación");
        }
    }

    private void requireOwner(Message message, Integer requesterId) {
        if (!message.getSenderId().equals(requesterId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No puedes modificar un mensaje de otro usuario");
        }
    }
}
