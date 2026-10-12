package zentry.back.api.core.repositories;

import zentry.back.api.core.models.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;


@Repository
public interface ProfileRepository extends JpaRepository<Profile, Integer> {
    Optional<Profile> findByUserId(Integer userId);

    List<Profile> findByNameContainingIgnoreCase(String name);
   
}