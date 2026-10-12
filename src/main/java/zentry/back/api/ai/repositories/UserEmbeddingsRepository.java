package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.UserEmbeddings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserEmbeddingsRepository extends JpaRepository<UserEmbeddings, Integer> {
    Optional<UserEmbeddings> findByUserId(Integer userId);
    boolean existsByUserId(Integer userId);
}
