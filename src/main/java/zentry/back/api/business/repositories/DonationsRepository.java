package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Donations;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface DonationsRepository extends JpaRepository<Donations, UUID> {

    List<Donations> findByUserId(Integer userId);

    Page<Donations> findByUserId(Integer userId, Pageable pageable);

    List<Donations> findByAmountGreaterThanEqual(BigDecimal amount);
}
