package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaPrompts;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IaPromptsRepository extends JpaRepository<IaPrompts, UUID> {
    List<IaPrompts> findByUserId(Integer userId);
    Page<IaPrompts> findByUserId(Integer userId, Pageable pageable);
    boolean existsByUserId(Integer userId);
}
