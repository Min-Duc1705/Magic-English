package vn.nhomx.magic_english.model.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AddVocabularyRequest {
    @NotBlank(message = "Word is required")
    private String word;
}
