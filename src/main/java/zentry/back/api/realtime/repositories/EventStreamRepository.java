package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.EventStream;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EventStreamRepository extends JpaRepository<EventStream, Integer> {

}
