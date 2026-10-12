package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaPromptsRequest;
import zentry.back.api.ai.dtos.IaPromptsResponse;
import zentry.back.api.ai.models.IaPrompts;
import zentry.back.api.ai.repositories.IaPromptsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaPromptsService {

    private final IaPromptsRepository repo;

    public IaPromptsService(IaPromptsRepository repo) {
        this.repo = repo;
    }

    public Page<IaPromptsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaPromptsResponse getById(UUID id) {
        IaPrompts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Prompt not found"));
        return IaMappers.toResponse(entity);
    }

    public IaPromptsResponse create(IaPromptsRequest request) {
        IaPrompts entity = IaPrompts.builder()
                .userId(request.getUserId())
                .prompt(request.getPrompt())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaPromptsResponse update(UUID id, IaPromptsRequest request) {
        IaPrompts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Prompt not found"));
        entity.setUserId(request.getUserId());
        entity.setPrompt(request.getPrompt());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaPrompts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Prompt not found"));
        repo.delete(entity);
    }
}
