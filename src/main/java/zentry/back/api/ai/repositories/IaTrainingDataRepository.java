package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaTrainingData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface IaTrainingDataRepository extends JpaRepository<IaTrainingData, UUID> {
    boolean existsByDataInput(String dataInput);
}
