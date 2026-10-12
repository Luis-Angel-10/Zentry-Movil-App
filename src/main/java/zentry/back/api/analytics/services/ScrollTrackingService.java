package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.ScrollTrackingRequest;
import zentry.back.api.analytics.dtos.ScrollTrackingResponse;
import zentry.back.api.analytics.models.ScrollTracking;
import zentry.back.api.analytics.repositories.ScrollTrackingRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class ScrollTrackingService {

    private final ScrollTrackingRepository repo;

    public ScrollTrackingService(ScrollTrackingRepository repo) {
        this.repo = repo;
    }

    public Page<ScrollTrackingResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public ScrollTrackingResponse getById(Integer id) {
        ScrollTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ScrollTracking not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public ScrollTrackingResponse create(ScrollTrackingRequest request) {
        ScrollTracking entity = ScrollTracking.builder()
                .userId(request.getUserId())
                .page(request.getPage())
                .depth(request.getDepth())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public ScrollTrackingResponse update(Integer id, ScrollTrackingRequest request) {
        ScrollTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ScrollTracking not found"));
        entity.setUserId(request.getUserId());
        entity.setPage(request.getPage());
        entity.setDepth(request.getDepth());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        ScrollTracking entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ScrollTracking not found"));
        repo.delete(entity);
    }
}
