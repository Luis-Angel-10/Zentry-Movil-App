package zentry.back.api.ai.models;

import java.io.Serializable;
import java.util.Objects;

public class IaSimilarityUsersId implements Serializable {
    private Integer user1;
    private Integer user2;

    public IaSimilarityUsersId() {}

    public IaSimilarityUsersId(Integer user1, Integer user2) {
        this.user1 = user1;
        this.user2 = user2;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof IaSimilarityUsersId)) return false;
        IaSimilarityUsersId that = (IaSimilarityUsersId) o;
        return Objects.equals(user1, that.user1) && Objects.equals(user2, that.user2);
    }

    @Override
    public int hashCode() {
        return Objects.hash(user1, user2);
    }
}
