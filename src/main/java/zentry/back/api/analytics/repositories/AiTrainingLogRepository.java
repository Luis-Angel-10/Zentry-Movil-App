package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.AiTrainingLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AiTrainingLogRepository extends JpaRepository<AiTrainingLog, Integer> {
   
}
