package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.VoiceSessionParticipantRequest;
import zentry.back.api.realtime.dtos.VoiceSessionParticipantResponse;
import zentry.back.api.realtime.models.VoiceSessionParticipant;
import zentry.back.api.realtime.models.VoiceSessionParticipant.VoiceSessionParticipantId;
import zentry.back.api.realtime.repositories.VoiceSessionParticipantRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class VoiceSessionParticipantService {

    private final VoiceSessionParticipantRepository repo;

    public VoiceSessionParticipantService(VoiceSessionParticipantRepository repo) {
        this.repo = repo;
    }

    public Page<VoiceSessionParticipantResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public VoiceSessionParticipantResponse getById(Integer sessionId, Integer userId) {
        VoiceSessionParticipantId id = new VoiceSessionParticipantId(sessionId, userId);
        VoiceSessionParticipant entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoiceSessionParticipant not found"));
        return mappers.toResponse(entity);
    }

    public VoiceSessionParticipantResponse create(VoiceSessionParticipantRequest request) {
        VoiceSessionParticipantId id = new VoiceSessionParticipantId(request.getSessionId(), request.getUserId());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "VoiceSessionParticipant already exists");
        }
        VoiceSessionParticipant entity = VoiceSessionParticipant.builder()
                .sessionId(request.getSessionId())
                .userId(request.getUserId())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer sessionId, Integer userId) {
        VoiceSessionParticipantId id = new VoiceSessionParticipantId(sessionId, userId);
        VoiceSessionParticipant entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoiceSessionParticipant not found"));
        repo.delete(entity);
    }
}
