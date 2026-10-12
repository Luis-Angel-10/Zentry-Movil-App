package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Payments;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface PaymentsRepository extends JpaRepository<Payments, UUID> {

    List<Payments> findByUserId(Integer userId);

    Page<Payments> findByUserId(Integer userId, Pageable pageable);

    List<Payments> findByPaymentMethodId(UUID paymentMethodId);

    List<Payments> findByAmountGreaterThanEqual(BigDecimal amount);
}
