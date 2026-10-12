package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.CommissionJobs;

import java.util.List;
import java.util.UUID;

@Repository
public interface CommissionJobsRepository extends JpaRepository<CommissionJobs, UUID> {

    List<CommissionJobs> findByUserId(Integer userId);

    List<CommissionJobs> findByDescripcionContainingIgnoreCase(String descripcion);

    boolean existsByUserId(Integer userId);
}
