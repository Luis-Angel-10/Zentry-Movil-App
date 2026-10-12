package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.PostMediaRequest;
import zentry.back.api.core.dtos.PostMediaResponse;
import zentry.back.api.core.models.PostMedia;
import zentry.back.api.core.repositories.PostMediaRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class PostMediaService {

    private final PostMediaRepository repo;

    public PostMediaService(PostMediaRepository repo) {
        this.repo = repo;
    }

    public Page<PostMediaResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public PostMediaResponse getById(Integer id) {
        PostMedia entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostMedia not found"));
        return CoreMappers.toResponse(entity);
    }

    public PostMediaResponse create(PostMediaRequest request) {
        PostMedia entity = PostMedia.builder()
                .postId(request.getPostId())
                .url(request.getUrl())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public PostMediaResponse update(Integer id, PostMediaRequest request) {
        PostMedia entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostMedia not found"));
        entity.setPostId(request.getPostId());
        entity.setUrl(request.getUrl());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        PostMedia entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostMedia not found"));
        repo.delete(entity);
    }
}
