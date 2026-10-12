package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.OnlineUserRequest;
import zentry.back.api.realtime.dtos.OnlineUserResponse;
import zentry.back.api.realtime.models.OnlineUser;
import zentry.back.api.realtime.repositories.OnlineUserRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class OnlineUserService {

    private final OnlineUserRepository repo;

    public OnlineUserService(OnlineUserRepository repo) {
        this.repo = repo;
    }

    public Page<OnlineUserResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public OnlineUserResponse getById(Integer userId) {
        OnlineUser entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "OnlineUser not found"));
        return mappers.toResponse(entity);
    }

    public OnlineUserResponse create(OnlineUserRequest request) {
        if (repo.existsById(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "OnlineUser already exists");
        }
        OnlineUser entity = OnlineUser.builder()
                .userId(request.getUserId())
                .status(request.getStatus())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public OnlineUserResponse update(Integer userId, OnlineUserRequest request) {
        OnlineUser entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "OnlineUser not found"));
        entity.setStatus(request.getStatus());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer userId) {
        OnlineUser entity = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "OnlineUser not found"));
        repo.delete(entity);
    }
}
