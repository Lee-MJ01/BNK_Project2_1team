package kr.co.api.backend.document;


public class Completion {

    private String[] input;
    private Integer weight;

    // 기본 생성자 (필수)
    public Completion() {}

    // 우리가 사용하는 생성자
    public Completion(String[] input) {
        this.input = input;
        this.weight = 1; // 기본 가중치
    }

    //  Getter & Setter
    public String[] getInput() {
        return input;
    }

    public void setInput(String[] input) {
        this.input = input;
    }

    public Integer getWeight() {
        return weight;
    }

    public void setWeight(Integer weight) {
        this.weight = weight;
    }
}