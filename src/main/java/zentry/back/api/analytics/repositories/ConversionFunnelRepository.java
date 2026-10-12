package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.ConversionFunnel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ConversionFunnelRepository extends JpaRepository<ConversionFunnel, Integer> {
   
}
