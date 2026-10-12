package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SeriesChapterResponse {

    private Integer id;
    private Integer seriesId;
}
