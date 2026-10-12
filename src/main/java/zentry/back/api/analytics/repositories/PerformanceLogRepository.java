package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.PerformanceLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PerformanceLogRepository extends JpaRepository<PerformanceLog, Integer> {
   
}
