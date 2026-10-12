package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.FeatureUsageRequest;
import zentry.back.api.analytics.dtos.FeatureUsageResponse;
import zentry.back.api.analytics.models.FeatureUsage;
import zentry.back.api.analytics.repositories.FeatureUsageRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class FeatureUsageService {

    private final FeatureUsageRepository repo;

    public FeatureUsageService(FeatureUsageRepository repo) {
        this.repo = repo;
    }

    public Page<FeatureUsageResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public FeatureUsageResponse getById(Integer id) {
        FeatureUsage entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeatureUsage not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public FeatureUsageResponse create(FeatureUsageRequest request) {
        FeatureUsage entity = FeatureUsage.builder()
                .feature(request.getFeature())
                .usageCount(request.getUsageCount())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public FeatureUsageResponse update(Integer id, FeatureUsageRequest request) {
        FeatureUsage entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeatureUsage not found"));
        entity.setFeature(request.getFeature());
        entity.setUsageCount(request.getUsageCount());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        FeatureUsage entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeatureUsage not found"));
        repo.delete(entity);
    }
}
