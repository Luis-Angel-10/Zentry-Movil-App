package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.PresenceLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PresenceLogRepository extends JpaRepository<PresenceLog, Integer> {

}
