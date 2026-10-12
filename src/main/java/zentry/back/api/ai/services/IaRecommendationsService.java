package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaRecommendationsRequest;
import zentry.back.api.ai.dtos.IaRecommendationsResponse;
import zentry.back.api.ai.models.IaRecommendations;
import zentry.back.api.ai.repositories.IaRecommendationsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaRecommendationsService {

    private final IaRecommendationsRepository repo;

    public IaRecommendationsService(IaRecommendationsRepository repo) {
        this.repo = repo;
    }

    public Page<IaRecommendationsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaRecommendationsResponse getById(UUID id) {
        IaRecommendations entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recommendation not found"));
        return IaMappers.toResponse(entity);
    }

    public IaRecommendationsResponse create(IaRecommendationsRequest request) {
        if (repo.existsByUserIdAndContenidoId(request.getUserId(), request.getContenidoId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Recommendation already exists for this user and content");
        }
        IaRecommendations entity = IaRecommendations.builder()
                .userId(request.getUserId())
                .contenidoId(request.getContenidoId())
                .score(request.getScore())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaRecommendationsResponse update(UUID id, IaRecommendationsRequest request) {
        IaRecommendations entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recommendation not found"));
        entity.setUserId(request.getUserId());
        entity.setContenidoId(request.getContenidoId());
        entity.setScore(request.getScore());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaRecommendations entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recommendation not found"));
        repo.delete(entity);
    }
}
