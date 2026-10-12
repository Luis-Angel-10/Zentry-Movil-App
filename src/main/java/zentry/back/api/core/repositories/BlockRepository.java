package zentry.back.api.core.repositories;

import zentry.back.api.core.models.Block;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BlockRepository extends JpaRepository<Block, Block.BlockId> {
   
}