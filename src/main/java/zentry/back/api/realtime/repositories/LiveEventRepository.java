package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.LiveEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LiveEventRepository extends JpaRepository<LiveEvent, Integer> {

}
