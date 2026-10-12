package zentry.back.api.realtime.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import zentry.back.api.realtime.dtos.ConversationSummaryResponse;
import zentry.back.api.realtime.models.Conversation;
import zentry.back.api.realtime.models.ConversationParticipant;
import zentry.back.api.realtime.models.Message;
import zentry.back.api.realtime.repositories.ConversationParticipantRepository;
import zentry.back.api.realtime.repositories.ConversationRepository;
import zentry.back.api.realtime.repositories.MessageRepository;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

/**
 * Prueba de extremo a extremo (con BD real H2 en modo PostgreSQL, según
 * application-test.properties) para el bug de "timestamp out of range" en
 * GET /api/realtime/conversations/mine: antes, una conversación nunca leída
 * generaba LocalDateTime.MIN como parámetro de "created_at > ?", lo que
 * desbordaba al convertirse a Timestamp. Aquí se ejercita el mismo camino
 * JPA/Hibernate que usa el endpoint real (vía ConversationService.listMine).
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
@DisplayName("ConversationService.listMine - integración con BD real (unreadCount)")
class ConversationServiceIntegrationTest {

    @Autowired
    private ConversationService conversationService;
    @Autowired
    private ConversationRepository conversationRepo;
    @Autowired
    private ConversationParticipantRepository participantRepo;
    @Autowired
    private MessageRepository messageRepo;

    private static final Integer ME = 100;
    private static final Integer OTHER = 200;

    private Integer createConversationWithMessages(LocalDateTime myLastReadAt) {
        LocalDateTime now = LocalDateTime.now();
        Conversation conversation = conversationRepo.save(Conversation.builder()
                .isGroup(false)
                .createdBy(OTHER)
                .createdAt(now)
                .lastMessageAt(now)
                .build());

        participantRepo.save(ConversationParticipant.builder()
                .conversationId(conversation.getId()).userId(ME).role("member")
                .joinedAt(now).lastReadAt(myLastReadAt).build());
        participantRepo.save(ConversationParticipant.builder()
                .conversationId(conversation.getId()).userId(OTHER).role("member")
                .joinedAt(now).build());

        messageRepo.save(Message.builder()
                .conversationId(conversation.getId()).senderId(OTHER)
                .content("hola").type("text").createdAt(now).build());
        messageRepo.save(Message.builder()
                .conversationId(conversation.getId()).senderId(ME)
                .content("mensaje propio").type("text").createdAt(now).build());

        return conversation.getId();
    }

    @Test
    @DisplayName("GET /conversations/mine: conversación nunca leída no lanza 'timestamp out of range' y cuenta el mensaje del otro usuario")
    void neverRead_doesNotThrowAndCountsUnreadFromOtherUser() {
        createConversationWithMessages(null);

        assertThatCode(() -> conversationService.listMine(ME, PageRequest.of(0, 20)))
                .doesNotThrowAnyException();

        Page<ConversationSummaryResponse> page = conversationService.listMine(ME, PageRequest.of(0, 20));
        assertThat(page.getContent()).hasSize(1);
        // 1 mensaje del OTHER, el propio (ME) no cuenta como no leído.
        assertThat(page.getContent().get(0).getUnreadCount()).isEqualTo(1L);
    }

    @Test
    @DisplayName("GET /conversations/mine: conversación ya leída después del mensaje -> unreadCount = 0")
    void alreadyRead_afterMessages_hasZeroUnread() {
        LocalDateTime readAt = LocalDateTime.now().plusSeconds(5);
        Integer conversationId = createConversationWithMessages(null);
        participantRepo.findByConversationIdAndUserId(conversationId, ME).ifPresent(p -> {
            p.setLastReadAt(readAt);
            participantRepo.save(p);
        });

        Page<ConversationSummaryResponse> page = conversationService.listMine(ME, PageRequest.of(0, 20));
        assertThat(page.getContent().get(0).getUnreadCount()).isEqualTo(0L);
    }
}
