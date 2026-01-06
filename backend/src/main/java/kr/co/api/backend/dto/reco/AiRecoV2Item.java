package kr.co.api.backend.dto.reco;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AiRecoV2Item {

    private String productId;
    private int rank;
    private double score; // 있으면 좋고 없어도 됨
}

