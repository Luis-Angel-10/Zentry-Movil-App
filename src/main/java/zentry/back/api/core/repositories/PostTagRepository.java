package zentry.back.api.core.repositories;

import zentry.back.api.core.models.PostTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PostTagRepository extends JpaRepository<PostTag, PostTag.PostTagId> {
   
}