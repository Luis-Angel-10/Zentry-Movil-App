package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.CollabLiveUpdate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CollabLiveUpdateRepository extends JpaRepository<CollabLiveUpdate, Integer> {

}
