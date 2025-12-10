package kr.co.api.backend.dto;

import java.util.List;

public class EmbeddingRespDTO {
    public String object;
    public List<EmbeddingData> data;
    public String model;
    public Usage usage;

    public static class EmbeddingData {
        public String object;
        public List<Double> embedding;
        public int index;
    }

    public static class Usage {
        public int prompt_tokens;
        public int total_tokens;
    }
}
