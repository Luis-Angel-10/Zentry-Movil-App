package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaPredictionsRequest;
import zentry.back.api.ai.dtos.IaPredictionsResponse;
import zentry.back.api.ai.models.IaPredictions;
import zentry.back.api.ai.repositories.IaPredictionsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaPredictionsService {

    private final IaPredictionsRepository repo;

    public IaPredictionsService(IaPredictionsRepository repo) {
        this.repo = repo;
    }

    public Page<IaPredictionsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaPredictionsResponse getById(UUID id) {
        IaPredictions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Prediction not found"));
        return IaMappers.toResponse(entity);
    }

    public IaPredictionsResponse create(IaPredictionsRequest request) {
        IaPredictions entity = IaPredictions.builder()
                .modelId(request.getModelId())
                .resultado(request.getResultado())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaPredictionsResponse update(UUID id, IaPredictionsRequest request) {
        IaPredictions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Prediction not found"));
        entity.setModelId(request.getModelId());
        entity.setResultado(request.getResultado());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaPredictions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Prediction not found"));
        repo.delete(entity);
    }
}
