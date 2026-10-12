package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.ContentEmbeddings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ContentEmbeddingsRepository extends JpaRepository<ContentEmbeddings, UUID> {
    List<ContentEmbeddings> findByPostId(Integer postId);
    Optional<ContentEmbeddings> findFirstByPostId(Integer postId);
    boolean existsByPostId(Integer postId);
}
