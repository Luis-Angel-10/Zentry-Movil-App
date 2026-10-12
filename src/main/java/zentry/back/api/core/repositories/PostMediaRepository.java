package zentry.back.api.core.repositories;

import zentry.back.api.core.models.PostMedia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PostMediaRepository extends JpaRepository<PostMedia, Integer> {
    java.util.List<PostMedia> findByPostId(Integer postId);
    void deleteByPostId(Integer postId);
}