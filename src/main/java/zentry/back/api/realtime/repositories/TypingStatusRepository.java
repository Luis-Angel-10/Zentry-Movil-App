package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.TypingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TypingStatusRepository extends JpaRepository<TypingStatus, TypingStatus.TypingStatusId> {

}
