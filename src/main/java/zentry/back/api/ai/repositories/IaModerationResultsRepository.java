package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaModerationResults;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IaModerationResultsRepository extends JpaRepository<IaModerationResults, UUID> {
    List<IaModerationResults> findByPostId(Integer postId);
    List<IaModerationResults> findByResultado(String resultado);
    boolean existsByPostId(Integer postId);
}
