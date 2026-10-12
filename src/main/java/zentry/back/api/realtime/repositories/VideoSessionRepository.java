package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.VideoSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VideoSessionRepository extends JpaRepository<VideoSession, Integer> {

}
