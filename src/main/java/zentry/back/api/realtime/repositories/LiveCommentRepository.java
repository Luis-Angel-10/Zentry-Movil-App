package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.LiveComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LiveCommentRepository extends JpaRepository<LiveComment, Integer> {

}
