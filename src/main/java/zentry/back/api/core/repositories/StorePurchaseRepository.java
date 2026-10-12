package zentry.back.api.core.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.core.models.StorePurchase;
import java.util.List;

@Repository
public interface StorePurchaseRepository extends JpaRepository<StorePurchase, Integer> {
    List<StorePurchase> findByUserId(Integer userId);
    boolean existsByUserIdAndStoreItemId(Integer userId, Integer storeItemId);
}
