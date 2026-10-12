package zentry.back.api.analytics.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.analytics.dtos.DataLakeEventRequest;
import zentry.back.api.analytics.dtos.DataLakeEventResponse;
import zentry.back.api.analytics.models.DataLakeEvent;
import zentry.back.api.analytics.repositories.DataLakeEventRepository;
import zentry.back.api.analytics.mappers.AnalyticsMappers;

@Service
@SuppressWarnings("null")
public class DataLakeEventService {

    private final DataLakeEventRepository repo;

    public DataLakeEventService(DataLakeEventRepository repo) {
        this.repo = repo;
    }

    public Page<DataLakeEventResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(AnalyticsMappers::toResponse);
    }

    public DataLakeEventResponse getById(Integer id) {
        DataLakeEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "DataLakeEvent not found"));
        return AnalyticsMappers.toResponse(entity);
    }

    public DataLakeEventResponse create(DataLakeEventRequest request) {
        DataLakeEvent entity = DataLakeEvent.builder()
                .rawData(request.getRawData())
                .source(request.getSource())
                .build();
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public DataLakeEventResponse update(Integer id, DataLakeEventRequest request) {
        DataLakeEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "DataLakeEvent not found"));
        entity.setRawData(request.getRawData());
        entity.setSource(request.getSource());
        return AnalyticsMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        DataLakeEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "DataLakeEvent not found"));
        repo.delete(entity);
    }
}
