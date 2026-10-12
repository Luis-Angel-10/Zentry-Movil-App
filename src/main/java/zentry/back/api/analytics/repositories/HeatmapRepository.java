package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.Heatmap;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HeatmapRepository extends JpaRepository<Heatmap, Integer> {
   
}
