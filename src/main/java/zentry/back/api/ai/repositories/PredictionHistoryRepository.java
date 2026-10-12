package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.PredictionHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

@Repository
public interface PredictionHistoryRepository extends JpaRepository<PredictionHistory, UUID> {
    List<PredictionHistory> findByPredictionId(Integer predictionId);
    List<PredictionHistory> findByFechaAfter(Timestamp fecha);
    boolean existsByPredictionId(Integer predictionId);
}
