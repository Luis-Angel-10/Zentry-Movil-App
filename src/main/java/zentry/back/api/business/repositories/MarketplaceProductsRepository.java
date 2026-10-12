package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.MarketplaceProducts;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface MarketplaceProductsRepository extends JpaRepository<MarketplaceProducts, UUID> {

    List<MarketplaceProducts> findBySellerId(Integer sellerId);

    List<MarketplaceProducts> findByNombreContainingIgnoreCase(String nombre);

    List<MarketplaceProducts> findByPrecioLessThanEqual(BigDecimal precio);

    boolean existsBySellerIdAndNombre(Integer sellerId, String nombre);
}
