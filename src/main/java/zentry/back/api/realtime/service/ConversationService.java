package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.realtime.dtos.ConversationResponse;
import zentry.back.api.realtime.dtos.ConversationSummaryResponse;
import zentry.back.api.realtime.dtos.GroupConversationRequest;
import zentry.back.api.realtime.models.Conversation;
import zentry.back.api.realtime.models.ConversationParticipant;
import zentry.back.api.realtime.models.Message;
import zentry.back.api.realtime.repositories.ConversationParticipantRepository;
import zentry.back.api.realtime.repositories.ConversationRepository;
import zentry.back.api.realtime.repositories.MessageRepository;
import zentry.back.api.global.mappers;

import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ConversationService {

    private final ConversationRepository conversationRepo;
    private final ConversationParticipantRepository participantRepo;
    private final MessageRepository messageRepo;
    private final UserRepository userRepo;

    public ConversationService(ConversationRepository conversationRepo, ConversationParticipantRepository participantRepo,
                                MessageRepository messageRepo, UserRepository userRepo) {
        this.conversationRepo = conversationRepo;
        this.participantRepo = participantRepo;
        this.messageRepo = messageRepo;
        this.userRepo = userRepo;
    }

    @Transactional
    public ConversationResponse startDirect(Integer userId, Integer otherUserId) {
        if (userId.equals(otherUserId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No puedes iniciar una conversación contigo mismo");
        }
        if (!userRepo.existsById(otherUserId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }

        Set<Integer> myConversationIds = participantRepo.findByUserId(userId).stream()
                .map(ConversationParticipant::getConversationId)
                .collect(Collectors.toSet());
        Set<Integer> otherConversationIds = participantRepo.findByUserId(otherUserId).stream()
                .map(ConversationParticipant::getConversationId)
                .collect(Collectors.toSet());
        myConversationIds.retainAll(otherConversationIds);

        for (Integer conversationId : myConversationIds) {
            Conversation candidate = conversationRepo.findById(conversationId).orElse(null);
            if (candidate != null && !Boolean.TRUE.equals(candidate.getIsGroup())
                    && participantRepo.countByConversationId(conversationId) == 2) {
                return mappers.toResponse(candidate);
            }
        }

        LocalDateTime now = LocalDateTime.now();
        Conversation conversation = conversationRepo.save(Conversation.builder()
                .isGroup(false)
                .createdBy(userId)
                .createdAt(now)
                .lastMessageAt(now)
                .build());

        participantRepo.save(ConversationParticipant.builder()
                .conversationId(conversation.getId()).userId(userId).role("member").joinedAt(now).build());
        participantRepo.save(ConversationParticipant.builder()
                .conversationId(conversation.getId()).userId(otherUserId).role("member").joinedAt(now).build());

        return mappers.toResponse(conversation);
    }

    @Transactional
    public ConversationResponse createGroup(Integer creatorId, GroupConversationRequest request) {
        Set<Integer> memberIds = new LinkedHashSet<>(request.getParticipantUserIds());
        memberIds.remove(creatorId);
        if (memberIds.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Un grupo necesita al menos otro participante");
        }
        for (Integer memberId : memberIds) {
            if (!userRepo.existsById(memberId)) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado: " + memberId);
            }
        }

        LocalDateTime now = LocalDateTime.now();
        Conversation conversation = conversationRepo.save(Conversation.builder()
                .isGroup(true)
                .name(request.getName())
                .createdBy(creatorId)
                .createdAt(now)
                .lastMessageAt(now)
                .build());

        participantRepo.save(ConversationParticipant.builder()
                .conversationId(conversation.getId()).userId(creatorId).role("admin").joinedAt(now).build());
        for (Integer memberId : memberIds) {
            participantRepo.save(ConversationParticipant.builder()
                    .conversationId(conversation.getId()).userId(memberId).role("member").joinedAt(now).build());
        }

        return mappers.toResponse(conversation);
    }

    public Page<ConversationSummaryResponse> listMine(Integer userId, Pageable pageable) {
        List<ConversationParticipant> myParticipations = participantRepo.findByUserId(userId);

        List<ConversationSummaryResponse> summaries = myParticipations.stream()
                .map(participation -> buildSummary(participation, userId))
                .filter(java.util.Objects::nonNull)
                .sorted((a, b) -> {
                    LocalDateTime ta = a.getLastMessageAt();
                    LocalDateTime tb = b.getLastMessageAt();
                    if (ta == null && tb == null) return 0;
                    if (ta == null) return 1;
                    if (tb == null) return -1;
                    return tb.compareTo(ta);
                })
                .collect(Collectors.toList());

        int start = Math.min((int) pageable.getOffset(), summaries.size());
        int end = Math.min(start + pageable.getPageSize(), summaries.size());
        return new PageImpl<>(summaries.subList(start, end), pageable, summaries.size());
    }

    public ConversationResponse getById(Integer conversationId, Integer requesterId) {
        Conversation conversation = conversationRepo.findById(conversationId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Conversación no encontrada"));
        requireParticipant(conversationId, requesterId);
        return mappers.toResponse(conversation);
    }

    @Transactional
    public ConversationResponse renameGroup(Integer conversationId, Integer requesterId, String newName) {
        Conversation conversation = conversationRepo.findById(conversationId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Conversación no encontrada"));
        if (!Boolean.TRUE.equals(conversation.getIsGroup())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Solo los grupos se pueden renombrar");
        }
        requireAdmin(conversationId, requesterId);
        conversation.setName(newName);
        return mappers.toResponse(conversationRepo.save(conversation));
    }

    @Transactional
    public void markRead(Integer conversationId, Integer userId) {
        ConversationParticipant participation = participantRepo.findByConversationIdAndUserId(conversationId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No perteneces a esta conversación"));
        participation.setLastReadAt(LocalDateTime.now());
        participantRepo.save(participation);
    }

    @Transactional
    public void deleteGroup(Integer conversationId, Integer requesterId) {
        Conversation conversation = conversationRepo.findById(conversationId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Conversación no encontrada"));
        if (!Boolean.TRUE.equals(conversation.getIsGroup())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Para salir de una conversación directa, elimina tu participación en vez de borrarla");
        }
        requireAdmin(conversationId, requesterId);
        messageRepo.deleteByConversationId(conversationId);
        participantRepo.findByConversationId(conversationId).forEach(participantRepo::delete);
        conversationRepo.delete(conversation);
    }

    void requireParticipant(Integer conversationId, Integer userId) {
        if (!participantRepo.existsByConversationIdAndUserId(conversationId, userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No perteneces a esta conversación");
        }
    }

    void requireAdmin(Integer conversationId, Integer userId) {
        ConversationParticipant participation = participantRepo.findByConversationIdAndUserId(conversationId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No perteneces a esta conversación"));
        if (!"admin".equalsIgnoreCase(participation.getRole())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Solo un administrador del grupo puede hacer esto");
        }
    }

    private ConversationSummaryResponse buildSummary(ConversationParticipant participation, Integer userId) {
        Conversation conversation = conversationRepo.findById(participation.getConversationId()).orElse(null);
        if (conversation == null) return null;

        Message lastMessage = messageRepo.findTopByConversationIdOrderByCreatedAtDesc(conversation.getId()).orElse(null);
        LocalDateTime lastReadAt = participation.getLastReadAt();
        long unread = lastReadAt != null
                ? messageRepo.countByConversationIdAndSenderIdNotAndCreatedAtAfter(conversation.getId(), userId, lastReadAt)
                : messageRepo.countByConversationIdAndSenderIdNot(conversation.getId(), userId);

        Integer otherUserId = null;
        if (!Boolean.TRUE.equals(conversation.getIsGroup())) {
            otherUserId = participantRepo.findByConversationId(conversation.getId()).stream()
                    .map(ConversationParticipant::getUserId)
                    .filter(id -> !id.equals(userId))
                    .findFirst()
                    .orElse(null);
        }

        return ConversationSummaryResponse.builder()
                .id(conversation.getId())
                .isGroup(conversation.getIsGroup())
                .name(conversation.getName())
                .otherUserId(otherUserId)
                .lastMessageContent(lastMessage != null ? lastMessage.getContent() : null)
                .lastMessageSenderId(lastMessage != null ? lastMessage.getSenderId() : null)
                .lastMessageAt(conversation.getLastMessageAt())
                .unreadCount(unread)
                .build();
    }
}
