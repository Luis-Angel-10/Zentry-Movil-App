package zentry.back.api.core.mappers;

import zentry.back.api.core.dtos.*;
import zentry.back.api.core.models.*;
import java.util.*;

public final class CoreMappers {
    private CoreMappers() {}

    public static UserResponse toResponse(User entity) {
        if (entity == null) return null;
        return UserResponse.builder()
                .id(entity.getId())
                .username(entity.getHandle())
                .email(entity.getEmail())
                .build();
    }

    /*
    public static ProfileResponse toResponse(Profile entity) {
        if (entity == null) return null;
        return ProfileResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .bio(entity.getBio())
                .build();
    }

    public static PostResponse toResponse(Post entity) {
        if (entity == null) return null;
        return PostResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .contenido(entity.getContenido())
                .build();
    }
    */
   
    public static CommentResponse toResponse(Comment entity) {
        if (entity == null) return null;
        return CommentResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .build();
    }

    public static CommentReactionResponse toResponse(CommentReaction entity) {
        if (entity == null) return null;
        return CommentReactionResponse.builder()
                .id(entity.getId())
                .commentId(entity.getCommentId())
                .userId(entity.getUserId())
                .build();
    }

    public static CommentReplyResponse toResponse(CommentReply entity) {
        if (entity == null) return null;
        return CommentReplyResponse.builder()
                .id(entity.getId())
                .commentId(entity.getCommentId())
                .build();
    }

    public static StudioProjectResponse toResponse(StudioProject entity) {
        if (entity == null) return null;
        return StudioProjectResponse.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .description(entity.getDescription())
                .type(entity.getType())
                .contentData(entity.getContentData())
                .mediaUrl(entity.getMediaUrl())
                .tools(entity.getTools())
                .rewardCoins(entity.getRewardCoins())
                .ownerUsername(entity.getOwnerUsername())
                .published(Boolean.TRUE.equals(entity.getPublished()))
                .postId(entity.getPostId())
                .createdAt(entity.getCreatedAt())
                .lastEditedAt(entity.getLastEditedAt())
                .build();
    }

