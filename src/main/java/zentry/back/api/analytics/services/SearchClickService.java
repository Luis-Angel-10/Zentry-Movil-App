package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.SearchClickRequest;
import zentry.back.api.analytics.dtos.SearchClickResponse;
import zentry.back.api.analytics.models.SearchClick;
import zentry.back.api.analytics.repositories.SearchClickRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class SearchClickService {

    private final SearchClickRepository repo;

    public SearchClickService(SearchClickRepository repo) {
        this.repo = repo;
    }

    public Page<SearchClickResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public SearchClickResponse getById(Integer id) {
        SearchClick entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SearchClick not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public SearchClickResponse create(SearchClickRequest request) {
        SearchClick entity = SearchClick.builder()
                .searchLogId(request.getSearchLogId())
                .resultClicked(request.getResultClicked())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public SearchClickResponse update(Integer id, SearchClickRequest request) {
        SearchClick entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SearchClick not found"));
        entity.setSearchLogId(request.getSearchLogId());
        entity.setResultClicked(request.getResultClicked());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        SearchClick entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SearchClick not found"));
        repo.delete(entity);
    }
}
