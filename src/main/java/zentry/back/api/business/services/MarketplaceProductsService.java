package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.MarketplaceProductsRequest;
import zentry.back.api.business.dtos.MarketplaceProductsResponse;
import zentry.back.api.business.models.MarketplaceProducts;
import zentry.back.api.business.repositories.MarketplaceProductsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class MarketplaceProductsService {

    private final MarketplaceProductsRepository repo;

    public MarketplaceProductsService(MarketplaceProductsRepository repo) {
        this.repo = repo;
    }

    public Page<MarketplaceProductsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public MarketplaceProductsResponse getById(UUID id) {
        MarketplaceProducts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "MarketplaceProduct not found"));
        return BusinessMappers.toResponse(entity);
    }

    public MarketplaceProductsResponse create(MarketplaceProductsRequest request) {
        if (repo.existsBySellerIdAndNombre(request.getSellerId(), request.getNombre())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Seller already has a product with this name");
        }
        MarketplaceProducts entity = MarketplaceProducts.builder()
                .sellerId(request.getSellerId())
                .nombre(request.getNombre())
                .precio(request.getPrecio())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public MarketplaceProductsResponse update(UUID id, MarketplaceProductsRequest request) {
        MarketplaceProducts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "MarketplaceProduct not found"));
        entity.setSellerId(request.getSellerId());
        entity.setNombre(request.getNombre());
        entity.setPrecio(request.getPrecio());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        MarketplaceProducts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "MarketplaceProduct not found"));
        repo.delete(entity);
    }
}
