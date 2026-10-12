package zentry.back.api.core.util;

public final class RankUtil {

    private RankUtil() {}

    private static final long[] THRESHOLDS = {0, 100, 300, 700, 1500, 3000};
    private static final String[] NAMES = {"Bronce", "Plata", "Oro", "Platino", "Diamante", "Leyenda"};

    public record RankInfo(String name, long minScore, Long nextThreshold) {}

    public static RankInfo forScore(long reputationScore) {
        int idx = 0;
        for (int i = 0; i < THRESHOLDS.length; i++) {
            if (reputationScore >= THRESHOLDS[i]) idx = i;
        }
        Long next = idx + 1 < THRESHOLDS.length ? THRESHOLDS[idx + 1] : null;
        return new RankInfo(NAMES[idx], THRESHOLDS[idx], next);
    }

    public static String[] tierNames() {
        return NAMES;
    }

    public static long[] tierThresholds() {
        return THRESHOLDS;
    }
}
