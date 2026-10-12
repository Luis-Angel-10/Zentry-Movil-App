
package zentry.back.api.core.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.core.models.StoreItem;
import java.util.List;

@Repository
public interface StoreItemRepository extends JpaRepository<StoreItem, Integer> {
    List<StoreItem> findByType(String type);
}
