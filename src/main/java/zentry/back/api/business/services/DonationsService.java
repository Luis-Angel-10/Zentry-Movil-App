package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.DonationsRequest;
import zentry.back.api.business.dtos.DonationsResponse;
import zentry.back.api.business.models.Donations;
import zentry.back.api.business.repositories.DonationsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class DonationsService {

    private final DonationsRepository repo;

    public DonationsService(DonationsRepository repo) {
        this.repo = repo;
    }

    public Page<DonationsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public DonationsResponse getById(UUID id) {
        Donations entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Donation not found"));
        return BusinessMappers.toResponse(entity);
    }

    public DonationsResponse create(DonationsRequest request) {
        Donations entity = Donations.builder()
                .userId(request.getUserId())
                .amount(request.getAmount())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public DonationsResponse update(UUID id, DonationsRequest request) {
        Donations entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Donation not found"));
        entity.setUserId(request.getUserId());
        entity.setAmount(request.getAmount());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Donations entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Donation not found"));
        repo.delete(entity);
    }
}
