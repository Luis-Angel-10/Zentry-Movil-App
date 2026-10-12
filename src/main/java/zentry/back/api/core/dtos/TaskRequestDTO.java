package zentry.back.api.core.dtos;

import lombok.Data;

@Data
public class TaskRequestDTO {
    private String title;
    private String priority; // "baja", "media", "alta"
    private String assignedTo;
    private String dueDate;
}
