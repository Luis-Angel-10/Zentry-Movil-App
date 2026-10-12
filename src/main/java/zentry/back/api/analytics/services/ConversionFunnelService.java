package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.ConversionFunnelRequest;
import zentry.back.api.analytics.dtos.ConversionFunnelResponse;
import zentry.back.api.analytics.models.ConversionFunnel;
import zentry.back.api.analytics.repositories.ConversionFunnelRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class ConversionFunnelService {

    private final ConversionFunnelRepository repo;

    public ConversionFunnelService(ConversionFunnelRepository repo) {
        this.repo = repo;
    }

    public Page<ConversionFunnelResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public ConversionFunnelResponse getById(Integer id) {
        ConversionFunnel entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ConversionFunnel not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public ConversionFunnelResponse create(ConversionFunnelRequest request) {
        ConversionFunnel entity = ConversionFunnel.builder()
                .funnelName(request.getFunnelName())
                .steps(request.getSteps())
                .conversions(request.getConversions())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public ConversionFunnelResponse update(Integer id, ConversionFunnelRequest request) {
        ConversionFunnel entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ConversionFunnel not found"));
        entity.setFunnelName(request.getFunnelName());
        entity.setSteps(request.getSteps());
        entity.setConversions(request.getConversions());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        ConversionFunnel entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ConversionFunnel not found"));
        repo.delete(entity);
    }
}
