package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Transactions;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface TransactionsRepository extends JpaRepository<Transactions, UUID> {

    List<Transactions> findByUserId(Integer userId);

    Page<Transactions> findByUserId(Integer userId, Pageable pageable);

    List<Transactions> findByAmountGreaterThanEqual(BigDecimal amount);
}
