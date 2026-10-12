
package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaFeedbackRequest;
import zentry.back.api.ai.dtos.IaFeedbackResponse;
import zentry.back.api.ai.models.IaFeedback;
import zentry.back.api.ai.repositories.IaFeedbackRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaFeedbackService {

    private final IaFeedbackRepository repo;

    public IaFeedbackService(IaFeedbackRepository repo) {
        this.repo = repo;
    }

    public Page<IaFeedbackResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaFeedbackResponse getById(UUID id) {
        IaFeedback entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Feedback not found"));
        return IaMappers.toResponse(entity);
    }

    public IaFeedbackResponse create(IaFeedbackRequest request) {
        IaFeedback entity = IaFeedback.builder()
                .userId(request.getUserId())
                .comentario(request.getComentario())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaFeedbackResponse update(UUID id, IaFeedbackRequest request) {
        IaFeedback entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Feedback not found"));
        entity.setUserId(request.getUserId());
        entity.setComentario(request.getComentario());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaFeedback entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Feedback not found"));
        repo.delete(entity);
    }
}
