package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.ScrollTracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ScrollTrackingRepository extends JpaRepository<ScrollTracking, Integer> {
   
}
