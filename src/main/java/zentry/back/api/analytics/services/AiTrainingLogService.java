package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.AiTrainingLogRequest;
import zentry.back.api.analytics.dtos.AiTrainingLogResponse;
import zentry.back.api.analytics.models.AiTrainingLog;
import zentry.back.api.analytics.repositories.AiTrainingLogRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class AiTrainingLogService {

    private final AiTrainingLogRepository repo;

    public AiTrainingLogService(AiTrainingLogRepository repo) {
        this.repo = repo;
    }

    public Page<AiTrainingLogResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public AiTrainingLogResponse getById(Integer id) {
        AiTrainingLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AiTrainingLog not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public AiTrainingLogResponse create(AiTrainingLogRequest request) {
        AiTrainingLog entity = AiTrainingLog.builder()
                .model(request.getModel())
                .inputData(request.getInputData())
                .outputData(request.getOutputData())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public AiTrainingLogResponse update(Integer id, AiTrainingLogRequest request) {
        AiTrainingLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AiTrainingLog not found"));
        entity.setModel(request.getModel());
        entity.setInputData(request.getInputData());
        entity.setOutputData(request.getOutputData());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        AiTrainingLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AiTrainingLog not found"));
        repo.delete(entity);
    }
}
