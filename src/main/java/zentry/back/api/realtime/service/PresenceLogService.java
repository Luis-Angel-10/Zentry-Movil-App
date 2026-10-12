package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.PresenceLogRequest;
import zentry.back.api.realtime.dtos.PresenceLogResponse;
import zentry.back.api.realtime.models.PresenceLog;
import zentry.back.api.realtime.repositories.PresenceLogRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class PresenceLogService {

    private final PresenceLogRepository repo;

    public PresenceLogService(PresenceLogRepository repo) {
        this.repo = repo;
    }

    public Page<PresenceLogResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public PresenceLogResponse getById(Integer id) {
        PresenceLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PresenceLog not found"));
        return mappers.toResponse(entity);
    }

    public PresenceLogResponse create(PresenceLogRequest request) {
        PresenceLog entity = PresenceLog.builder()
                .userId(request.getUserId())
                .status(request.getStatus())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public PresenceLogResponse update(Integer id, PresenceLogRequest request) {
        PresenceLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PresenceLog not found"));
        entity.setUserId(request.getUserId());
        entity.setStatus(request.getStatus());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        PresenceLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PresenceLog not found"));
        repo.delete(entity);
    }
}
