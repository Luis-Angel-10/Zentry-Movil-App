package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.SearchClick;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SearchClickRepository extends JpaRepository<SearchClick, Integer> {
   
}
