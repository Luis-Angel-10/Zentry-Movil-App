package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaTrainingDataRequest;
import zentry.back.api.ai.dtos.IaTrainingDataResponse;
import zentry.back.api.ai.models.IaTrainingData;
import zentry.back.api.ai.repositories.IaTrainingDataRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaTrainingDataService {

    private final IaTrainingDataRepository repo;

    public IaTrainingDataService(IaTrainingDataRepository repo) {
        this.repo = repo;
    }

    public Page<IaTrainingDataResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaTrainingDataResponse getById(UUID id) {
        IaTrainingData entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TrainingData not found"));
        return IaMappers.toResponse(entity);
    }

    public IaTrainingDataResponse create(IaTrainingDataRequest request) {
        if (repo.existsByDataInput(request.getDataInput())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Training data already exists");
        }
        IaTrainingData entity = IaTrainingData.builder()
                .dataInput(request.getDataInput())
                .dataOutput(request.getDataOutput())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaTrainingDataResponse update(UUID id, IaTrainingDataRequest request) {
        IaTrainingData entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TrainingData not found"));
        entity.setDataInput(request.getDataInput());
        entity.setDataOutput(request.getDataOutput());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaTrainingData entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TrainingData not found"));
        repo.delete(entity);
    }
}
