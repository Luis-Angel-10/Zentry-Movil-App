package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserStatsResponse {
    @JsonProperty("user_id")
    private Integer userId;

    private String username;

    @JsonProperty("posts_count")
    private long postsCount;

    @JsonProperty("followers_count")
    private long followersCount;

    @JsonProperty("following_count")
    private long followingCount;

    @JsonProperty("friends_count")
    private long friendsCount;

    @JsonProperty("zentry_coins")
    private long zentryCoins;

    @JsonProperty("coins_today")
    private long coinsToday;

    @JsonProperty("reputation_score")
    private long reputationScore;

    private String rank;

    @JsonProperty("rank_min_score")
    private long rankMinScore;

    @JsonProperty("next_rank_score")
    private Long nextRankScore;
}
