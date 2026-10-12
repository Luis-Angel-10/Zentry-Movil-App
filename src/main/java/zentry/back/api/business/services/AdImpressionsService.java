package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.AdImpressionsRequest;
import zentry.back.api.business.dtos.AdImpressionsResponse;
import zentry.back.api.business.models.AdImpressions;
import zentry.back.api.business.repositories.AdImpressionsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class AdImpressionsService {

    private final AdImpressionsRepository repo;

    public AdImpressionsService(AdImpressionsRepository repo) {
        this.repo = repo;
    }

    public Page<AdImpressionsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public AdImpressionsResponse getById(UUID id) {
        AdImpressions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AdImpression not found"));
        return BusinessMappers.toResponse(entity);
    }

    public AdImpressionsResponse create(AdImpressionsRequest request) {
        AdImpressions entity = AdImpressions.builder()
                .campaignId(request.getCampaignId())
                .vistas(request.getVistas())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public AdImpressionsResponse update(UUID id, AdImpressionsRequest request) {
        AdImpressions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AdImpression not found"));
        entity.setCampaignId(request.getCampaignId());
        entity.setVistas(request.getVistas());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        AdImpressions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AdImpression not found"));
        repo.delete(entity);
    }
}
