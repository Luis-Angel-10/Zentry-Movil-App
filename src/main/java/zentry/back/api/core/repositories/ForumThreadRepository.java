package zentry.back.api.core.repositories;

import zentry.back.api.core.models.ForumThread;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ForumThreadRepository extends JpaRepository<ForumThread, Integer> {
    Page<ForumThread> findByCommunityIdOrderByUpdatedAtDesc(Integer communityId, Pageable pageable);
    java.util.List<ForumThread> findByCommunityId(Integer communityId);
}
