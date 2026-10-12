package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.SeriesRequest;
import zentry.back.api.core.dtos.SeriesResponse;
import zentry.back.api.core.models.Series;
import zentry.back.api.core.repositories.SeriesRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class SeriesService {

    private final SeriesRepository repo;

    public SeriesService(SeriesRepository repo) {
        this.repo = repo;
    }

    public Page<SeriesResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public SeriesResponse getById(Integer id) {
        Series entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Series not found"));
        return CoreMappers.toResponse(entity);
    }

    public SeriesResponse create(SeriesRequest request) {
        Series entity = Series.builder()
                .userId(request.getUserId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public SeriesResponse update(Integer id, SeriesRequest request) {
        Series entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Series not found"));
        entity.setUserId(request.getUserId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Series entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Series not found"));
        repo.delete(entity);
    }
}
