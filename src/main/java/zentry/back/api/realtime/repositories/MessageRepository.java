package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface MessageRepository extends JpaRepository<Message, Integer> {
    Page<Message> findByConversationId(Integer conversationId, Pageable pageable);
    Optional<Message> findTopByConversationIdOrderByCreatedAtDesc(Integer conversationId);
    long countByConversationIdAndSenderIdNotAndCreatedAtAfter(Integer conversationId, Integer senderId, LocalDateTime after);
    long countByConversationIdAndSenderIdNot(Integer conversationId, Integer senderId);
    void deleteByConversationId(Integer conversationId);
}
