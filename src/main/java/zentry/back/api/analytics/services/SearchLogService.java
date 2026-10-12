package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.SearchLogRequest;
import zentry.back.api.analytics.dtos.SearchLogResponse;
import zentry.back.api.analytics.models.SearchLog;
import zentry.back.api.analytics.repositories.SearchLogRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class SearchLogService {

    private final SearchLogRepository repo;

    public SearchLogService(SearchLogRepository repo) {
        this.repo = repo;
    }

    public Page<SearchLogResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public SearchLogResponse getById(Integer id) {
        SearchLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SearchLog not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public SearchLogResponse create(SearchLogRequest request) {
        SearchLog entity = SearchLog.builder()
                .userId(request.getUserId())
                .query(request.getQuery())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public SearchLogResponse update(Integer id, SearchLogRequest request) {
        SearchLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SearchLog not found"));
        entity.setUserId(request.getUserId());
        entity.setQuery(request.getQuery());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        SearchLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SearchLog not found"));
        repo.delete(entity);
    }
}
