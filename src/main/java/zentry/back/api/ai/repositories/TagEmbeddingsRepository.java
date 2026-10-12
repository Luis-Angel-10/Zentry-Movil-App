package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.TagEmbeddings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TagEmbeddingsRepository extends JpaRepository<TagEmbeddings, UUID> {
    List<TagEmbeddings> findByTagId(Integer tagId);
    Optional<TagEmbeddings> findFirstByTagId(Integer tagId);
    boolean existsByTagId(Integer tagId);
}
