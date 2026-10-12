package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.FeedbackLabelsRequest;
import zentry.back.api.ai.dtos.FeedbackLabelsResponse;
import zentry.back.api.ai.models.FeedbackLabels;
import zentry.back.api.ai.repositories.FeedbackLabelsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class FeedbackLabelsService {

    private final FeedbackLabelsRepository repo;

    public FeedbackLabelsService(FeedbackLabelsRepository repo) {
        this.repo = repo;
    }

    public Page<FeedbackLabelsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public FeedbackLabelsResponse getById(UUID id) {
        FeedbackLabels entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeedbackLabel not found"));
        return IaMappers.toResponse(entity);
    }

    public FeedbackLabelsResponse create(FeedbackLabelsRequest request) {
        FeedbackLabels entity = FeedbackLabels.builder()
                .feedbackId(request.getFeedbackId())
                .etiqueta(request.getEtiqueta())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public FeedbackLabelsResponse update(UUID id, FeedbackLabelsRequest request) {
        FeedbackLabels entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeedbackLabel not found"));
        entity.setFeedbackId(request.getFeedbackId());
        entity.setEtiqueta(request.getEtiqueta());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        FeedbackLabels entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeedbackLabel not found"));
        repo.delete(entity);
    }
}
