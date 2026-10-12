package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.UserBehaviorRequest;
import zentry.back.api.analytics.dtos.UserBehaviorResponse;
import zentry.back.api.analytics.models.UserBehavior;
import zentry.back.api.analytics.repositories.UserBehaviorRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class UserBehaviorService {

    private final UserBehaviorRepository repo;

    public UserBehaviorService(UserBehaviorRepository repo) {
        this.repo = repo;
    }

    public Page<UserBehaviorResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public UserBehaviorResponse getById(Integer id) {
        UserBehavior entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserBehavior not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public UserBehaviorResponse create(UserBehaviorRequest request) {
        UserBehavior entity = UserBehavior.builder()
                .userId(request.getUserId())
                .type(request.getType())
                .metadata(request.getMetadata())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public UserBehaviorResponse update(Integer id, UserBehaviorRequest request) {
        UserBehavior entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserBehavior not found"));
        entity.setUserId(request.getUserId());
        entity.setType(request.getType());
        entity.setMetadata(request.getMetadata());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        UserBehavior entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserBehavior not found"));
        repo.delete(entity);
    }
}
