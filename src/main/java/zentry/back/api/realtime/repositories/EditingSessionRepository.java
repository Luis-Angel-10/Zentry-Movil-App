package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.EditingSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EditingSessionRepository extends JpaRepository<EditingSession, Integer> {

}
