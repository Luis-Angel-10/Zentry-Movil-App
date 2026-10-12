package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaSimilarityContentRequest;
import zentry.back.api.ai.dtos.IaSimilarityContentResponse;
import zentry.back.api.ai.models.IaSimilarityContent;
import zentry.back.api.ai.repositories.IaSimilarityContentRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaSimilarityContentService {

    private final IaSimilarityContentRepository repo;

    public IaSimilarityContentService(IaSimilarityContentRepository repo) {
        this.repo = repo;
    }

    public Page<IaSimilarityContentResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaSimilarityContentResponse getById(UUID id) {
        IaSimilarityContent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SimilarityContent not found"));
        return IaMappers.toResponse(entity);
    }

    public IaSimilarityContentResponse create(IaSimilarityContentRequest request) {
        if (repo.existsByPostId1AndPostId2(request.getPostId1(), request.getPostId2())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Similarity record already exists for these posts");
        }
        IaSimilarityContent entity = IaSimilarityContent.builder()
                .postId1(request.getPostId1())
                .postId2(request.getPostId2())
                .score(request.getScore())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaSimilarityContentResponse update(UUID id, IaSimilarityContentRequest request) {
        IaSimilarityContent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SimilarityContent not found"));
        entity.setPostId1(request.getPostId1());
        entity.setPostId2(request.getPostId2());
        entity.setScore(request.getScore());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaSimilarityContent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SimilarityContent not found"));
        repo.delete(entity);
    }
}
