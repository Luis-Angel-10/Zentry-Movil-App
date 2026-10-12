package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.ConversationParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConversationParticipantRepository extends JpaRepository<ConversationParticipant, ConversationParticipant.ConversationParticipantId> {
    boolean existsByConversationIdAndUserId(Integer conversationId, Integer userId);
    Optional<ConversationParticipant> findByConversationIdAndUserId(Integer conversationId, Integer userId);
    List<ConversationParticipant> findByUserId(Integer userId);
    List<ConversationParticipant> findByConversationId(Integer conversationId);
    long countByConversationId(Integer conversationId);
}
