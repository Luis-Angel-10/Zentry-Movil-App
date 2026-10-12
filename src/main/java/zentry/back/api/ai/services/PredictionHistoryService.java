package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.PredictionHistoryRequest;
import zentry.back.api.ai.dtos.PredictionHistoryResponse;
import zentry.back.api.ai.models.PredictionHistory;
import zentry.back.api.ai.repositories.PredictionHistoryRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class PredictionHistoryService {

    private final PredictionHistoryRepository repo;

    public PredictionHistoryService(PredictionHistoryRepository repo) {
        this.repo = repo;
    }

    public Page<PredictionHistoryResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public PredictionHistoryResponse getById(UUID id) {
        PredictionHistory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PredictionHistory not found"));
        return IaMappers.toResponse(entity);
    }

    public PredictionHistoryResponse create(PredictionHistoryRequest request) {
        PredictionHistory entity = PredictionHistory.builder()
                .predictionId(request.getPredictionId())
                .fecha(request.getFecha())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public PredictionHistoryResponse update(UUID id, PredictionHistoryRequest request) {
        PredictionHistory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PredictionHistory not found"));
        entity.setPredictionId(request.getPredictionId());
        entity.setFecha(request.getFecha());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        PredictionHistory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PredictionHistory not found"));
        repo.delete(entity);
    }
}
