package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.ApiLogRequest;
import zentry.back.api.analytics.dtos.ApiLogResponse;
import zentry.back.api.analytics.models.ApiLog;
import zentry.back.api.analytics.repositories.ApiLogRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class ApiLogService {

    private final ApiLogRepository repo;

    public ApiLogService(ApiLogRepository repo) {
        this.repo = repo;
    }

    public Page<ApiLogResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public ApiLogResponse getById(Integer id) {
        ApiLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ApiLog not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public ApiLogResponse create(ApiLogRequest request) {
        ApiLog entity = ApiLog.builder()
                .endpoint(request.getEndpoint())
                .method(request.getMethod())
                .responseTime(request.getResponseTime())
                .statusCode(request.getStatusCode())
                .userId(request.getUserId())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public ApiLogResponse update(Integer id, ApiLogRequest request) {
        ApiLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ApiLog not found"));
        entity.setEndpoint(request.getEndpoint());
        entity.setMethod(request.getMethod());
        entity.setResponseTime(request.getResponseTime());
        entity.setStatusCode(request.getStatusCode());
        entity.setUserId(request.getUserId());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        ApiLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ApiLog not found"));
        repo.delete(entity);
    }
}
