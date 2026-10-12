package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.WalletsRequest;
import zentry.back.api.business.dtos.WalletsResponse;
import zentry.back.api.business.models.Wallets;
import zentry.back.api.business.repositories.WalletsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

@Service
@SuppressWarnings("null")
public class WalletsService {

    private final WalletsRepository repo;

    public WalletsService(WalletsRepository repo) {
        this.repo = repo;
    }

    public Page<WalletsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public WalletsResponse getById(Integer userId) {
        Wallets entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Wallet not found"));
        return BusinessMappers.toResponse(entity);
    }

    public WalletsResponse create(WalletsRequest request) {
        if (repo.existsByUserId(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Wallet already exists for this user");
        }
        Wallets entity = Wallets.builder()
                .userId(request.getUserId())
                .balance(request.getBalance())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public WalletsResponse update(Integer userId, WalletsRequest request) {
        Wallets entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Wallet not found"));
        entity.setBalance(request.getBalance());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer userId) {
        Wallets entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Wallet not found"));
        repo.delete(entity);
    }
}
