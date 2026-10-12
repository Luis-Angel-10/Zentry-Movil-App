package zentry.back.api.core.dtos;

import lombok.Data;

@Data
public class NoteRequestDTO {
    private String content;
    private String author;
}
