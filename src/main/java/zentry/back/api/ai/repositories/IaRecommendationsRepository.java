package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaRecommendations;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface IaRecommendationsRepository extends JpaRepository<IaRecommendations, UUID> {
    List<IaRecommendations> findByUserId(Integer userId);
    Page<IaRecommendations> findByUserId(Integer userId, Pageable pageable);
    List<IaRecommendations> findByContenidoId(Integer contenidoId);
    List<IaRecommendations> findByScoreGreaterThanEqual(BigDecimal score);
    boolean existsByUserIdAndContenidoId(Integer userId, Integer contenidoId);
}
