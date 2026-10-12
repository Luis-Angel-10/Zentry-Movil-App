package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.PostVersionRequest;
import zentry.back.api.core.dtos.PostVersionResponse;
import zentry.back.api.core.models.PostVersion;
import zentry.back.api.core.repositories.PostVersionRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class PostVersionService {

    private final PostVersionRepository repo;

    public PostVersionService(PostVersionRepository repo) {
        this.repo = repo;
    }

    public Page<PostVersionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public PostVersionResponse getById(Integer id) {
        PostVersion entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostVersion not found"));
        return CoreMappers.toResponse(entity);
    }

    public PostVersionResponse create(PostVersionRequest request) {
        PostVersion entity = PostVersion.builder()
                .postId(request.getPostId())
                .contenido(request.getContenido())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public PostVersionResponse update(Integer id, PostVersionRequest request) {
        PostVersion entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostVersion not found"));
        entity.setPostId(request.getPostId());
        entity.setContenido(request.getContenido());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        PostVersion entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostVersion not found"));
        repo.delete(entity);
    }
}
