package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.WalletTransactions;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface WalletTransactionsRepository extends JpaRepository<WalletTransactions, UUID> {

    List<WalletTransactions> findByUserId(Integer userId);

    Page<WalletTransactions> findByUserId(Integer userId, Pageable pageable);

    List<WalletTransactions> findByAmountGreaterThanEqual(BigDecimal amount);
}
