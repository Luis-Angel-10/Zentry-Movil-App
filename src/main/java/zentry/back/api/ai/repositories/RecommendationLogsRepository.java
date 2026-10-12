package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.RecommendationLogs;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

@Repository
public interface RecommendationLogsRepository extends JpaRepository<RecommendationLogs, UUID> {
    List<RecommendationLogs> findByRecommendationId(Integer recommendationId);
    List<RecommendationLogs> findByTimestampAfter(Timestamp timestamp);
    boolean existsByRecommendationId(Integer recommendationId);
}
