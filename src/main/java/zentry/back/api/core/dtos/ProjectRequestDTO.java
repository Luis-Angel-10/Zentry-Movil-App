package zentry.back.api.core.dtos;

import lombok.Data;
import java.util.List;

@Data
public class ProjectRequestDTO {
    private String title;
    private String description;
    private String category;
    private String priority;
    private String status; // "active", "completed", "paused"
    private String deadline;
    private List<String> tags;
}
