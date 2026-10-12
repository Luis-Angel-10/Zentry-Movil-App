package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Payouts;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface PayoutsRepository extends JpaRepository<Payouts, UUID> {

    List<Payouts> findByUserId(Integer userId);

    Page<Payouts> findByUserId(Integer userId, Pageable pageable);

    List<Payouts> findByAmountGreaterThanEqual(BigDecimal amount);
}
