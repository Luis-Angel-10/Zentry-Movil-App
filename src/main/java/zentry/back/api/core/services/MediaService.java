package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.MediaRequest;
import zentry.back.api.core.dtos.MediaResponse;
import zentry.back.api.core.models.Media;
import zentry.back.api.core.repositories.MediaRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class MediaService {

    private final MediaRepository repo;

    public MediaService(MediaRepository repo) {
        this.repo = repo;
    }

    public Page<MediaResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public MediaResponse getById(Integer id) {
        Media entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Media not found"));
        return CoreMappers.toResponse(entity);
    }

    public MediaResponse create(MediaRequest request) {
        Media entity = Media.builder()
                .postId(request.getPostId())
                .url(request.getUrl())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public MediaResponse update(Integer id, MediaRequest request) {
        Media entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Media not found"));
        entity.setPostId(request.getPostId());
        entity.setUrl(request.getUrl());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Media entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Media not found"));
        repo.delete(entity);
    }
}
