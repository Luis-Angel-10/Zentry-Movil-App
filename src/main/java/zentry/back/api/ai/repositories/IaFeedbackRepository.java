package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaFeedback;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IaFeedbackRepository extends JpaRepository<IaFeedback, UUID> {
    List<IaFeedback> findByUserId(Integer userId);
    Page<IaFeedback> findByUserId(Integer userId, Pageable pageable);
    boolean existsByUserId(Integer userId);
}
