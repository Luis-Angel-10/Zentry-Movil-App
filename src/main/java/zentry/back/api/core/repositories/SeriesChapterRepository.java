package zentry.back.api.core.repositories;

import zentry.back.api.core.models.SeriesChapter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SeriesChapterRepository extends JpaRepository<SeriesChapter, Integer> {
   
}