package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.TagRequest;
import zentry.back.api.core.dtos.TagResponse;
import zentry.back.api.core.models.Tag;
import zentry.back.api.core.repositories.TagRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class TagService {

    private final TagRepository repo;

    public TagService(TagRepository repo) {
        this.repo = repo;
    }

    public Page<TagResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public TagResponse getById(Integer id) {
        Tag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Tag not found"));
        return CoreMappers.toResponse(entity);
    }

    public TagResponse create(TagRequest request) {
        Tag entity = Tag.builder()
                .nombre(request.getNombre())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public TagResponse update(Integer id, TagRequest request) {
        Tag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Tag not found"));
        entity.setNombre(request.getNombre());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Tag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Tag not found"));
        repo.delete(entity);
    }
}
