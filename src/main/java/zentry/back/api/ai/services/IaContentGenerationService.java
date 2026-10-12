package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaContentGenerationRequest;
import zentry.back.api.ai.dtos.IaContentGenerationResponse;
import zentry.back.api.ai.models.IaContentGeneration;
import zentry.back.api.ai.repositories.IaContentGenerationRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaContentGenerationService {

    private final IaContentGenerationRepository repo;

    public IaContentGenerationService(IaContentGenerationRepository repo) {
        this.repo = repo;
    }

    public Page<IaContentGenerationResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaContentGenerationResponse getById(UUID id) {
        IaContentGeneration entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentGeneration not found"));
        return IaMappers.toResponse(entity);
    }

    public IaContentGenerationResponse create(IaContentGenerationRequest request) {
        IaContentGeneration entity = IaContentGeneration.builder()
                .promptId(request.getPromptId())
                .resultado(request.getResultado())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaContentGenerationResponse update(UUID id, IaContentGenerationRequest request) {
        IaContentGeneration entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentGeneration not found"));
        entity.setPromptId(request.getPromptId());
        entity.setResultado(request.getResultado());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaContentGeneration entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ContentGeneration not found"));
        repo.delete(entity);
    }
}
