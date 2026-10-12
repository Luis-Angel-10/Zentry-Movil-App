package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.UserDeviceRequest;
import zentry.back.api.core.dtos.UserDeviceResponse;
import zentry.back.api.core.models.UserDevice;
import zentry.back.api.core.repositories.UserDeviceRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class UserDeviceService {

    private final UserDeviceRepository repo;

    public UserDeviceService(UserDeviceRepository repo) {
        this.repo = repo;
    }

    public Page<UserDeviceResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public UserDeviceResponse getById(Integer id) {
        UserDevice entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserDevice not found"));
        return CoreMappers.toResponse(entity);
    }

    public UserDeviceResponse create(UserDeviceRequest request) {
        UserDevice entity = UserDevice.builder()
                .userId(request.getUserId())
                .dispositivo(request.getDispositivo())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public UserDeviceResponse update(Integer id, UserDeviceRequest request) {
        UserDevice entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserDevice not found"));
        entity.setUserId(request.getUserId());
        entity.setDispositivo(request.getDispositivo());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        UserDevice entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserDevice not found"));
        repo.delete(entity);
    }
}
