package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.UserSessionRequest;
import zentry.back.api.core.dtos.UserSessionResponse;
import zentry.back.api.core.models.UserSession;
import zentry.back.api.core.repositories.UserSessionRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class UserSessionService {

    private final UserSessionRepository repo;

    public UserSessionService(UserSessionRepository repo) {
        this.repo = repo;
    }

    public Page<UserSessionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public UserSessionResponse getById(Integer id) {
        UserSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSession not found"));
        return CoreMappers.toResponse(entity);
    }

    public UserSessionResponse create(UserSessionRequest request) {
        UserSession entity = UserSession.builder()
                .userId(request.getUserId())
                .token(request.getToken())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public UserSessionResponse update(Integer id, UserSessionRequest request) {
        UserSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSession not found"));
        entity.setUserId(request.getUserId());
        entity.setToken(request.getToken());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        UserSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSession not found"));
        repo.delete(entity);
    }
}
