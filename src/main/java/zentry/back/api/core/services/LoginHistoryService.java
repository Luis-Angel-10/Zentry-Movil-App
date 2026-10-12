package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.LoginHistoryRequest;
import zentry.back.api.core.dtos.LoginHistoryResponse;
import zentry.back.api.core.models.LoginHistory;
import zentry.back.api.core.repositories.LoginHistoryRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class LoginHistoryService {

    private final LoginHistoryRepository repo;

    public LoginHistoryService(LoginHistoryRepository repo) {
        this.repo = repo;
    }

    public Page<LoginHistoryResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public LoginHistoryResponse getById(Integer id) {
        LoginHistory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LoginHistory not found"));
        return CoreMappers.toResponse(entity);
    }

    public LoginHistoryResponse create(LoginHistoryRequest request) {
        LoginHistory entity = LoginHistory.builder()
                .userId(request.getUserId())
                .ip(request.getIp())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public LoginHistoryResponse update(Integer id, LoginHistoryRequest request) {
        LoginHistory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LoginHistory not found"));
        entity.setUserId(request.getUserId());
        entity.setIp(request.getIp());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        LoginHistory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LoginHistory not found"));
        repo.delete(entity);
    }
}
