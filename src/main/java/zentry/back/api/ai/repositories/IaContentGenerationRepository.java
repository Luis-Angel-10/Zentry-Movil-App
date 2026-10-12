package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaContentGeneration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IaContentGenerationRepository extends JpaRepository<IaContentGeneration, UUID> {
    List<IaContentGeneration> findByPromptId(Integer promptId);
    boolean existsByPromptId(Integer promptId);
}
