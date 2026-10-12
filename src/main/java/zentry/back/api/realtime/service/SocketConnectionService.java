package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.SocketConnectionRequest;
import zentry.back.api.realtime.dtos.SocketConnectionResponse;
import zentry.back.api.realtime.models.SocketConnection;
import zentry.back.api.realtime.repositories.SocketConnectionRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class SocketConnectionService {

    private final SocketConnectionRepository repo;

    public SocketConnectionService(SocketConnectionRepository repo) {
        this.repo = repo;
    }

    public Page<SocketConnectionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public SocketConnectionResponse getById(Integer id) {
        SocketConnection entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SocketConnection not found"));
        return mappers.toResponse(entity);
    }

    public SocketConnectionResponse create(SocketConnectionRequest request) {
        SocketConnection entity = SocketConnection.builder()
                .userId(request.getUserId())
                .socketId(request.getSocketId())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public SocketConnectionResponse update(Integer id, SocketConnectionRequest request) {
        SocketConnection entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SocketConnection not found"));
        entity.setUserId(request.getUserId());
        entity.setSocketId(request.getSocketId());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        SocketConnection entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SocketConnection not found"));
        repo.delete(entity);
    }
}
