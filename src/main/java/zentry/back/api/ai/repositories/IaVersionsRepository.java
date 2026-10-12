package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaVersions;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface IaVersionsRepository extends JpaRepository<IaVersions, UUID> {
    List<IaVersions> findByModelId(Integer modelId);
    Optional<IaVersions> findByModelIdAndVersion(Integer modelId, String version);
    boolean existsByModelIdAndVersion(Integer modelId, String version);
}
