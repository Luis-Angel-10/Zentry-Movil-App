package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.PayoutsRequest;
import zentry.back.api.business.dtos.PayoutsResponse;
import zentry.back.api.business.models.Payouts;
import zentry.back.api.business.repositories.PayoutsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class PayoutsService {

    private final PayoutsRepository repo;

    public PayoutsService(PayoutsRepository repo) {
        this.repo = repo;
    }

    public Page<PayoutsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public PayoutsResponse getById(UUID id) {
        Payouts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payout not found"));
        return BusinessMappers.toResponse(entity);
    }

    public PayoutsResponse create(PayoutsRequest request) {
        Payouts entity = Payouts.builder()
                .userId(request.getUserId())
                .amount(request.getAmount())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public PayoutsResponse update(UUID id, PayoutsRequest request) {
        Payouts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payout not found"));
        entity.setUserId(request.getUserId());
        entity.setAmount(request.getAmount());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Payouts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payout not found"));
        repo.delete(entity);
    }
}
