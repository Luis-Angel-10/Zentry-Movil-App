package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.AbTestRequest;
import zentry.back.api.analytics.dtos.AbTestResponse;
import zentry.back.api.analytics.models.AbTest;
import zentry.back.api.analytics.repositories.AbTestRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class AbTestService {

    private final AbTestRepository repo;

    public AbTestService(AbTestRepository repo) {
        this.repo = repo;
    }

    public Page<AbTestResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public AbTestResponse getById(Integer id) {
        AbTest entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AbTest not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public AbTestResponse create(AbTestRequest request) {
        AbTest entity = AbTest.builder()
                .testName(request.getTestName())
                .description(request.getDescription())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public AbTestResponse update(Integer id, AbTestRequest request) {
        AbTest entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AbTest not found"));
        entity.setTestName(request.getTestName());
        entity.setDescription(request.getDescription());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        AbTest entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AbTest not found"));
        repo.delete(entity);
    }
}
