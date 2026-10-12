package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Contracts;

import java.util.List;
import java.util.UUID;

@Repository
public interface ContractsRepository extends JpaRepository<Contracts, UUID> {

    List<Contracts> findByUserId(Integer userId);

    List<Contracts> findByDetallesContainingIgnoreCase(String detalles);

    boolean existsByUserId(Integer userId);
}
