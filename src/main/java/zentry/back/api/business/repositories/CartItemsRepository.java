package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.CartItems;
import zentry.back.api.business.models.CartItems.CartItemsId;

import java.util.List;
import java.util.UUID;

@Repository
public interface CartItemsRepository extends JpaRepository<CartItems, CartItemsId> {

    List<CartItems> findByCartId(UUID cartId);

    List<CartItems> findByProductId(UUID productId);

    boolean existsByCartIdAndProductId(UUID cartId, UUID productId);

    void deleteByCartId(UUID cartId);
}
