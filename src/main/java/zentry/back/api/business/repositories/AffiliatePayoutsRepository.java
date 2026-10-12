package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.AffiliatePayouts;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface AffiliatePayoutsRepository extends JpaRepository<AffiliatePayouts, UUID> {

    List<AffiliatePayouts> findByAffiliateId(UUID affiliateId);

    Page<AffiliatePayouts> findByAffiliateId(UUID affiliateId, Pageable pageable);

    List<AffiliatePayouts> findByAmountGreaterThanEqual(BigDecimal amount);
}
