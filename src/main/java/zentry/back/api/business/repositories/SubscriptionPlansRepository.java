package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.SubscriptionPlans;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SubscriptionPlansRepository extends JpaRepository<SubscriptionPlans, UUID> {

    Optional<SubscriptionPlans> findByName(String name);

    boolean existsByName(String name);

    List<SubscriptionPlans> findByPrecioLessThanEqual(BigDecimal precio);
}
