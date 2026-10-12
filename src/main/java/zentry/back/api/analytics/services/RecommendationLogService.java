package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.RecommendationLogRequest;
import zentry.back.api.analytics.dtos.RecommendationLogResponse;
import zentry.back.api.analytics.models.RecommendationLog;
import zentry.back.api.analytics.repositories.RecommendationLogRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class RecommendationLogService {

    private final RecommendationLogRepository repo;

    public RecommendationLogService(RecommendationLogRepository repo) {
        this.repo = repo;
    }

    public Page<RecommendationLogResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public RecommendationLogResponse getById(Integer id) {
        RecommendationLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RecommendationLog not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public RecommendationLogResponse create(RecommendationLogRequest request) {
        RecommendationLog entity = RecommendationLog.builder()
                .userId(request.getUserId())
                .recommendations(request.getRecommendations())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public RecommendationLogResponse update(Integer id, RecommendationLogRequest request) {
        RecommendationLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RecommendationLog not found"));
        entity.setUserId(request.getUserId());
        entity.setRecommendations(request.getRecommendations());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        RecommendationLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RecommendationLog not found"));
        repo.delete(entity);
    }
}
