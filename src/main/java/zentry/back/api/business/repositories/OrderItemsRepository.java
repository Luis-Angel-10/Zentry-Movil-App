package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.OrderItems;
import zentry.back.api.business.models.OrderItems.OrderItemsId;

import java.util.List;
import java.util.UUID;

@Repository
public interface OrderItemsRepository extends JpaRepository<OrderItems, OrderItemsId> {

    List<OrderItems> findByOrderId(UUID orderId);

    List<OrderItems> findByProductId(UUID productId);

    boolean existsByOrderIdAndProductId(UUID orderId, UUID productId);

    void deleteByOrderId(UUID orderId);
}
