package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.ContentPerformanceRequest;
import zentry.back.api.analytics.dtos.ContentPerformanceResponse;
import zentry.back.api.analytics.models.ContentPerformance;
import zentry.back.api.analytics.repositories.ContentPerformanceRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class ContentPerformanceService {

    private final ContentPerformanceRepository repo;

    public ContentPerformanceService(ContentPerformanceRepository repo) {
        this.repo = repo;
    }

    public Page<ContentPerformanceResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public ContentPerformanceResponse getById(Integer id) {
        ContentPerformance entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentPerformance not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public ContentPerformanceResponse create(ContentPerformanceRequest request) {
        ContentPerformance entity = ContentPerformance.builder()
                .postId(request.getPostId())
                .views(request.getViews())
                .likes(request.getLikes())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public ContentPerformanceResponse update(Integer id, ContentPerformanceRequest request) {
        ContentPerformance entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentPerformance not found"));
        entity.setPostId(request.getPostId());
        entity.setViews(request.getViews());
        entity.setLikes(request.getLikes());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        ContentPerformance entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentPerformance not found"));
        repo.delete(entity);
    }
}
