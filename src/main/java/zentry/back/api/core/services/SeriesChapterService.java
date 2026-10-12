package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.SeriesChapterRequest;
import zentry.back.api.core.dtos.SeriesChapterResponse;
import zentry.back.api.core.models.SeriesChapter;
import zentry.back.api.core.repositories.SeriesChapterRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class SeriesChapterService {

    private final SeriesChapterRepository repo;

    public SeriesChapterService(SeriesChapterRepository repo) {
        this.repo = repo;
    }

    public Page<SeriesChapterResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public SeriesChapterResponse getById(Integer id) {
        SeriesChapter entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SeriesChapter not found"));
        return CoreMappers.toResponse(entity);
    }

    public SeriesChapterResponse create(SeriesChapterRequest request) {
        SeriesChapter entity = SeriesChapter.builder()
                .seriesId(request.getSeriesId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public SeriesChapterResponse update(Integer id, SeriesChapterRequest request) {
        SeriesChapter entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SeriesChapter not found"));
        entity.setSeriesId(request.getSeriesId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        SeriesChapter entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SeriesChapter not found"));
        repo.delete(entity);
    }
}
