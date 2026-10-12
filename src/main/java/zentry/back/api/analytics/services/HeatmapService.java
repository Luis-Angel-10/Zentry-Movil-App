package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.HeatmapRequest;
import zentry.back.api.analytics.dtos.HeatmapResponse;
import zentry.back.api.analytics.models.Heatmap;
import zentry.back.api.analytics.repositories.HeatmapRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class HeatmapService {

    private final HeatmapRepository repo;

    public HeatmapService(HeatmapRepository repo) {
        this.repo = repo;
    }

    public Page<HeatmapResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public HeatmapResponse getById(Integer id) {
        Heatmap entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Heatmap not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public HeatmapResponse create(HeatmapRequest request) {
        Heatmap entity = Heatmap.builder()
                .page(request.getPage())
                .clickData(request.getClickData())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public HeatmapResponse update(Integer id, HeatmapRequest request) {
        Heatmap entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Heatmap not found"));
        entity.setPage(request.getPage());
        entity.setClickData(request.getClickData());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Heatmap entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Heatmap not found"));
        repo.delete(entity);
    }
}
