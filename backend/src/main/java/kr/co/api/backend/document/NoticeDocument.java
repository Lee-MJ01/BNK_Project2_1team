package kr.co.api.backend.document;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.*;

import java.time.LocalDate;

@Data
@Document(indexName = "notice")
@Setting(settingPath = "elastic/common-setting.json")
@Mapping(mappingPath = "elastic/notice-mapping.json")
public class NoticeDocument {

    @Id
    private String boardNo; // 게시글 번호 (Primary Key 역할)

    @Field(type = FieldType.Text, analyzer = "nori")
    private String boardTitle; // 게시글 제목 (mapToSearchResultItem에서 사용)

    @Field(type = FieldType.Text, analyzer = "nori")
    private String boardContent; // 게시글 내용 (mapToSearchResultItem에서 사용)

    @Field(type = FieldType.Date, format = DateFormat.date)
    private LocalDate boardRegDt;

    // 자동완성을 위한 필드
    @CompletionField(maxInputLength = 100, preserveSeparators = true)
    private Completion suggest;
}