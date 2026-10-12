package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.TagEmbeddingsRequest;
import zentry.back.api.ai.dtos.TagEmbeddingsResponse;
import zentry.back.api.ai.models.TagEmbeddings;
import zentry.back.api.ai.repositories.TagEmbeddingsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class TagEmbeddingsService {

    private final TagEmbeddingsRepository repo;

    public TagEmbeddingsService(TagEmbeddingsRepository repo) {
        this.repo = repo;
    }

    public Page<TagEmbeddingsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public TagEmbeddingsResponse getById(UUID id) {
        TagEmbeddings entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TagEmbedding not found"));
        return IaMappers.toResponse(entity);
    }

    public TagEmbeddingsResponse create(TagEmbeddingsRequest request) {
        TagEmbeddings entity = TagEmbeddings.builder()
                .tagId(request.getTagId())
                .vector(request.getVector())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public TagEmbeddingsResponse update(UUID id, TagEmbeddingsRequest request) {
        TagEmbeddings entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TagEmbedding not found"));
        entity.setTagId(request.getTagId());
        entity.setVector(request.getVector());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        TagEmbeddings entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TagEmbedding not found"));
        repo.delete(entity);
    }
}
