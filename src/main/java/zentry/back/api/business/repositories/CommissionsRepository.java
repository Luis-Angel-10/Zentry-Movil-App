package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Commissions;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface CommissionsRepository extends JpaRepository<Commissions, UUID> {

    List<Commissions> findByPorcentajeLessThanEqual(BigDecimal porcentaje);

    List<Commissions> findByPorcentajeGreaterThanEqual(BigDecimal porcentaje);
}
