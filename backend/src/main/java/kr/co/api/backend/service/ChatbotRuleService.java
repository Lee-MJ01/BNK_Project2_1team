package kr.co.api.backend.service;

import kr.co.api.backend.dto.ChatbotBadTypeDTO;
import kr.co.api.backend.dto.ChatbotBadWordDTO;
import kr.co.api.backend.dto.ChatbotRulesDTO;
import kr.co.api.backend.mapper.ChatbotRuleMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.regex.Pattern;

@Service
@Slf4j
@RequiredArgsConstructor
public class ChatbotRuleService {

    private final ChatbotRuleMapper chatbotRuleMapper;

    public List<ChatbotBadTypeDTO> selectBadTypeList() {
        return chatbotRuleMapper.selectBadTypeList();
    }


    public List<ChatbotBadWordDTO> selectBadWordList() {
        return chatbotRuleMapper.selectBadWordList();
    }


    public List<ChatbotRulesDTO> selectRulesList() {
        return chatbotRuleMapper.selectRulesList();
    }

    public String checkForbiddenWord(String q) {
        List<ChatbotBadWordDTO> badWords = chatbotRuleMapper.getActiveWords(); // BAD_USE_YN='Y'
        List<ChatbotBadTypeDTO> badTypes = chatbotRuleMapper.selectBadTypeList(); // type→answer 맵핑

        for (ChatbotBadWordDTO w : badWords) {
            if (w.getBadType() == 1) {
                // 욕설/비속어 : 단순 포함 체크
                if (q.contains(w.getBadWord())) {
                    return badTypes.get(0).getBtAnswer();
                }
            } else if (w.getBadType() == 2) {
                // 개인정보 : 정규식 패턴 매칭
                if (Pattern.compile(w.getBadWord()).matcher(q).find()) {

                    return badTypes.get(1).getBtAnswer();
                }
            } else if (w.getBadType() == 3) {
                //
                if (q.contains(w.getBadWord())) {

                    return badTypes.get(2).getBtAnswer();
                }
            }
        }

        if (Pattern.compile("^(?=.*혜택)(?=.*상품).*").matcher(q).find()){
            return """
아래는 혜택 중심으로 추천드리는<br/>
‘슈카월드 X 플로뱅크 달러 풀링 예금’ 안내입니다. <br/><br/>

** 슈카월드 X 플로뱅크 달러 풀링 예금 **
<br/><br/>
- 상품 특징: 구독자 361만 ‘슈카월드’와 함께하는 공동구매형 달러 예금
<br/><br/>
- 금리 구조: 참여 인원이 많아질수록 금리가 상승
<br/><br/>
- 최대 금리: 연 5.2%
<br/><br/>
- 혜택: 하와이 왕복 항공권 포함 경품 추첨 진행
<br/><br/>
- 참여 방식: 신청만 해도 자동 이벤트 참여
<br/><br/>
현재 사전 신청 기간으로, 단순 금리 이상의 혜택을 기대할 수 있어 지금 가장 문의가 많은 상품입니다.
자세한 정보는 이벤트 페이지에서 확인하실 수 있습니다.
<br/><br/>
🎁 <a href="/flobank/test/lounge">이벤트 페이지 바로가기</a>
                    """;
        }

        if (Pattern.compile("^(?=.*송금)(?=.*어떻게).*").matcher(q).find()){
            return """
                    해외 송금 절차에 관해 안내드리겠습니다.
                    <br><br>
                    1. 금액/통화 입력<br>
                    - 송금할 금액·통화를 입력합니다.
                    <br><br>
                    2. 환율·적용 금액 확인<br>
                    - 적용 환율 및 수취(혹은 출금) 금액을 확인합니다.
                    <br><br>
                    3. 정보 확인 및 전자서명<br>
                    - 송금 정보·수취인 정보 확인 후 전자서명을 진행합니다.
                    <br><br>
                    4. 송금 완료<br>
                    - 송금이 처리되며 거래내역이 생성됩니다.
                    """;
        }

        return null; // 필터 대상 아님
    }

    public String checkAllForbiddenWord(String q) {
        List<ChatbotBadWordDTO> badWords = chatbotRuleMapper.selectBadWordList(); // BAD_USE_YN='Y'
        List<ChatbotBadTypeDTO> badTypes = chatbotRuleMapper.selectBadTypeList(); // type→answer 맵핑


        for (ChatbotBadWordDTO w : badWords) {
            if (w.getBadType() == 1) {
                // 🔹 욕설/비속어 : 단순 포함 체크
                if (q.contains(w.getBadWord())) {
                    return badTypes.get(0).getBtAnswer();
                }
            } else if (w.getBadType() == 2) {
                // 🔹 개인정보 : 정규식 패턴 매칭
                if (Pattern.compile(w.getBadWord()).matcher(q).find()) {

                    return badTypes.get(1).getBtAnswer();
                }
            }
        }
        return null; // 필터 대상 아님
    }

    public void insertBadWords(ChatbotBadWordDTO badWordDTO) {
        chatbotRuleMapper.insertBadWords(badWordDTO);
    }
}
