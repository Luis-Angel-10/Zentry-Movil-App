package zentry.back.api.core.repositories;

import zentry.back.api.core.models.UserStreak;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserStreakRepository extends JpaRepository<UserStreak, Integer> {
    Optional<UserStreak> findByUserId(Integer userId);
    void deleteByUserId(Integer userId);
}
