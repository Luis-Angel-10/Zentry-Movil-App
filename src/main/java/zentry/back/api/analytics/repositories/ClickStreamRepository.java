package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.ClickStream;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClickStreamRepository extends JpaRepository<ClickStream, Integer> {
   
}
