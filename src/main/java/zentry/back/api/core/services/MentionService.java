package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.MentionRequest;
import zentry.back.api.core.dtos.MentionResponse;
import zentry.back.api.core.models.Mention;
import zentry.back.api.core.repositories.MentionRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class MentionService {

    private final MentionRepository repo;

    public MentionService(MentionRepository repo) {
        this.repo = repo;
    }

    public Page<MentionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public MentionResponse getById(Integer id) {
        Mention entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Mention not found"));
        return CoreMappers.toResponse(entity);
    }

    public MentionResponse create(MentionRequest request) {
        Mention entity = Mention.builder()
                .userId(request.getUserId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public MentionResponse update(Integer id, MentionRequest request) {
        Mention entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Mention not found"));
        entity.setUserId(request.getUserId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Mention entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Mention not found"));
        repo.delete(entity);
    }
}
