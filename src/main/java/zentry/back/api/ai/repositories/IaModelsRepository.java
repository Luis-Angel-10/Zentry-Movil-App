package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaModels;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.Optional;

public interface IaModelsRepository extends JpaRepository<IaModels, UUID> {
    Page<IaModels> findByNombreContainingIgnoreCase(String nombre, Pageable pageable);
    Optional<IaModels> findByNombre(String nombre);
    boolean existsByNombre(String nombre);
}
