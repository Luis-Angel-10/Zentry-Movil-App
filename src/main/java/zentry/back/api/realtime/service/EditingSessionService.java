package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.EditingSessionRequest;
import zentry.back.api.realtime.dtos.EditingSessionResponse;
import zentry.back.api.realtime.models.EditingSession;
import zentry.back.api.realtime.repositories.EditingSessionRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class EditingSessionService {

    private final EditingSessionRepository repo;

    public EditingSessionService(EditingSessionRepository repo) {
        this.repo = repo;
    }

    public Page<EditingSessionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public EditingSessionResponse getById(Integer id) {
        EditingSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingSession not found"));
        return mappers.toResponse(entity);
    }

    public EditingSessionResponse create(EditingSessionRequest request) {
        EditingSession entity = EditingSession.builder()
                .docId(request.getDocId())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public EditingSessionResponse update(Integer id, EditingSessionRequest request) {
        EditingSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingSession not found"));
        entity.setDocId(request.getDocId());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        EditingSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingSession not found"));
        repo.delete(entity);
    }
}
