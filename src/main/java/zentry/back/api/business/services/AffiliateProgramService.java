package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.AffiliateProgramRequest;
import zentry.back.api.business.dtos.AffiliateProgramResponse;
import zentry.back.api.business.models.AffiliateProgram;
import zentry.back.api.business.repositories.AffiliateProgramRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class AffiliateProgramService {

    private final AffiliateProgramRepository repo;

    public AffiliateProgramService(AffiliateProgramRepository repo) {
        this.repo = repo;
    }

    public Page<AffiliateProgramResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public AffiliateProgramResponse getById(UUID id) {
        AffiliateProgram entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AffiliateProgram not found"));
        return BusinessMappers.toResponse(entity);
    }

    public AffiliateProgramResponse create(AffiliateProgramRequest request) {
        if (repo.existsByUserId(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User is already enrolled in the affiliate program");
        }
        AffiliateProgram entity = AffiliateProgram.builder()
                .userId(request.getUserId())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public AffiliateProgramResponse update(UUID id, AffiliateProgramRequest request) {
        AffiliateProgram entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AffiliateProgram not found"));
        entity.setUserId(request.getUserId());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        AffiliateProgram entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AffiliateProgram not found"));
        repo.delete(entity);
    }
}
