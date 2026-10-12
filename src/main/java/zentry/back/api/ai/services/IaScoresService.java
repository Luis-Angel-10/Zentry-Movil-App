package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaScoresRequest;
import zentry.back.api.ai.dtos.IaScoresResponse;
import zentry.back.api.ai.models.IaScores;
import zentry.back.api.ai.repositories.IaScoresRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaScoresService {

    private final IaScoresRepository repo;

    public IaScoresService(IaScoresRepository repo) {
        this.repo = repo;
    }

    public Page<IaScoresResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaScoresResponse getById(UUID id) {
        IaScores entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Score not found"));
        return IaMappers.toResponse(entity);
    }

    public IaScoresResponse create(IaScoresRequest request) {
        IaScores entity = IaScores.builder()
                .postId(request.getPostId())
                .score(request.getScore())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaScoresResponse update(UUID id, IaScoresRequest request) {
        IaScores entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Score not found"));
        entity.setPostId(request.getPostId());
        entity.setScore(request.getScore());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaScores entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Score not found"));
        repo.delete(entity);
    }
}
