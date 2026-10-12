package zentry.back.api.core.repositories;

import zentry.back.api.core.models.CommentReply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentReplyRepository extends JpaRepository<CommentReply, Integer> {
   
}