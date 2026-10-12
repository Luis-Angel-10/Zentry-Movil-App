package zentry.back.api.core.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zentry.back.api.core.models.Story;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StoryRepository extends JpaRepository<Story, Integer> {

    List<Story> findByExpiresAtAfterAndIsArchivedFalseOrderByCreatedAtAsc(LocalDateTime now);

    List<Story> findByUserIdAndExpiresAtAfterAndIsArchivedFalseOrderByCreatedAtAsc(Integer userId, LocalDateTime now);

    List<Story> findByUserIdOrderByCreatedAtDesc(Integer userId);

    @Query("SELECT DISTINCT s.userId FROM Story s WHERE s.expiresAt > :now AND s.isArchived = false ORDER BY s.createdAt DESC")
    List<Integer> findDistinctActiveUserIds(@Param("now") LocalDateTime now);
}
