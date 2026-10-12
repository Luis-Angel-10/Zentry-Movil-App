package zentry.back.api.core.repositories;

import zentry.back.api.core.models.PostVersion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PostVersionRepository extends JpaRepository<PostVersion, Integer> {
   
}