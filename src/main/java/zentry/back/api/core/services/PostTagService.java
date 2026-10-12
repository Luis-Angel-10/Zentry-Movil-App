package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.PostTagRequest;
import zentry.back.api.core.dtos.PostTagResponse;
import zentry.back.api.core.models.PostTag;
import zentry.back.api.core.models.PostTag.PostTagId;
import zentry.back.api.core.repositories.PostTagRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class PostTagService {

    private final PostTagRepository repo;

    public PostTagService(PostTagRepository repo) {
        this.repo = repo;
    }

    public Page<PostTagResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public PostTagResponse getById(Integer postId, Integer tagId) {
        PostTagId id = new PostTagId(postId, tagId);
        PostTag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostTag not found"));
        return CoreMappers.toResponse(entity);
    }

    public PostTagResponse create(PostTagRequest request) {
        PostTagId id = new PostTagId(request.getPostId(), request.getTagId());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "PostTag already exists");
        }
        PostTag entity = PostTag.builder()
                .postId(request.getPostId())
                .tagId(request.getTagId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer postId, Integer tagId) {
        PostTagId id = new PostTagId(postId, tagId);
        PostTag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PostTag not found"));
        repo.delete(entity);
    }
}
