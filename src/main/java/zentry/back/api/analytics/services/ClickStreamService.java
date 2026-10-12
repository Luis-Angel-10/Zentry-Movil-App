package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.ClickStreamRequest;
import zentry.back.api.analytics.dtos.ClickStreamResponse;
import zentry.back.api.analytics.models.ClickStream;
import zentry.back.api.analytics.repositories.ClickStreamRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class ClickStreamService {

    private final ClickStreamRepository repo;

    public ClickStreamService(ClickStreamRepository repo) {
        this.repo = repo;
    }

    public Page<ClickStreamResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public ClickStreamResponse getById(Integer id) {
        ClickStream entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ClickStream not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public ClickStreamResponse create(ClickStreamRequest request) {
        ClickStream entity = ClickStream.builder()
                .userId(request.getUserId())
                .element(request.getElement())
                .page(request.getPage())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public ClickStreamResponse update(Integer id, ClickStreamRequest request) {
        ClickStream entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ClickStream not found"));
        entity.setUserId(request.getUserId());
        entity.setElement(request.getElement());
        entity.setPage(request.getPage());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        ClickStream entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ClickStream not found"));
        repo.delete(entity);
    }
}
