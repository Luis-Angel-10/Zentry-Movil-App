package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.AffiliateProgram;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AffiliateProgramRepository extends JpaRepository<AffiliateProgram, UUID> {

    List<AffiliateProgram> findByUserId(Integer userId);

    Optional<AffiliateProgram> findFirstByUserId(Integer userId);

    boolean existsByUserId(Integer userId);
}
