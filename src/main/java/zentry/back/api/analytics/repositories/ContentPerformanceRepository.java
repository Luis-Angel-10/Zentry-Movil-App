package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.ContentPerformance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ContentPerformanceRepository extends JpaRepository<ContentPerformance, Integer> {
   
}
