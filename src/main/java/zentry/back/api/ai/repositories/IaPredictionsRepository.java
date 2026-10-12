package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaPredictions;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IaPredictionsRepository extends JpaRepository<IaPredictions, UUID> {
    List<IaPredictions> findByModelId(Integer modelId);
    boolean existsByModelId(Integer modelId);
}
