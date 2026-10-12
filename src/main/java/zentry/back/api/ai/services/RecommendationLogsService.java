package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.RecommendationLogsRequest;
import zentry.back.api.ai.dtos.RecommendationLogsResponse;
import zentry.back.api.ai.models.RecommendationLogs;
import zentry.back.api.ai.repositories.RecommendationLogsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class RecommendationLogsService {

    private final RecommendationLogsRepository repo;

    public RecommendationLogsService(RecommendationLogsRepository repo) {
        this.repo = repo;
    }

    public Page<RecommendationLogsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public RecommendationLogsResponse getById(UUID id) {
        RecommendationLogs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RecommendationLog not found"));
        return IaMappers.toResponse(entity);
    }

    public RecommendationLogsResponse create(RecommendationLogsRequest request) {
        RecommendationLogs entity = RecommendationLogs.builder()
                .recommendationId(request.getRecommendationId())
                .timestamp(request.getTimestamp())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public RecommendationLogsResponse update(UUID id, RecommendationLogsRequest request) {
        RecommendationLogs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RecommendationLog not found"));
        entity.setRecommendationId(request.getRecommendationId());
        entity.setTimestamp(request.getTimestamp());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        RecommendationLogs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RecommendationLog not found"));
        repo.delete(entity);
    }
}
