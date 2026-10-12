package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.CommunityEmbeddings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CommunityEmbeddingsRepository extends JpaRepository<CommunityEmbeddings, UUID> {
    List<CommunityEmbeddings> findByCommunityId(Integer communityId);
    boolean existsByCommunityId(Integer communityId);
}
