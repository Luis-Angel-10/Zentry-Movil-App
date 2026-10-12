package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.AdImpressions;

import java.util.List;
import java.util.UUID;

@Repository
public interface AdImpressionsRepository extends JpaRepository<AdImpressions, UUID> {

    List<AdImpressions> findByCampaignId(UUID campaignId);

    List<AdImpressions> findByVistasGreaterThanEqual(Integer vistas);

    boolean existsByCampaignId(UUID campaignId);
}
