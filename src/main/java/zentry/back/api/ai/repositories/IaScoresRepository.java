package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaScores;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface IaScoresRepository extends JpaRepository<IaScores, UUID> {
    List<IaScores> findByPostId(Integer postId);
    Optional<IaScores> findFirstByPostId(Integer postId);
    List<IaScores> findByScoreGreaterThanEqual(BigDecimal score);
    boolean existsByPostId(Integer postId);
}
