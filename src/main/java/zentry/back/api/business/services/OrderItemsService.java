package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.OrderItemsRequest;
import zentry.back.api.business.dtos.OrderItemsResponse;
import zentry.back.api.business.models.OrderItems;
import zentry.back.api.business.models.OrderItems.OrderItemsId;
import zentry.back.api.business.repositories.OrderItemsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class OrderItemsService {

    private final OrderItemsRepository repo;

    public OrderItemsService(OrderItemsRepository repo) {
        this.repo = repo;
    }

    public Page<OrderItemsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public OrderItemsResponse getById(UUID orderId, UUID productId) {
        OrderItemsId id = new OrderItemsId(orderId, productId);
        OrderItems entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "OrderItem not found"));
        return BusinessMappers.toResponse(entity);
    }

    public OrderItemsResponse create(OrderItemsRequest request) {
        if (repo.existsByOrderIdAndProductId(request.getOrderId(), request.getProductId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Item already exists in this order");
        }
        OrderItems entity = OrderItems.builder()
                .orderId(request.getOrderId())
                .productId(request.getProductId())
                .cantidad(request.getCantidad())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public OrderItemsResponse update(UUID orderId, UUID productId, OrderItemsRequest request) {
        OrderItemsId id = new OrderItemsId(orderId, productId);
        OrderItems entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "OrderItem not found"));
        entity.setCantidad(request.getCantidad());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID orderId, UUID productId) {
        OrderItemsId id = new OrderItemsId(orderId, productId);
        OrderItems entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "OrderItem not found"));
        repo.delete(entity);
    }
}
