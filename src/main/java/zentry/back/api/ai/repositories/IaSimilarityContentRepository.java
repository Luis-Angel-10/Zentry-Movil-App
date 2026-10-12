package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaSimilarityContent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface IaSimilarityContentRepository extends JpaRepository<IaSimilarityContent, UUID> {
    List<IaSimilarityContent> findByPostId1(Integer postId1);
    List<IaSimilarityContent> findByPostId2(Integer postId2);
    List<IaSimilarityContent> findByPostId1OrPostId2(Integer postId1, Integer postId2);
    List<IaSimilarityContent> findByScoreGreaterThanEqual(BigDecimal score);
    boolean existsByPostId1AndPostId2(Integer postId1, Integer postId2);
}
