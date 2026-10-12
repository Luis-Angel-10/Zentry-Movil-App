package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaModerationResultsRequest;
import zentry.back.api.ai.dtos.IaModerationResultsResponse;
import zentry.back.api.ai.models.IaModerationResults;
import zentry.back.api.ai.repositories.IaModerationResultsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaModerationResultsService {

    private final IaModerationResultsRepository repo;

    public IaModerationResultsService(IaModerationResultsRepository repo) {
        this.repo = repo;
    }

    public Page<IaModerationResultsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaModerationResultsResponse getById(UUID id) {
        IaModerationResults entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ModerationResult not found"));
        return IaMappers.toResponse(entity);
    }

    public IaModerationResultsResponse create(IaModerationResultsRequest request) {
        IaModerationResults entity = IaModerationResults.builder()
                .postId(request.getPostId())
                .resultado(request.getResultado())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaModerationResultsResponse update(UUID id, IaModerationResultsRequest request) {
        IaModerationResults entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ModerationResult not found"));
        entity.setPostId(request.getPostId());
        entity.setResultado(request.getResultado());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaModerationResults entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ModerationResult not found"));
        repo.delete(entity);
    }
}
