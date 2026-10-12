package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.RecommendationLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RecommendationLogRepository extends JpaRepository<RecommendationLog, Integer> {
   
}
