package kr.co.api.backend.dto.reco;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter @Setter
public class RecoRerankResponse {
    private Long surveyId;
    private String custCode;
    private List<Item> items;

    @Getter @Setter
    public static class Item {
        private String productId;
        private int rank;       // 1~3
        private double score;   // v2 score
    }
}


