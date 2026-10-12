package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaTrainingLogs;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

@Repository
public interface IaTrainingLogsRepository extends JpaRepository<IaTrainingLogs, UUID> {
    List<IaTrainingLogs> findByModelId(Integer modelId);
    List<IaTrainingLogs> findByEstado(String estado);
    List<IaTrainingLogs> findByModelIdAndEstado(Integer modelId, String estado);
    List<IaTrainingLogs> findByFechaAfter(Timestamp fecha);
    boolean existsByModelIdAndEstado(Integer modelId, String estado);
}
