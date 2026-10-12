package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.AdsCampaigns;

import java.util.List;
import java.util.UUID;

@Repository
public interface AdsCampaignsRepository extends JpaRepository<AdsCampaigns, UUID> {

    List<AdsCampaigns> findByUserId(Integer userId);

    List<AdsCampaigns> findByNombreContainingIgnoreCase(String nombre);

    boolean existsByUserIdAndNombre(Integer userId, String nombre);

    List<AdsCampaigns> findByIsActiveTrueAndPlacementIn(List<String> placements);
}
