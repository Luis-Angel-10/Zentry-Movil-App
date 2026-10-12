package zentry.back.api.core.repositories;

import zentry.back.api.core.models.ForumReply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ForumReplyRepository extends JpaRepository<ForumReply, Integer> {
    List<ForumReply> findByThreadIdOrderByCreatedAtAsc(Integer threadId);
    long countByThreadId(Integer threadId);
    void deleteByThreadId(Integer threadId);
}
