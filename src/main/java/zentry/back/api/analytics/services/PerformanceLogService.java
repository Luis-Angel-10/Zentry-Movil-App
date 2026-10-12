package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.PerformanceLogRequest;
import zentry.back.api.analytics.dtos.PerformanceLogResponse;
import zentry.back.api.analytics.models.PerformanceLog;
import zentry.back.api.analytics.repositories.PerformanceLogRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class PerformanceLogService {

    private final PerformanceLogRepository repo;

    public PerformanceLogService(PerformanceLogRepository repo) {
        this.repo = repo;
    }

    public Page<PerformanceLogResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public PerformanceLogResponse getById(Integer id) {
        PerformanceLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PerformanceLog not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public PerformanceLogResponse create(PerformanceLogRequest request) {
        PerformanceLog entity = PerformanceLog.builder()
                .metric(request.getMetric())
                .value(request.getValue())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public PerformanceLogResponse update(Integer id, PerformanceLogRequest request) {
        PerformanceLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PerformanceLog not found"));
        entity.setMetric(request.getMetric());
        entity.setValue(request.getValue());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        PerformanceLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PerformanceLog not found"));
        repo.delete(entity);
    }
}
