package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.ReportRequest;
import zentry.back.api.core.dtos.ReportResponse;
import zentry.back.api.core.models.Report;
import zentry.back.api.core.repositories.ReportRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class ReportService {

    private final ReportRepository repo;

    public ReportService(ReportRepository repo) {
        this.repo = repo;
    }

    public Page<ReportResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public ReportResponse getById(Integer id) {
        Report entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Report not found"));
        return CoreMappers.toResponse(entity);
    }

    public ReportResponse create(ReportRequest request) {
        Report entity = Report.builder()
                .userId(request.getUserId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public ReportResponse update(Integer id, ReportRequest request) {
        Report entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Report not found"));
        entity.setUserId(request.getUserId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Report entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Report not found"));
        repo.delete(entity);
    }
}
