package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaBehaivorAnalitycs;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface IaBehaivorAnalitycsRepository extends JpaRepository<IaBehaivorAnalitycs, UUID> {
    List<IaBehaivorAnalitycs> findByUserId(Integer userId);
    List<IaBehaivorAnalitycs> findByScoreGreaterThanEqual(BigDecimal score);
    List<IaBehaivorAnalitycs> findByScoreLessThan(BigDecimal score);
    boolean existsByUserId(Integer userId);
}
