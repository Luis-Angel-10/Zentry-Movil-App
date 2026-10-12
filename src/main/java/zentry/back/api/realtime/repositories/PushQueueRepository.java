package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.PushQueue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PushQueueRepository extends JpaRepository<PushQueue, Integer> {

}
