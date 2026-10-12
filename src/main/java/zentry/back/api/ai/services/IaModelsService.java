package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaModelsRequest;
import zentry.back.api.ai.dtos.IaModelsResponse;
import zentry.back.api.ai.models.IaModels;
import zentry.back.api.ai.repositories.IaModelsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaModelsService {

    private final IaModelsRepository repo;

    public IaModelsService(IaModelsRepository repo) {
        this.repo = repo;
    }

    public Page<IaModelsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaModelsResponse getById(UUID id) {
        IaModels model = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Model not found"));
        return IaMappers.toResponse(model);
    }

    public IaModelsResponse create(IaModelsRequest request) {
        if (repo.existsByNombre(request.getNombre())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Model already exists");
        }
        IaModels model = IaModels.builder()
                .nombre(request.getNombre())
                .build();
        return IaMappers.toResponse(repo.save(model));
    }

    public IaModelsResponse update(UUID id, IaModelsRequest request) {
        IaModels model = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Model not found"));
        model.setNombre(request.getNombre());
        return IaMappers.toResponse(repo.save(model));
    }

    public void delete(UUID id) {
        IaModels model = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Model not found"));
        repo.delete(model);
    }
}
