package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.EngagementMetric;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EngagementMetricRepository extends JpaRepository<EngagementMetric, Integer> {
   
}
