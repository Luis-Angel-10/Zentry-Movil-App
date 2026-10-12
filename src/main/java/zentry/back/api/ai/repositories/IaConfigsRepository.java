package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaConfigs;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IaConfigsRepository extends JpaRepository<IaConfigs, UUID> {
    List<IaConfigs> findByModelId(Integer modelId);
    boolean existsByModelId(Integer modelId);
}
