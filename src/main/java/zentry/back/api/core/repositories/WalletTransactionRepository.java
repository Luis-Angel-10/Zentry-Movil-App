package zentry.back.api.core.repositories;

import zentry.back.api.core.models.WalletTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {

    List<WalletTransaction> findByUsernameOrderByCreatedAtDesc(String username);
}
