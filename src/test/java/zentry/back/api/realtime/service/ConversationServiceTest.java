package zentry.back.api.realtime.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.realtime.dtos.ConversationSummaryResponse;
import zentry.back.api.realtime.models.Conversation;
import zentry.back.api.realtime.models.ConversationParticipant;
import zentry.back.api.realtime.repositories.ConversationParticipantRepository;
import zentry.back.api.realtime.repositories.ConversationRepository;
import zentry.back.api.realtime.repositories.MessageRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Cubre el cálculo de unreadCount en ConversationService.buildSummary(...), que se
 * ejecuta a través de listMine(...). Regresión del bug: cuando lastReadAt era null se
 * usaba LocalDateTime.MIN como parámetro de "created_at > ?", lo que al convertirse a
 * Timestamp desbordaba y PostgreSQL rechazaba la consulta ("timestamp out of range").
 */
@DisplayName("ConversationService.listMine (cálculo de unreadCount)")
class ConversationServiceTest {

    private ConversationRepository conversationRepo;
    private ConversationParticipantRepository participantRepo;
    private MessageRepository messageRepo;
    private UserRepository userRepo;
    private ConversationService conversationService;

    private static final Integer CONVERSATION_ID = 10;
    private static final Integer ME = 1;
    private static final Integer OTHER = 2;

    @BeforeEach
    void setUp() {
        conversationRepo = mock(ConversationRepository.class);
        participantRepo = mock(ConversationParticipantRepository.class);
        messageRepo = mock(MessageRepository.class);
        userRepo = mock(UserRepository.class);
        conversationService = new ConversationService(conversationRepo, participantRepo, messageRepo, userRepo);

        Conversation conversation = Conversation.builder()
                .id(CONVERSATION_ID)
                .isGroup(false)
                .createdBy(ME)
                .createdAt(LocalDateTime.now())
                .lastMessageAt(LocalDateTime.now())
                .build();
        when(conversationRepo.findById(CONVERSATION_ID)).thenReturn(Optional.of(conversation));
        when(participantRepo.findByConversationId(CONVERSATION_ID)).thenReturn(List.of(
                ConversationParticipant.builder().conversationId(CONVERSATION_ID).userId(ME).role("member").build(),
                ConversationParticipant.builder().conversationId(CONVERSATION_ID).userId(OTHER).role("member").build()
        ));
        when(messageRepo.findTopByConversationIdOrderByCreatedAtDesc(CONVERSATION_ID)).thenReturn(Optional.empty());
    }

    private Page<ConversationSummaryResponse> listMine() {
        Pageable pageable = PageRequest.of(0, 20);
        return conversationService.listMine(ME, pageable);
    }

    @Test
    @DisplayName("conversación nunca leída (lastReadAt == null) -> usa countByConversationIdAndSenderIdNot, sin timestamp sentinel")
    void neverRead_usesCountWithoutTimestamp() {
        ConversationParticipant myParticipation = ConversationParticipant.builder()
                .conversationId(CONVERSATION_ID).userId(ME).role("member").lastReadAt(null).build();
        when(participantRepo.findByUserId(ME)).thenReturn(List.of(myParticipation));
        when(messageRepo.countByConversationIdAndSenderIdNot(CONVERSATION_ID, ME)).thenReturn(3L);

        Page<ConversationSummaryResponse> result = listMine();

        assertThat(result.getContent()).hasSize(1);
        assertThat(result.getContent().get(0).getUnreadCount()).isEqualTo(3L);
        verify(messageRepo).countByConversationIdAndSenderIdNot(CONVERSATION_ID, ME);
        verify(messageRepo, never())
                .countByConversationIdAndSenderIdNotAndCreatedAtAfter(anyInt(), anyInt(), any());
    }

    @Test
    @DisplayName("conversación ya leída -> cuenta solo mensajes posteriores a lastReadAt")
    void alreadyRead_countsMessagesAfterLastReadAt() {
        LocalDateTime lastReadAt = LocalDateTime.now().minusHours(1);
        ConversationParticipant myParticipation = ConversationParticipant.builder()
                .conversationId(CONVERSATION_ID).userId(ME).role("member").lastReadAt(lastReadAt).build();
        when(participantRepo.findByUserId(ME)).thenReturn(List.of(myParticipation));
        when(messageRepo.countByConversationIdAndSenderIdNotAndCreatedAtAfter(CONVERSATION_ID, ME, lastReadAt))
                .thenReturn(2L);

        Page<ConversationSummaryResponse> result = listMine();

        assertThat(result.getContent().get(0).getUnreadCount()).isEqualTo(2L);
        verify(messageRepo).countByConversationIdAndSenderIdNotAndCreatedAtAfter(CONVERSATION_ID, ME, lastReadAt);
        verify(messageRepo, never()).countByConversationIdAndSenderIdNot(anyInt(), anyInt());
    }

    @Test
    @DisplayName("mensajes posteriores a lastReadAt se reflejan en unreadCount")
    void messagesAfterLastReadAt_areCounted() {
        LocalDateTime lastReadAt = LocalDateTime.now().minusMinutes(30);
        ConversationParticipant myParticipation = ConversationParticipant.builder()
                .conversationId(CONVERSATION_ID).userId(ME).role("member").lastReadAt(lastReadAt).build();
        when(participantRepo.findByUserId(ME)).thenReturn(List.of(myParticipation));
        when(messageRepo.countByConversationIdAndSenderIdNotAndCreatedAtAfter(eq(CONVERSATION_ID), eq(ME), any()))
                .thenReturn(5L);

        Page<ConversationSummaryResponse> result = listMine();

        assertThat(result.getContent().get(0).getUnreadCount()).isEqualTo(5L);
    }

    @Test
    @DisplayName("el conteo de no leídos excluye mensajes propios (delega senderId<>? al repositorio)")
    void ownMessages_areExcludedViaSenderIdNotParameter() {
        ConversationParticipant myParticipation = ConversationParticipant.builder()
                .conversationId(CONVERSATION_ID).userId(ME).role("member").lastReadAt(null).build();
        when(participantRepo.findByUserId(ME)).thenReturn(List.of(myParticipation));
        when(messageRepo.countByConversationIdAndSenderIdNot(CONVERSATION_ID, ME)).thenReturn(0L);

        listMine();

        // El "propio usuario" (ME) es exactamente el senderId excluido -> mensajes propios no cuentan.
        verify(messageRepo).countByConversationIdAndSenderIdNot(CONVERSATION_ID, ME);
    }

    @Test
    @DisplayName("timestamp normal actual -> se pasa tal cual al repositorio, sin transformación")
    void normalCurrentTimestamp_passedThroughUnchanged() {
        LocalDateTime now = LocalDateTime.now();
        ConversationParticipant myParticipation = ConversationParticipant.builder()
                .conversationId(CONVERSATION_ID).userId(ME).role("member").lastReadAt(now).build();
        when(participantRepo.findByUserId(ME)).thenReturn(List.of(myParticipation));
        when(messageRepo.countByConversationIdAndSenderIdNotAndCreatedAtAfter(CONVERSATION_ID, ME, now))
                .thenReturn(1L);

        listMine();

        verify(messageRepo).countByConversationIdAndSenderIdNotAndCreatedAtAfter(CONVERSATION_ID, ME, now);
    }
}
