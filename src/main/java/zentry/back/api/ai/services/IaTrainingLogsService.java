package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaTrainingLogsRequest;
import zentry.back.api.ai.dtos.IaTrainingLogsResponse;
import zentry.back.api.ai.models.IaTrainingLogs;
import zentry.back.api.ai.repositories.IaTrainingLogsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaTrainingLogsService {

    private final IaTrainingLogsRepository repo;

    public IaTrainingLogsService(IaTrainingLogsRepository repo) {
        this.repo = repo;
    }

    public Page<IaTrainingLogsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaTrainingLogsResponse getById(UUID id) {
        IaTrainingLogs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TrainingLog not found"));
        return IaMappers.toResponse(entity);
    }

    public IaTrainingLogsResponse create(IaTrainingLogsRequest request) {
        IaTrainingLogs entity = IaTrainingLogs.builder()
                .modelId(request.getModelId())
                .estado(request.getEstado())
                .fecha(request.getFecha())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaTrainingLogsResponse update(UUID id, IaTrainingLogsRequest request) {
        IaTrainingLogs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TrainingLog not found"));
        entity.setModelId(request.getModelId());
        entity.setEstado(request.getEstado());
        entity.setFecha(request.getFecha());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaTrainingLogs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TrainingLog not found"));
        repo.delete(entity);
    }
}
