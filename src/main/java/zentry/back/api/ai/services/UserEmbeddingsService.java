package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.UserEmbeddingsRequest;
import zentry.back.api.ai.dtos.UserEmbeddingsResponse;
import zentry.back.api.ai.models.UserEmbeddings;
import zentry.back.api.ai.repositories.UserEmbeddingsRepository;
import zentry.back.api.ai.mappers.IaMappers;

@Service
@SuppressWarnings("null")
public class UserEmbeddingsService {

    private final UserEmbeddingsRepository repo;

    public UserEmbeddingsService(UserEmbeddingsRepository repo) {
        this.repo = repo;
    }

    public Page<UserEmbeddingsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public UserEmbeddingsResponse getById(Integer userId) {
        UserEmbeddings entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserEmbedding not found"));
        return IaMappers.toResponse(entity);
    }

    public UserEmbeddingsResponse create(UserEmbeddingsRequest request) {
        if (repo.existsByUserId(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Embedding already exists for this user");
        }
        UserEmbeddings entity = UserEmbeddings.builder()
                .userId(request.getUserId())
                .vector(request.getVector())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public UserEmbeddingsResponse update(Integer userId, UserEmbeddingsRequest request) {
        UserEmbeddings entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserEmbedding not found"));
        entity.setVector(request.getVector());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer userId) {
        UserEmbeddings entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserEmbedding not found"));
        repo.delete(entity);
    }
}
