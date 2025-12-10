package kr.co.api.backend.document;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.*;

import java.time.LocalDate;


@Data
@Document(indexName = "event")
@Setting(settingPath = "elastic/common-setting.json")
@Mapping(mappingPath = "elastic/event-mapping.json")
public class EventDocument {

    @Id
    private String boardNo; // 게시글 번호 (Primary Key 역할)

    @Field(type = FieldType.Text, analyzer = "nori")
    private String boardTitle; // 게시글 제목 (mapToSearchResultItem에서 사용)

    @Field(type = FieldType.Text, analyzer = "nori")
    private String boardContent; // 게시글 내용 (mapToSearchResultItem에서 사용)

    @Field(type = FieldType.Text, analyzer = "nori")
    private String eventBenefit; // 이벤트 혜택 (검색 필드로 사용)

    @Field(type = FieldType.Date, format = DateFormat.date)
    private LocalDate boardRegDt;

    // 자동완성을 위한 필드
    @CompletionField(maxInputLength = 100, preserveSeparators = true)
    private Completion suggest;
}