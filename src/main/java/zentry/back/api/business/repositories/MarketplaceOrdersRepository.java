package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.MarketplaceOrders;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface MarketplaceOrdersRepository extends JpaRepository<MarketplaceOrders, UUID> {

    List<MarketplaceOrders> findByBuyerId(Integer buyerId);

    Page<MarketplaceOrders> findByBuyerId(Integer buyerId, Pageable pageable);

    List<MarketplaceOrders> findByTotalGreaterThanEqual(BigDecimal total);
}
