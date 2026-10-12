package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaClusters;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IaClustersRepository extends JpaRepository<IaClusters, UUID> {
    List<IaClusters> findByDescripcionContainingIgnoreCase(String descripcion);
    boolean existsByDescripcion(String descripcion);
}
