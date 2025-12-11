package kr.co.api.backend.service;

import kr.co.api.backend.dto.DepositRateDTO;
import kr.co.api.backend.dto.InterestInfoDTO;
import kr.co.api.backend.dto.ProductDTO;
import kr.co.api.backend.dto.TermsHistDTO;
import kr.co.api.backend.mapper.WhiteListMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class WhiteListService {
    private final WhiteListMapper whiteListMapper;

    public String queryAndFormat(String templateName) {

        return switch (templateName) {
            case "flobankDepositProduct" -> {

                List<String> list = whiteListMapper.dpstIdList();
                StringBuilder sb = new StringBuilder();

                List<ProductDTO> dtoList = new ArrayList<>();
                for (String dpstId : list) {
                    dtoList = whiteListMapper.dpstAllInfo(dpstId);
                    if (dtoList.isEmpty()) {
                        continue;
                    }
                    sb.append(flobankDepositProduct(dtoList))
                    .append("\n\n");
                }


                yield sb.toString();
            }
            case "flobankInterest" -> {
                List<DepositRateDTO> dtoList = whiteListMapper.interestsInfo();
                yield flobankInterestInfo(dtoList);
            }
            case "registerTerms" -> {
                List<TermsHistDTO> terms = whiteListMapper.selectLatestTermsByCate(1);
                yield flobankTerms(terms);
            }
            case "fxTerms" -> {
                List<TermsHistDTO> terms = whiteListMapper.selectLatestTermsByCate(2);
                yield flobankTerms(terms);
            }
            case "remitTerms" -> {
                List<TermsHistDTO> terms = whiteListMapper.selectLatestTermsByCate(3);
                yield flobankTerms(terms);
            }
            case "depositTerms" -> {
                List<TermsHistDTO> terms = whiteListMapper.selectLatestTermsByCate(4);
                yield flobankTerms(terms);
            }
            case "krwAcctTerms" -> {
                List<TermsHistDTO> terms = whiteListMapper.selectLatestTermsByCate(5);
                yield flobankTerms(terms);
            }
            case "fxAcctTerms" -> {
                List<TermsHistDTO> terms = whiteListMapper.selectLatestTermsByCate(6);
                yield flobankTerms(terms);
            }



            default -> "";
        };
    }

    private String flobankInterest(List<InterestInfoDTO> dtoList) {
        StringBuilder sb = new StringBuilder();
        String a = "";

        for (InterestInfoDTO interest : dtoList) {

            if (interest.getInterestMonth()==0){
                a = "플로뱅크 " + interest.getInterestCurrency() +" 1개월 미만 예치 금리 : 거주자 " + interest.getInterestRate() + "%\n";
            }else if (interest.getInterestMonth()==1){
                a = "플로뱅크 " + interest.getInterestCurrency() +" " + interest.getInterestMonth() + "개월 이상 3개월 미만 예치 금리 : 거주자 " + interest.getInterestRate() + "%\n";
            }else if (interest.getInterestMonth()==3){
                a = "플로뱅크 " + interest.getInterestCurrency() +" " + interest.getInterestMonth() + "개월 이상 6개월 미만 예치 금리 : 거주자 " + interest.getInterestRate() + "%\n";
            }else if (interest.getInterestMonth()==6){
                a = "플로뱅크 " + interest.getInterestCurrency() +" " + interest.getInterestMonth() + "개월 이상 12개월 미만 예치 금리 : 거주자 " + interest.getInterestRate() + "%\n";
            }else {
                a = "플로뱅크 " + interest.getInterestCurrency() +" " + interest.getInterestMonth() + "개월 이상 예치 금리 : 거주자 " + interest.getInterestRate() + "%\n";
            }
            sb.append(a);
        }

        return sb.toString();

    }

    private String flobankInterestInfo(List<DepositRateDTO> dtoList) {
        StringBuilder sb = new StringBuilder();
        String a = "";

        for (DepositRateDTO interest : dtoList) {

            a = "플로뱅크 " + interest.getCurrency() + " 외화예금 금리\n";
            a += "플로뱅크 " + interest.getCurrency() + " 1개월 금리 : " + interest.getRate1M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 2개월 금리 : " + interest.getRate2M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 3개월 금리 : " + interest.getRate3M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 4개월 금리 : " + interest.getRate4M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 5개월 금리 : " + interest.getRate5M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 6개월 금리 : " + interest.getRate6M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 7개월 금리 : " + interest.getRate7M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 8개월 금리 : " + interest.getRate8M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 9개월 금리 : " + interest.getRate9M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 10개월 금리 : " + interest.getRate10M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 11개월 금리 : " + interest.getRate11M() + "\n";
            a += "플로뱅크 " + interest.getCurrency() + " 12개월 금리 : " + interest.getRate12M() + "\n";
            sb.append(a);
        }

        return sb.toString();

    }


    private String flobankDepositProduct(List<ProductDTO> dtoList) {


        String dpstName = dtoList.get(0).getDpstName();
        String dpstInfo = dtoList.get(0).getDpstInfo();
        String dpstType;
        if (dtoList.get(0).getDpstType() == 1){
            dpstType = "거치식 예금";
        }else {
            dpstType = "자유적립식 예금";
        }
        String dpstCurrency = dtoList.get(0).getDpstCurrency();
        String dpstRateType;
        if (dtoList.get(0).getDpstRateType() == 1){
            dpstRateType = "가입시점환율형";
        }else {
            dpstRateType = "만기시점환율형";
        }
        String dpstDescript =  dtoList.get(0).getDpstDescript();

        String dpstAutoRenewYn;
        if (dtoList.get(0).getDpstAutoRenewYn().equals("Y")){
            dpstAutoRenewYn = "가능";
        }else {
            dpstAutoRenewYn = "불가능";
        }
        String dpstAddPay;
        if (dtoList.get(0).getDpstAddPayYn().equals("Y")){
            dpstAddPay = "가능, 추가납입 최대 "+dtoList.get(0).getDpstAddPayMax()+"회";
        }else{
            dpstAddPay = "불가능";
        }
        String dpstRegDt = dtoList.get(0).getDpstRegDt().toString();

        String dpstAge;
        if (dtoList.get(0).getDpstMinAge() == null && dtoList.get(0).getDpstMaxAge() == null){
            dpstAge = "제한 없음";
        }else if (dtoList.get(0).getDpstMinAge() == null){
            dpstAge =  "만 " + dtoList.get(0).getDpstMaxAge()+"세 이하";
        }else if (dtoList.get(0).getDpstMaxAge() == null){
            dpstAge = "만 " + dtoList.get(0).getDpstMinAge()+"세 이상";
        }else {
            dpstAge = "만 " + dtoList.get(0).getDpstMinAge()+"세 이상, 만 "+dtoList.get(0).getDpstMaxAge()+"세 이하";
        }

        String dpstPeriod;
        if (dtoList.get(0).getDpstPeriodType()==1){
            dpstPeriod = dtoList.get(0).getPeriodMinMonth()+"개월 ~ "+dtoList.get(0).getPeriodMaxMonth() +"개월";
        }else {
            dpstPeriod = dtoList.get(0).getPeriodFixedMonth() + "";
            int fixed = dtoList.get(0).getPeriodFixedMonth();
            for (ProductDTO d : dtoList){
                if (d.getPeriodFixedMonth() != fixed){
                    dpstPeriod = dpstPeriod + ", " + d.getPeriodFixedMonth();
                    fixed = d.getPeriodFixedMonth();
                }
            }
            dpstPeriod = dpstPeriod + "개월";
        }

        String dpstPartWdrw;
        if (dtoList.get(0).getDpstPartWdrwYn().equals("N")){
            dpstPartWdrw = "불가능";
        }else {
            dpstPartWdrw = "최소" + dtoList.get(0).getWdrwMinMonth()+"개월 이상 예치된 계좌, 최대 "+dtoList.get(0).getWdrwMax()+"회";
            if (dtoList.get(0).getAmtCurrency() != null){
                String cur = dtoList.get(0).getAmtCurrency();
                dpstPartWdrw = dpstPartWdrw + " (통화별 최소인출금액 : " + cur +" "+ dtoList.get(0).getAmtMin();
                for (ProductDTO d : dtoList){
                    if (!d.getAmtCurrency().equals(cur)){
                        dpstPartWdrw = dpstPartWdrw + ", " + d.getAmtCurrency() + " "+ d.getAmtMin();
                        cur = d.getAmtCurrency();
                    }
                }
            }
            dpstPartWdrw = dpstPartWdrw + ")";
        }

        String lcur = dtoList.get(0).getLmtCurrency();
        String moneyLimit = "";
        if (dtoList.get(0).getDpstMinYn().equals("Y") && dtoList.get(0).getDpstMaxYn().equals("Y")){
            moneyLimit = "(최소 "+dtoList.get(0).getLmtMinAmt()+" "+lcur+", 최대 "+dtoList.get(0).getLmtMaxAmt()+" "+lcur;
            for (ProductDTO d : dtoList){
                if (!d.getLmtCurrency().equals(lcur)){
                    lcur = d.getLmtCurrency();
                    moneyLimit = moneyLimit +"/ 최소"+ d.getLmtMinAmt() + " "+lcur+ ", 최대 " + d.getLmtMaxAmt() + " " + lcur;
                }
            }
            moneyLimit = moneyLimit + ")";
        }else if (dtoList.get(0).getDpstMinYn().equals("Y")) {
            moneyLimit = "최대 금액 없음, (최소 "+dtoList.get(0).getLmtMinAmt()+" "+lcur;
            for (ProductDTO d : dtoList){
                if (!d.getLmtCurrency().equals(lcur)){
                    lcur = d.getLmtCurrency();
                    moneyLimit = moneyLimit +"/ 최소"+ d.getLmtMinAmt() + " "+lcur;
                }
            }
            moneyLimit = moneyLimit + ")";
        }else if (dtoList.get(0).getDpstMaxYn().equals("Y")) {
            moneyLimit = "최소 금액 없음, (최대 "+dtoList.get(0).getLmtMaxAmt()+" "+lcur;
            for (ProductDTO d : dtoList){
                if (!d.getLmtCurrency().equals(lcur)){
                    lcur = d.getLmtCurrency();
                    moneyLimit = moneyLimit +"/ 최대 " + d.getLmtMaxAmt() + " " + lcur;
                }
            }
            moneyLimit = moneyLimit + ")";
        }else {
            moneyLimit = "없음";
        }




        return """
        [플로뱅크 예금상품 정보]
        예금 이름 : %s
        예금 개요 : %s
        예금 타입 : %s
        적용 통화 : %s
        환율 적용 : %s
        최소/최대 금액 제한 : %s
        가입 기간 : %s
        상품 설명 : %s
        분할 인출 : %s
        나이 제한 : %s
        자동 갱신 : %s
        추가 납입 : %s
        """.formatted(
                dpstName,
                dpstInfo,
                dpstType,
                dpstCurrency,
                dpstRateType,
                moneyLimit,
                dpstPeriod,
                dpstDescript,
                dpstPartWdrw,
                dpstAge,
                dpstAutoRenewYn,
                dpstAddPay
        );
    }

    public String flobankTerms(List<TermsHistDTO> terms) {
        StringBuilder sb = new StringBuilder();
        String a = "";
        int i=1;

        for (TermsHistDTO t : terms) {
            a = (i++) + ". " + t.getTermTitle() + "\n" + t.getThistContent() +"\n\n";
            sb.append(a);
        }

        return sb.toString();
    }


}
