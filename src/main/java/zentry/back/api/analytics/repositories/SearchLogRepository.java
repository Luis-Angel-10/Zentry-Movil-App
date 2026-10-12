package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.SearchLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SearchLogRepository extends JpaRepository<SearchLog, Integer> {
   
}
