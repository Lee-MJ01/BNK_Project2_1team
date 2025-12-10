package kr.co.api.backend.document;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.*;

@Data
@Document(indexName = "faq")
@Setting(settingPath = "elastic/common-setting.json")
@Mapping(mappingPath = "elastic/faq-mapping.json")
public class FaqDocument {

    @Id
    private String faqNo; // FAQ 번호 (Primary Key 역할)

    @Field(type = FieldType.Text, analyzer = "nori")
    private String faqQuestion; // 질문 (mapToSearchResultItem에서 사용)

    @Field(type = FieldType.Text, analyzer = "nori")
    private String faqAnswer; // 답변 (mapToSearchResultItem에서 사용)

    // 자동완성을 위한 필드
    @CompletionField(maxInputLength = 100, preserveSeparators = true)
    private Completion suggest;
}