package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.UserPreferencesRequest;
import zentry.back.api.core.dtos.UserPreferencesResponse;
import zentry.back.api.core.models.UserPreferences;
import zentry.back.api.core.repositories.UserPreferencesRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class UserPreferencesService {

    private final UserPreferencesRepository repo;

    public UserPreferencesService(UserPreferencesRepository repo) {
        this.repo = repo;
    }

    public Page<UserPreferencesResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public UserPreferencesResponse getById(Integer userId) {
        UserPreferences entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserPreferences not found"));
        return CoreMappers.toResponse(entity);
    }

    public UserPreferencesResponse create(UserPreferencesRequest request) {
        if (repo.existsById(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "UserPreferences already exists for this user");
        }
        UserPreferences entity = UserPreferences.builder()
                .userId(request.getUserId())
                .config(request.getConfig())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public UserPreferencesResponse update(Integer userId, UserPreferencesRequest request) {
        UserPreferences entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserPreferences not found"));
        entity.setConfig(request.getConfig());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer userId) {
        UserPreferences entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserPreferences not found"));
        repo.delete(entity);
    }
}
