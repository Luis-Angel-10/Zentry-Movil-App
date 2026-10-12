package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.ErrorTrackingRequest;
import zentry.back.api.analytics.dtos.ErrorTrackingResponse;
import zentry.back.api.analytics.models.ErrorTracking;
import zentry.back.api.analytics.repositories.ErrorTrackingRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class ErrorTrackingService {

    private final ErrorTrackingRepository repo;

    public ErrorTrackingService(ErrorTrackingRepository repo) {
        this.repo = repo;
    }

    public Page<ErrorTrackingResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public ErrorTrackingResponse getById(Integer id) {
        ErrorTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ErrorTracking not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public ErrorTrackingResponse create(ErrorTrackingRequest request) {
        ErrorTracking entity = ErrorTracking.builder()
                .error(request.getError())
                .stackTrace(request.getStackTrace())
                .userId(request.getUserId())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public ErrorTrackingResponse update(Integer id, ErrorTrackingRequest request) {
        ErrorTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ErrorTracking not found"));
        entity.setError(request.getError());
        entity.setStackTrace(request.getStackTrace());
        entity.setUserId(request.getUserId());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        ErrorTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ErrorTracking not found"));
        repo.delete(entity);
    }
}
