package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.FeatureUsage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FeatureUsageRepository extends JpaRepository<FeatureUsage, Integer> {
   
}
