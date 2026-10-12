package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.CollabLiveUpdateRequest;
import zentry.back.api.realtime.dtos.CollabLiveUpdateResponse;
import zentry.back.api.realtime.models.CollabLiveUpdate;
import zentry.back.api.realtime.repositories.CollabLiveUpdateRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class CollabLiveUpdateService {

    private final CollabLiveUpdateRepository repo;

    public CollabLiveUpdateService(CollabLiveUpdateRepository repo) {
        this.repo = repo;
    }

    public Page<CollabLiveUpdateResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public CollabLiveUpdateResponse getById(Integer id) {
        CollabLiveUpdate entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CollabLiveUpdate not found"));
        return mappers.toResponse(entity);
    }

    public CollabLiveUpdateResponse create(CollabLiveUpdateRequest request) {
        CollabLiveUpdate entity = CollabLiveUpdate.builder()
                .projectId(request.getProjectId())
                .updateData(request.getUpdateData())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public CollabLiveUpdateResponse update(Integer id, CollabLiveUpdateRequest request) {
        CollabLiveUpdate entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CollabLiveUpdate not found"));
        entity.setProjectId(request.getProjectId());
        entity.setUpdateData(request.getUpdateData());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        CollabLiveUpdate entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CollabLiveUpdate not found"));
        repo.delete(entity);
    }
}
