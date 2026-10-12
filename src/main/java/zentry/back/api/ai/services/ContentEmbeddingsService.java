package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.ContentEmbeddingsRequest;
import zentry.back.api.ai.dtos.ContentEmbeddingsResponse;
import zentry.back.api.ai.models.ContentEmbeddings;
import zentry.back.api.ai.repositories.ContentEmbeddingsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class ContentEmbeddingsService {

    private final ContentEmbeddingsRepository repo;

    public ContentEmbeddingsService(ContentEmbeddingsRepository repo) {
        this.repo = repo;
    }

    public Page<ContentEmbeddingsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public ContentEmbeddingsResponse getById(UUID id) {
        ContentEmbeddings entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentEmbedding not found"));
        return IaMappers.toResponse(entity);
    }

    public ContentEmbeddingsResponse create(ContentEmbeddingsRequest request) {
        ContentEmbeddings entity = ContentEmbeddings.builder()
                .postId(request.getPostId())
                .vector(request.getVector())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public ContentEmbeddingsResponse update(UUID id, ContentEmbeddingsRequest request) {
        ContentEmbeddings entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentEmbedding not found"));
        entity.setPostId(request.getPostId());
        entity.setVector(request.getVector());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        ContentEmbeddings entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentEmbedding not found"));
        repo.delete(entity);
    }
}
