package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.EditingSessionUserRequest;
import zentry.back.api.realtime.dtos.EditingSessionUserResponse;
import zentry.back.api.realtime.models.EditingSessionUser;
import zentry.back.api.realtime.models.EditingSessionUser.EditingSessionUserId;
import zentry.back.api.realtime.repositories.EditingSessionUserRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class EditingSessionUserService {

    private final EditingSessionUserRepository repo;

    public EditingSessionUserService(EditingSessionUserRepository repo) {
        this.repo = repo;
    }

    public Page<EditingSessionUserResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public EditingSessionUserResponse getById(Integer sessionId, Integer userId) {
        EditingSessionUserId id = new EditingSessionUserId(sessionId, userId);
        EditingSessionUser entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingSessionUser not found"));
        return mappers.toResponse(entity);
    }

    public EditingSessionUserResponse create(EditingSessionUserRequest request) {
        EditingSessionUserId id = new EditingSessionUserId(request.getSessionId(), request.getUserId());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "EditingSessionUser already exists");
        }
        EditingSessionUser entity = EditingSessionUser.builder()
                .sessionId(request.getSessionId())
                .userId(request.getUserId())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer sessionId, Integer userId) {
        EditingSessionUserId id = new EditingSessionUserId(sessionId, userId);
        EditingSessionUser entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EditingSessionUser not found"));
        repo.delete(entity);
    }
}
