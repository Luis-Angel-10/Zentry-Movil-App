package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.CartRequest;
import zentry.back.api.business.dtos.CartResponse;
import zentry.back.api.business.models.Cart;
import zentry.back.api.business.repositories.CartRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class CartService {

    private final CartRepository repo;

    public CartService(CartRepository repo) {
        this.repo = repo;
    }

    public Page<CartResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public CartResponse getById(UUID id) {
        Cart entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cart not found"));
        return BusinessMappers.toResponse(entity);
    }

    public CartResponse create(CartRequest request) {
        Cart entity = Cart.builder()
                .userId(request.getUserId())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public CartResponse update(UUID id, CartRequest request) {
        Cart entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cart not found"));
        entity.setUserId(request.getUserId());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Cart entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cart not found"));
        repo.delete(entity);
    }
}
