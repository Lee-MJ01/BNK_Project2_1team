package kr.co.api.backend.document;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.*;


@Data
@Document(indexName = "product")
@Setting(settingPath = "elastic/common-setting.json")
@Mapping(mappingPath = "elastic/product-mapping.json")
public class ProductDocument {

    @Id
    private String dpstId; // 상품 ID (Primary Key 역할)

    @Field(type = FieldType.Text, analyzer = "nori") // "외화예금" -> "외화", "예금"으로 쪼개서 저장함
    private String dpstName;

    @Field(type = FieldType.Text, analyzer = "nori")
    private String dpstInfo;

    @Field(type = FieldType.Text, analyzer = "nori")
    private String dpstDescript; // 상품 상세 설명 (검색 필드로 사용)

    // 자동완성을 위한 필드
    @CompletionField(maxInputLength = 100, preserveSeparators = true)
    private Completion suggest;

}