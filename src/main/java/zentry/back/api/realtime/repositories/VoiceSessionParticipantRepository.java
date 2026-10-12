package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.VoiceSessionParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VoiceSessionParticipantRepository extends JpaRepository<VoiceSessionParticipant, VoiceSessionParticipant.VoiceSessionParticipantId> {

}
