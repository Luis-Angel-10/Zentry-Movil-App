package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.WalletTransactionsRequest;
import zentry.back.api.business.dtos.WalletTransactionsResponse;
import zentry.back.api.business.models.WalletTransactions;
import zentry.back.api.business.repositories.WalletTransactionsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class WalletTransactionsService {

    private final WalletTransactionsRepository repo;

    public WalletTransactionsService(WalletTransactionsRepository repo) {
        this.repo = repo;
    }

    public Page<WalletTransactionsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public WalletTransactionsResponse getById(UUID id) {
        WalletTransactions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "WalletTransaction not found"));
        return BusinessMappers.toResponse(entity);
    }

    public WalletTransactionsResponse create(WalletTransactionsRequest request) {
        WalletTransactions entity = WalletTransactions.builder()
                .userId(request.getUserId())
                .amount(request.getAmount())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public WalletTransactionsResponse update(UUID id, WalletTransactionsRequest request) {
        WalletTransactions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "WalletTransaction not found"));
        entity.setUserId(request.getUserId());
        entity.setAmount(request.getAmount());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        WalletTransactions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "WalletTransaction not found"));
        repo.delete(entity);
    }
}
