package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.DataLakeEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DataLakeEventRepository extends JpaRepository<DataLakeEvent, Integer> {
   
}
