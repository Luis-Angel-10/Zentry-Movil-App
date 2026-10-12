package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.RealtimeReaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RealtimeReactionRepository extends JpaRepository<RealtimeReaction, Integer> {

}
