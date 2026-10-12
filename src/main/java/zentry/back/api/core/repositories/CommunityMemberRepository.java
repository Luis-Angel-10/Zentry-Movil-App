package zentry.back.api.core.repositories;

import zentry.back.api.core.models.CommunityMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CommunityMemberRepository extends JpaRepository<CommunityMember, CommunityMember.CommunityMemberId> {
    Integer countByCommunityId(Integer communityId);
    boolean existsByCommunityIdAndUserId(Integer communityId, Integer userId);
    Optional<CommunityMember> findByCommunityIdAndUserId(Integer communityId, Integer userId);
    void deleteByCommunityId(Integer communityId);
}