    public static CommunityResponse toResponse(Community entity) {
        if (entity == null) return null;
        return CommunityResponse.builder()
                .id(entity.getId())
                .slug(entity.getSlug())
                .nombre(entity.getNombre())
                .descripcion(entity.getDescripcion())
                .imageUrl(entity.getImageUrl())
                .avatarUrl(entity.getAvatarUrl())
                .bannerUrl(entity.getBannerUrl())
                .categoria(entity.getCategoria())
                .creatorId(entity.getCreatorId())
                .ownerUsername(entity.getOwnerUsername())
                .rules(entity.getRules())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static CommunityMemberResponse toResponse(CommunityMember entity) {
        if (entity == null) return null;
        return CommunityMemberResponse.builder()
                .communityId(entity.getCommunityId())
                .userId(entity.getUserId())
                .build();
    }

    public static FollowResponse toResponse(Follow entity) {
        if (entity == null) return null;
        return FollowResponse.builder()
                .follower(entity.getFollower())
                .following(entity.getFollowing())
                .build();
    }

    public static FriendshipResponse toResponse(Friendship entity) {
        if (entity == null) return null;
        return FriendshipResponse.builder()
                .user1(entity.getUser1())
                .user2(entity.getUser2())
                .build();
    }

    public static FriendRequestResponse toResponse(FriendRequest entity) {
        if (entity == null) return null;
        return FriendRequestResponse.builder()
                .id(entity.getId())
                .user1(entity.getUser1())
                .user2(entity.getUser2())
                .build();
    }

    public static BlockResponse toResponse(Block entity) {
        if (entity == null) return null;
        return BlockResponse.builder()
                .userId(entity.getUserId())
                .blockedId(entity.getBlockedId())
                .build();
    }

    public static BookmarkResponse toResponse(Bookmark entity) {
        if (entity == null) return null;
        return BookmarkResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .postId(entity.getPostId())
                .build();
    }

    public static CategoryResponse toResponse(Category entity) {
        if (entity == null) return null;
        return CategoryResponse.builder()
                .id(entity.getId())
                .nombre(entity.getNombre())
                .build();
    }

    public static SubcategoryResponse toResponse(Subcategory entity) {
        if (entity == null) return null;
        return SubcategoryResponse.builder()
                .id(entity.getId())
                .categoriaId(entity.getCategoriaId())
                .build();
    }

    public static TagResponse toResponse(Tag entity) {
        if (entity == null) return null;
        return TagResponse.builder()
                .id(entity.getId())
                .nombre(entity.getNombre())
                .build();
    }

    public static PostTagResponse toResponse(PostTag entity) {
        if (entity == null) return null;
        return PostTagResponse.builder()
                .postId(entity.getPostId())
                .tagId(entity.getTagId())
                .build();
    }

    public static PostMediaResponse toResponse(PostMedia entity) {
        if (entity == null) return null;
        return PostMediaResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .url(entity.getUrl())
                .build();
    }

    public static PostVersionResponse toResponse(PostVersion entity) {
        if (entity == null) return null;
        return PostVersionResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .contenido(entity.getContenido())
                .build();
    }

    public static MediaResponse toResponse(Media entity) {
        if (entity == null) return null;
        return MediaResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .url(entity.getUrl())
                .build();
    }

    public static MentionResponse toResponse(Mention entity) {
        if (entity == null) return null;
        return MentionResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static NotificationResponse toResponse(Notification entity) {
        if (entity == null) return null;
        return NotificationResponse.builder()
                .id(entity.getId())
                .type(entity.getType())
                .content(entity.getContent())
                .sourceUsername(entity.getSourceUsername())
                .sourceAvatarUrl(entity.getSourceAvatarUrl())
                .relatedId(entity.getRelatedId())
                .read(Boolean.TRUE.equals(entity.getRead()))
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static ReactionResponse toResponse(Reaction entity) {
        if (entity == null) return null;
        return ReactionResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .build();
    }

    public static ReportResponse toResponse(Report entity) {
        if (entity == null) return null;
        return ReportResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static ShareResponse toResponse(Share entity) {
        if (entity == null) return null;
        return ShareResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .build();
    }

    public static SeriesResponse toResponse(Series entity) {
        if (entity == null) return null;
        return SeriesResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static SeriesChapterResponse toResponse(SeriesChapter entity) {
        if (entity == null) return null;
        return SeriesChapterResponse.builder()
                .id(entity.getId())
                .seriesId(entity.getSeriesId())
                .build();
    }

    public static AuditLogResponse toResponse(AuditLog entity) {
        if (entity == null) return null;
        return AuditLogResponse.builder()
                .id(entity.getId())
                .accion(entity.getAccion())
                .build();
    }

    public static FeatureFlagResponse toResponse(FeatureFlag entity) {
        if (entity == null) return null;
        return FeatureFlagResponse.builder()
                .id(entity.getId())
                .nombre(entity.getNombre())
                .build();
    }

    public static SystemConfigResponse toResponse(SystemConfig entity) {
        if (entity == null) return null;
        return SystemConfigResponse.builder()
                .id(entity.getId())
                .clave(entity.getClave())
                .build();
    }

    public static LoginHistoryResponse toResponse(LoginHistory entity) {
        if (entity == null) return null;
        return LoginHistoryResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .ip(entity.getIp())
                .build();
    }

    public static UserDeviceResponse toResponse(UserDevice entity) {
        if (entity == null) return null;
        return UserDeviceResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .dispositivo(entity.getDispositivo())
                .build();
    }

    public static UserSessionResponse toResponse(UserSession entity) {
        if (entity == null) return null;
        return UserSessionResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .token(entity.getToken())
                .build();
    }

    public static UserPreferencesResponse toResponse(UserPreferences entity) {
        if (entity == null) return null;
        return UserPreferencesResponse.builder()
                .userId(entity.getUserId())
                .config(entity.getConfig())
                .build();
    }

    public static UserPrivacyResponse toResponse(UserPrivacy entity) {
        if (entity == null) return null;
        return UserPrivacyResponse.builder()
                .userId(entity.getUserId())
                .nivel(entity.getNivel())
                .build();
    }

    public static UserSettingsResponse toResponse(UserSettings entity) {
        if (entity == null) return null;
        return UserSettingsResponse.builder()
                .userId(entity.getUserId())
                .privacidad(entity.getPrivacidad())
                .build();
    }

    public static ForumThreadResponse toResponse(ForumThread entity) {
        if (entity == null) return null;
        return ForumThreadResponse.builder()
                .id(entity.getId())
                .communityId(entity.getCommunityId())
                .build();
    }

    public static ForumReplyResponse toResponse(ForumReply entity) {
        if (entity == null) return null;
        return ForumReplyResponse.builder()
                .id(entity.getId())
                .threadId(entity.getThreadId())
                .build();
    }
    public static TrendingTopicResponse toResponse(TrendingTopic entity) {
        if (entity == null) return null;
        return TrendingTopicResponse.builder()
                .id(entity.getId())
                .hashtag(entity.getHashtag())
                .category(entity.getCategory())
                .postsCount(entity.getPostsCount())
                .isHot(entity.getIsHot())
                .year(entity.getYear())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public static WalletTransactionResponse toResponse(WalletTransaction entity) {
        if (entity == null) return null;
        return WalletTransactionResponse.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .type(entity.getType())
                .amount(entity.getAmount())
                .description(entity.getDescription())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static WalletResponse toResponse(Wallet entity, java.util.List<WalletTransaction> transactions) {
        if (entity == null) return null;
        java.util.List<WalletTransactionResponse> txList = (transactions == null) ? java.util.Collections.emptyList() :
                transactions.stream().map(CoreMappers::toResponse).collect(java.util.stream.Collectors.toList());

        return WalletResponse.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .balance(entity.getBalance())
                .activePlanId(entity.getActivePlanId())
                .nextBillingDate(entity.getNextBillingDate())
                .transactions(txList)
                .build();
    }

    public static StoryResponse toResponse(Story entity) {
        if (entity == null) return null;
        return StoryResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .mediaUrl(entity.getMediaUrl())
                .mediaType(entity.getMediaType())
                .textContent(entity.getTextContent())
                .textColor(entity.getTextColor())
                .background(entity.getBackground())
                .fontStyle(entity.getFontStyle())
                .caption(entity.getCaption())
                .musicTitle(entity.getMusicTitle())
                .musicArtist(entity.getMusicArtist())
                .musicUrl(entity.getMusicUrl())
                .linkUrl(entity.getLinkUrl())
                .duration(entity.getDuration())
                .createdAt(entity.getCreatedAt())
                .expiresAt(entity.getExpiresAt())
                .viewCount(entity.getViewCount())
                .likesCount(entity.getLikesCount())
                .isArchived(entity.getIsArchived())
                .build();
    }
}
