package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.MarketplaceOrdersRequest;
import zentry.back.api.business.dtos.MarketplaceOrdersResponse;
import zentry.back.api.business.models.MarketplaceOrders;
import zentry.back.api.business.repositories.MarketplaceOrdersRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class MarketplaceOrdersService {

    private final MarketplaceOrdersRepository repo;

    public MarketplaceOrdersService(MarketplaceOrdersRepository repo) {
        this.repo = repo;
    }

    public Page<MarketplaceOrdersResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public MarketplaceOrdersResponse getById(UUID id) {
        MarketplaceOrders entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "MarketplaceOrder not found"));
        return BusinessMappers.toResponse(entity);
    }

    public MarketplaceOrdersResponse create(MarketplaceOrdersRequest request) {
        MarketplaceOrders entity = MarketplaceOrders.builder()
                .buyerId(request.getBuyerId())
                .total(request.getTotal())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public MarketplaceOrdersResponse update(UUID id, MarketplaceOrdersRequest request) {
        MarketplaceOrders entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "MarketplaceOrder not found"));
        entity.setBuyerId(request.getBuyerId());
        entity.setTotal(request.getTotal());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        MarketplaceOrders entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "MarketplaceOrder not found"));
        repo.delete(entity);
    }
}
