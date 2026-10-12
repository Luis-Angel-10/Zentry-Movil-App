package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.SessionTrackingRequest;
import zentry.back.api.analytics.dtos.SessionTrackingResponse;
import zentry.back.api.analytics.models.SessionTracking;
import zentry.back.api.analytics.repositories.SessionTrackingRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class SessionTrackingService {

    private final SessionTrackingRepository repo;

    public SessionTrackingService(SessionTrackingRepository repo) {
        this.repo = repo;
    }

    public Page<SessionTrackingResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public SessionTrackingResponse getById(Integer id) {
        SessionTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SessionTracking not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public SessionTrackingResponse create(SessionTrackingRequest request) {
        SessionTracking entity = SessionTracking.builder()
                .userId(request.getUserId())
                .sessionStart(request.getSessionStart())
                .sessionEnd(request.getSessionEnd())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public SessionTrackingResponse update(Integer id, SessionTrackingRequest request) {
        SessionTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SessionTracking not found"));
        entity.setUserId(request.getUserId());
        entity.setSessionStart(request.getSessionStart());
        entity.setSessionEnd(request.getSessionEnd());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        SessionTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SessionTracking not found"));
        repo.delete(entity);
    }
}
