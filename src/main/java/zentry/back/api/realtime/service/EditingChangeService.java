package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.EditingChangeRequest;
import zentry.back.api.realtime.dtos.EditingChangeResponse;
import zentry.back.api.realtime.models.EditingChange;
import zentry.back.api.realtime.repositories.EditingChangeRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class EditingChangeService {

    private final EditingChangeRepository repo;

    public EditingChangeService(EditingChangeRepository repo) {
        this.repo = repo;
    }

    public Page<EditingChangeResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public EditingChangeResponse getById(Integer id) {
        EditingChange entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingChange not found"));
        return mappers.toResponse(entity);
    }

    public EditingChangeResponse create(EditingChangeRequest request) {
        EditingChange entity = EditingChange.builder()
                .sessionId(request.getSessionId())
                .changeData(request.getChangeData())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public EditingChangeResponse update(Integer id, EditingChangeRequest request) {
        EditingChange entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingChange not found"));
        entity.setSessionId(request.getSessionId());
        entity.setChangeData(request.getChangeData());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        EditingChange entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingChange not found"));
        repo.delete(entity);
    }
}
