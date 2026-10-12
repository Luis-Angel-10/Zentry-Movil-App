package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.RetentionData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RetentionDataRepository extends JpaRepository<RetentionData, Integer> {
   
}
