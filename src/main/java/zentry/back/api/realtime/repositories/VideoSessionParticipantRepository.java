package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.VideoSessionParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VideoSessionParticipantRepository extends JpaRepository<VideoSessionParticipant, VideoSessionParticipant.VideoSessionParticipantId> {

}
