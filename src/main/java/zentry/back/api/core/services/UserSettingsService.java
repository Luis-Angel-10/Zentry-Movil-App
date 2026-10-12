package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.UserSettingsRequest;
import zentry.back.api.core.dtos.UserSettingsResponse;
import zentry.back.api.core.models.UserSettings;
import zentry.back.api.core.repositories.UserSettingsRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class UserSettingsService {

    private final UserSettingsRepository repo;

    public UserSettingsService(UserSettingsRepository repo) {
        this.repo = repo;
    }

    public Page<UserSettingsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public UserSettingsResponse getById(Integer userId) {
        UserSettings entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSettings not found"));
        return CoreMappers.toResponse(entity);
    }

    public UserSettingsResponse create(UserSettingsRequest request) {
        if (repo.existsById(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "UserSettings already exists for this user");
        }
        UserSettings entity = UserSettings.builder()
                .userId(request.getUserId())
                .privacidad(request.getPrivacidad())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public UserSettingsResponse update(Integer userId, UserSettingsRequest request) {
        UserSettings entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSettings not found"));
        entity.setPrivacidad(request.getPrivacidad());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer userId) {
        UserSettings entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSettings not found"));
        repo.delete(entity);
    }
}
