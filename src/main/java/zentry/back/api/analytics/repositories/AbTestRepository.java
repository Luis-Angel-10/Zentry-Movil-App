package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.AbTest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AbTestRepository extends JpaRepository<AbTest, Integer> {

}
