package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.ErrorTracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ErrorTrackingRepository extends JpaRepository<ErrorTracking, Integer> {
   
}
