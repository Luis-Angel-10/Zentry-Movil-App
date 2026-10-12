package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.VoiceSessionRequest;
import zentry.back.api.realtime.dtos.VoiceSessionResponse;
import zentry.back.api.realtime.models.VoiceSession;
import zentry.back.api.realtime.repositories.VoiceSessionRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class VoiceSessionService {

    private final VoiceSessionRepository repo;

    public VoiceSessionService(VoiceSessionRepository repo) {
        this.repo = repo;
    }

    public Page<VoiceSessionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public VoiceSessionResponse getById(Integer id) {
        VoiceSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoiceSession not found"));
        return mappers.toResponse(entity);
    }

    public VoiceSessionResponse create(VoiceSessionRequest request) {
        VoiceSession entity = VoiceSession.builder()
                .startedAt(request.getStartedAt())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public VoiceSessionResponse update(Integer id, VoiceSessionRequest request) {
        VoiceSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoiceSession not found"));
        entity.setStartedAt(request.getStartedAt());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        VoiceSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VoiceSession not found"));
        repo.delete(entity);
    }
}
