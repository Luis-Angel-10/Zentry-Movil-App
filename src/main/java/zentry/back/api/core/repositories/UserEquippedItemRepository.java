package zentry.back.api.core.repositories;

import zentry.back.api.core.models.UserEquippedItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserEquippedItemRepository extends JpaRepository<UserEquippedItem, UserEquippedItem.UserEquippedItemId> {
    List<UserEquippedItem> findByUserId(Integer userId);
    Optional<UserEquippedItem> findByUserIdAndCategory(Integer userId, String category);
}
