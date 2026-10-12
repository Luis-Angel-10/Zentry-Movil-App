package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.StreamEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StreamEventRepository extends JpaRepository<StreamEvent, Integer> {

}
