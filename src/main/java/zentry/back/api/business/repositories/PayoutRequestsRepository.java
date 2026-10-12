package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.PayoutRequests;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface PayoutRequestsRepository extends JpaRepository<PayoutRequests, UUID> {

    List<PayoutRequests> findByUserId(Integer userId);

    Page<PayoutRequests> findByUserId(Integer userId, Pageable pageable);

    List<PayoutRequests> findByAmountGreaterThanEqual(BigDecimal amount);
}
