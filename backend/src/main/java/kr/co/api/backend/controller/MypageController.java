package kr.co.api.backend.controller;

import jakarta.servlet.http.HttpSession;
import kr.co.api.flobankapi.dto.*;
import kr.co.api.flobankapi.dto.TermsHistDTO;
import kr.co.api.flobankapi.jwt.CustomUserDetails;
import kr.co.api.flobankapi.service.*;
import kr.co.api.flobankapi.util.AesUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Controller
@RequestMapping("/mypage")
@Slf4j
@RequiredArgsConstructor
public class MypageController {
    private final TermsDbService termsService;
    private final MypageService mypageService;

    private final QTypeClassifierService typeClassifier;
    private final EmbeddingService embeddingService;
    private final PineconeService pineconeService;
    private final ChatGPTService chatGPTService;

    private final PasswordEncoder passwordEncoder;

    @GetMapping({"/main", "/"})
    public String mypage(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {

        String userCode = userDetails.getUsername();
        CustInfoDTO custInfo = mypageService.getCustInfo(userCode);
        List<CustAcctDTO> custAcctDTOList = mypageService.findAllAcct(userCode);
        CustFrgnAcctDTO custFrgnAcctDTO = mypageService.findFrgnAcct(userCode);

        CustFrgnAcctDTO frgnAcct = mypageService.findFrgnAcct(userCode);
        List<FrgnAcctBalanceDTO> frgnBalanceList = new ArrayList<>();

        if (frgnAcct != null) {
            // 외화 계좌(모체)가 있으면 -> 자식 계좌 리스트(USD, JPY...) 조회
            frgnBalanceList = mypageService.getAllFrgnAcctBal(frgnAcct.getFrgnAcctNo());
            model.addAttribute("custFrgnAcctDTO", frgnAcct);
        }


        List<CouponDTO> couponList = mypageService.getCouponList(userCode);
        model.addAttribute("couponList", couponList);
        model.addAttribute("frgnBalanceList", frgnBalanceList);
        model.addAttribute("custInfo", custInfo);
        model.addAttribute("custAcctDTOList", custAcctDTOList);
        model.addAttribute("custFrgnAcctDTO", custFrgnAcctDTO);


        List<MypageDpstDTO> dpstList = mypageService.getDpstAcctHdrList(userCode);
        model.addAttribute("dpstList", dpstList);

        log.info(dpstList.toString());

        List<DpstAcctDtlDTO> dpstHistList = mypageService.getDpstAcctHistList(userCode);
        model.addAttribute("dpstHistList", dpstHistList);

        return "mypage/main";
    }

    @PostMapping("/updateAcctName")
    public ResponseEntity<?> updateAcctName(@RequestBody AcctNameUpdateRequestDTO requestDTO) {

        Map<String, Object> response = new HashMap<>();
        log.info("updateAcctName requestDTO:{}", requestDTO);
        try {
            // --- 비즈니스 로직 ---
            // 1. 유효성 검사 (예: requestDTO.getAcctName()의 길이 등)
            // (JavaScript에서 이미 검사했지만, 서버에서도 이중 검사하는 것이 안전합니다)
            String newName = requestDTO.getAcctName();
            if (newName == null || newName.trim().isEmpty() || newName.length() > 20) {
                response.put("status", "error");
                response.put("message", "별명은 1자 이상 20자 이하로 입력하세요.");
                // 400 Bad Request 상태와 에러 메시지를 반환
                return ResponseEntity.badRequest().body(response);
            }

            if ("KRW".equals(requestDTO.getAcctType())) {
                mypageService.modifyAcctName(requestDTO.getAcctName(), requestDTO.getAcctNo());
            } else {
                mypageService.modifyFrgnAcctName(requestDTO.getAcctName(), requestDTO.getAcctNo());
            }

            // 3. 성공 응답 반환
            response.put("status", "success");
            // 200 OK 상태와 성공 메시지를 반환
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("계좌 별명 변경 중 심각한 오류 발생", e);
            // 4. 예기치 못한 서버 오류 처리
            response.put("status", "error");
            response.put("message", "서버 오류로 인해 별명 변경에 실패했습니다.");
            // 500 Internal Server Error 상태와 에러 메시지를 반환
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/account_open_main")
    public String account_open_main() {
        return "mypage/account_open_main";
    }

    @GetMapping("/ko_account_open_1")
    public String openAccountTerms(Model model) {
        int termLocation = 5; // 5번: 원화통장개설 페이지

        List<TermsHistDTO> termsList = termsService.getTermsByLocation(termLocation);

        System.out.println("### termsList size = " + termsList.size());

        model.addAttribute("termsList", termsList);

        return "mypage/ko_account_open_1";
    }

    @GetMapping("/ko_account_open_2")
    public String ko_account_open_2(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {

        if (userDetails == null) {
            return "redirect:/login";
        }

        String userCode = userDetails.getUsername();
        log.info("userCode = " + userCode);
        CustInfoDTO custInfoDTO = mypageService.getCustInfo(userCode);

        // 보안 등급별 1회, 1일 이체한도 고시
        if (custInfoDTO.getCustSecurityLevel().equals(1)) {
            model.addAttribute("dayTrsfLmt", "5억");
            model.addAttribute("onceTrsfLmt", "1억");
        } else if (custInfoDTO.getCustSecurityLevel().equals(2)) {
            model.addAttribute("dayTrsfLmt", "5천만원");
            model.addAttribute("onceTrsfLmt", "1천만원");
        } else if (custInfoDTO.getCustSecurityLevel().equals(3)) {
            model.addAttribute("dayTrsfLmt", "1천만원");
            model.addAttribute("onceTrsfLmt", "1천만원");
        }

        // '남자', '여자'
        if ("M".equals(custInfoDTO.getCustGen())) {
            model.addAttribute("gender", "남자");
        } else {
            model.addAttribute("gender", "여자");
        }

        // 생년월일 마스킹
        String maskedBirth = "";

        if (custInfoDTO.getCustBirthDt() != null) {
            String birthString = custInfoDTO.getCustBirthDt().toString(); //
            maskedBirth = birthString.substring(0, 4) + "-**-**";
        }
        model.addAttribute("maskedBirthDt", maskedBirth);

        model.addAttribute("custInfoDTO", custInfoDTO);
        model.addAttribute("custAcctDTO", new CustAcctDTO()); // View의 폼이 사용할 빈 객체 전달

        return "mypage/ko_account_open_2";
    }

    @PostMapping("/ko_account_open_2")
    public String createAcct(@ModelAttribute CustAcctDTO custAcctDTO, @AuthenticationPrincipal CustomUserDetails userDetails) {

        log.info("custAcctDTO = " + custAcctDTO);
        mypageService.saveAcct(custAcctDTO);

        return "redirect:/mypage/ko_account_open_3";
    }

    @GetMapping("/ko_account_open_3")
    public String ko_account_open_3() {
        return "mypage/ko_account_open_3";
    }

    @GetMapping("/koAcctCheck")
    public String koAcctCheck(@AuthenticationPrincipal CustomUserDetails userDetails, RedirectAttributes redirectAttributes) {

        String userCode = userDetails.getUsername();
        log.info("userId = " + userCode);
        CustInfoDTO custInfoDTO = mypageService.getCustInfo(userCode);
        if (mypageService.checkKoAcct(custInfoDTO.getCustCode())) {
            return "redirect:/mypage/ko_account_open_1";
        } else {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "최근 1개월(30일) 이내에 원화 입출금 통장을 개설한 이력이 있어 신규 개설이 제한됩니다. (금융사기 예방 조치)");
            return "redirect:/mypage/account_open_main";
        }

    }

    @GetMapping("/enAcctCheck")
    public String enAcctCheck(@AuthenticationPrincipal CustomUserDetails userDetails, RedirectAttributes redirectAttributes) {
        String UserCode = userDetails.getUsername();
        log.info("UserCode = " + UserCode);
        CustInfoDTO custInfoDTO = mypageService.getCustInfo(UserCode);
        if (mypageService.checkCntKoAcct(custInfoDTO.getCustCode()) >= 1) {
            int checkCnt = mypageService.checkEnAcct(UserCode);
            if (checkCnt >= 1) {
                redirectAttributes.addFlashAttribute("errorMessage",
                        "이미 외화 입출금통장이 있습니다. 외화 입출금통장은 2개 이상 만들 수 없습니다.");
                return "redirect:/mypage/account_open_main";
            } else {
                return "redirect:/mypage/en_account_open_1";
            }
        } else {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "원화 입출금 통장이 1개 이상 있어야 개설 가능합니다. 원화 입출금 통장을 먼저 만들어주세요.");
            return "redirect:/mypage/account_open_main";
        }

    }

    @GetMapping("/en_account_open_1")
    public String en_account_open_1(Model model) {

        int termLocation = 6; // 6번: 외화통장개설 페이지

        List<TermsHistDTO> termsList = termsService.getTermsByLocation(termLocation);

        System.out.println("### termsList size = " + termsList.size());

        model.addAttribute("termsList", termsList);

        return "mypage/en_account_open_1";
    }

    @GetMapping("/en_account_open_2")
    public String en_account_open_2(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {

        // custInfoDTO 정보 보내기
        String custCode = userDetails.getUsername();
        CustInfoDTO custInfoDTO = mypageService.getCustInfo(custCode);
        model.addAttribute("custInfoDTO", custInfoDTO);

        // 계좌 개설 정보 전달용
        CustFrgnAcctDTO custFrgnAcctDTO = new CustFrgnAcctDTO();
        model.addAttribute("custFrgnAcctDTO", custFrgnAcctDTO);

        // 보안 등급 확인 후 1일, 1회 이체한도 보내기
        if (custInfoDTO.getCustSecurityLevel().equals(3)) {
            model.addAttribute("dayTrsfLmt", "7,000$");
            model.addAttribute("onceTrsfLmt", "7,000$");
        } else if (custInfoDTO.getCustSecurityLevel().equals(2)) {
            model.addAttribute("dayTrsfLmt", "35,000$");
            model.addAttribute("onceTrsfLmt", "7,000$");
        } else if (custInfoDTO.getCustSecurityLevel().equals(1)) {
            model.addAttribute("dayTrsfLmt", "350,000$");
            model.addAttribute("onceTrsfLmt", "70,000$");
        }

        return "mypage/en_account_open_2";
    }

    @PostMapping("/en_account_open_2")
    public String saveEnAcct(@ModelAttribute CustFrgnAcctDTO custFrgnAcctDTO, @AuthenticationPrincipal CustomUserDetails userDetails) {
        String userCode = userDetails.getUsername();
        CustInfoDTO custInfoDTO = mypageService.getCustInfo(userCode);
        custFrgnAcctDTO.setFrgnAcctCustCode(userCode);
        custFrgnAcctDTO.setFrgnAcctCustEngName(custInfoDTO.getCustEngName());

        log.info("custFrgnAcctDTO = " + custFrgnAcctDTO);

        mypageService.saveFrgnAcct(custFrgnAcctDTO);

        return "redirect:/mypage/en_account_open_3";
    }

    @GetMapping("/en_account_open_3")
    public String en_account_open_3() {

        return "mypage/en_account_open_3";
    }

    @PostMapping("/ko_transfer_1")
    public String ko_transfer_1(Model model, @RequestParam("acctNo") String acctNo) {

        // 계좌 정보 보내기
        CustAcctDTO custAcctDTO = mypageService.findCustAcct(acctNo);
        model.addAttribute("custAcctDTO", custAcctDTO);

        // 이체 정보 받을 객체 보내기
        CustTranHistDTO custTranHistDTO = new CustTranHistDTO();
        // 미리 설정할 거
        custTranHistDTO.setTranType(2); // 출금 : 2
        custTranHistDTO.setTranAcctNo(acctNo); // 계좌번호


        model.addAttribute("custTranHistDTO", custTranHistDTO);

        return "mypage/ko_transfer_1";
    }

    // 이체 전 비밀번호 확인
    @PostMapping("/checkAcctPw")
    @ResponseBody
    public ResponseEntity<Map<String, Boolean>> checkAcctPw(@RequestBody Map<String, String> requestData) {

        String acctNo = requestData.get("acctNo");
        String inputPw = requestData.get("accountPw");

        // DB에 저장된 해당 계좌의 비밀번호와 사용자가 입력한 inputPw를 비교하는 로직 수행
        boolean matches = mypageService.checkAcctPw(acctNo, inputPw);

        Map<String, Boolean> response = new HashMap<>();
        response.put("isPwCorrect", matches);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/ko_transfer_2")
    public String ko_transfer_2(Model model,
                                @ModelAttribute CustTranHistDTO custTranHistDTO,
                                @AuthenticationPrincipal CustomUserDetails userDetails,
                                RedirectAttributes redirectAttributes) {

        // 1. 입금 은행 코드 및 계좌번호 추출
        String bankCode = custTranHistDTO.getTranRecBkCode();
        String acctNo = custTranHistDTO.getTranRecAcctNo();
        String realOwnerName = ""; // 조회된 실제 예금주명

        // 2. 은행 코드에 따른 분기 처리 (자행 vs 타행)
        try {
            if ("888".equals(bankCode)) { // 자행
                // [플로은행] 내부 계좌 조회
                CustAcctDTO acct = mypageService.findCustAcct(acctNo);

                if (acct == null) {
                    throw new Exception("존재하지 않는 플로은행 계좌입니다.");
                }

                realOwnerName = acct.getCustName();

            } else { // 타행
                // [외부은행] 타행 계좌 조회 (TB_EXT_ACCT)
                ExtAcctDTO extAcct = mypageService.findExtAcct(acctNo, custTranHistDTO.getTranRecBkCode());

                if (extAcct == null) {
                    throw new Exception("해당 은행에 존재하지 않는 계좌번호입니다.");
                }
                // ExtAcctDTO의 예금주명 필드 (예: extCustName)
                realOwnerName = extAcct.getExtCustName(); // ※실제 DTO 변수명에 맞춰 수정 필요
            }
        } catch (Exception e) {
            // 계좌 검증 실패 시 이전 페이지로 리다이렉트
            log.error("계좌 조회 실패: {}", e.getMessage());
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            // 계좌번호 등 입력했던 정보를 다시 유지하고 싶다면 파라미터로 붙여서 보낼 수 있음
            return "redirect:/mypage/ko_transfer_1?acctNo=" + custTranHistDTO.getTranAcctNo();
        }

        // 3. 검증된 '실제 예금주명'을 DTO에 세팅
        // 사용자가 입력한 값이 있더라도, 금융 실명 확인을 위해 조회된 이름으로 덮어쓰는 것이 안전함
        custTranHistDTO.setTranRecName(realOwnerName);


        // 4. 나머지 데이터(메모 등) 처리
        // '내통장표시'가 비어있으면 -> 사용자 이름(보내는 사람) or 조회된 받는분 이름 등 정책에 따라 설정
        if (custTranHistDTO.getTranCustName() == null || custTranHistDTO.getTranCustName().trim().isEmpty()) {
            // 예: 비어있으면 '나에게' 메모에는 '받는 사람 이름'을 기본으로 입력 등
            // 여기서는 기존 로직 유지 (로그인 유저 이름)
            custTranHistDTO.setTranCustName(userDetails.getCustName());
        }

        model.addAttribute("custTranHistDTO", custTranHistDTO);

        return "mypage/ko_transfer_2";
    }

    // 계좌번호 유효성 검사 API
    @PostMapping("/api/validate-account")
    public ResponseEntity<Map<String, Object>> validateAccount(@RequestBody Map<String, String> requestData) {
        String bankCode = requestData.get("bankCode");
        String acctNo = requestData.get("acctNo");

        boolean exists = false;
        String ownerName = "";

        // 1. 플로은행(888)인 경우
        if ("888".equals(bankCode)) {
            CustAcctDTO acct = mypageService.findCustAcct(acctNo);
            if (acct != null) {
                exists = true;
                // 예금주명 가져오기
                ownerName = acct.getCustName();
            }
        }
        // 2. 타행인 경우 (TB_EXT_ACCT 조회)
        else {
            ExtAcctDTO extAcct = mypageService.findExtAcct(acctNo, bankCode);
            if (extAcct != null) {
                exists = true;
                ownerName = extAcct.getExtCustName();
            }
        }

        Map<String, Object> response = new HashMap<>();
        response.put("exists", exists);
        response.put("ownerName", ownerName); // 필요 시 사용

        return ResponseEntity.ok(response);
    }

    @PostMapping("/ko_transfer_3")
    public String ko_transfer_3(@AuthenticationPrincipal CustomUserDetails userDetails,
                                @ModelAttribute CustTranHistDTO custTranHistDTO,
                                Model model,
                                HttpSession session) {
        // 전자서명 임시 승인 수정해야함

        // 3. [검증 로직 추가] 세션에서 인증 완료 여부 확인 (CertController에서 저장한 값)
        // CertController 로직에 따라 "CERT_STATUS" 또는 "IS_AUTH_COMPLETE" 키 사용
        String certStatus = (String) session.getAttribute("CERT_STATUS"); // 예: "COMPLETE"
        boolean isVerified = "COMPLETE".equals(certStatus);

        if (isVerified) {
            // 인증 성공 시에만 Y로 설정하고 진행
            custTranHistDTO.setTranEsignYn("Y");

            // 이체 실행 (Service 호출)
            mypageService.processCustAcctBal(custTranHistDTO);

            // 인증 정보 1회용이므로 삭제 (선택사항)
            session.removeAttribute("CERT_STATUS");

            model.addAttribute("custTranHistDTO", custTranHistDTO);
            CustAcctDTO custAcctDTO = mypageService.findCustAcct(custTranHistDTO.getTranAcctNo());
            model.addAttribute("custAcctDTO", custAcctDTO);
            model.addAttribute("state", "정상");
        }else {
            // 인증 실패 또는 건너뛰기 시도 시
            custTranHistDTO.setTranEsignYn("N");

            model.addAttribute("custTranHistDTO", custTranHistDTO);
            CustAcctDTO custAcctDTO = mypageService.findCustAcct(custTranHistDTO.getTranAcctNo());
            model.addAttribute("custAcctDTO", custAcctDTO);
            model.addAttribute("state", "실패 (전자서명 미완료)");
        }

        return "mypage/ko_transfer_3";
    }


    @PostMapping("/checkPw")
    @ResponseBody // [필수] JSON 응답을 위해 꼭 필요
    public Map<String, Object> checkPw(@RequestBody Map<String, String> requestData,
                                       @AuthenticationPrincipal CustomUserDetails userDetails) {

        Map<String, Object> response = new HashMap<>();

        try {
            String inputPw = requestData.get("password");
            String userCode = userDetails.getUsername();

            boolean isMatch = mypageService.checkPassword(userCode, inputPw);

            if (isMatch) {
                response.put("status", "success");
            } else {
                response.put("status", "fail");
            }

        } catch (Exception e) {
            log.error("비밀번호 확인 중 에러 발생", e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
        }

        return response;
    }


    @PostMapping("/updateUserInfo")
    @ResponseBody
    public Map<String, Object> updateUserInfo(@RequestBody Map<String, String> requestData,
                                              @AuthenticationPrincipal CustomUserDetails userDetails) {
        Map<String, Object> response = new HashMap<>();
        try {
            String userCode = userDetails.getUsername();
            // 서비스 호출 (데이터 맵과 유저코드를 넘김)
            mypageService.modifyUserInfo(userCode, requestData);
            response.put("status", "success");

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "서버 오류 발생");
        }

        return response;
    }


    @PostMapping("/transactionHistory")
    @ResponseBody
    public Map<String, Object> transactionHistory(@RequestBody Map<String, String> requestData) {
        Map<String, Object> response = new HashMap<>();
        String acctNo = requestData.get("acctNo");

        try {
            Map<String, Object> data = mypageService.getAcctDetailWithHistory(acctNo);

            CustAcctDTO account = (CustAcctDTO) data.get("account");
            List<CustTranHistDTO> histList = (List<CustTranHistDTO>) data.get("history");

            //  JSON 직렬화용 리스트
            List<Map<String, Object>> convertedList = new ArrayList<>();

            for (CustTranHistDTO h : histList) {
                Map<String, Object> row = new HashMap<>();

                row.put("tranDt", h.getTranDt());
                row.put("tranType", h.getTranType());
                row.put("tranMemo", h.getTranMemo());
                row.put("tranRecName", h.getTranRecName());
                row.put("tranRecAcctNo", h.getTranRecAcctNo());
                row.put("tranBalance", h.getTranBalance());

                // BigDecimal → Integer 변환 (핵심)
                BigDecimal amt = h.getTranAmount();
                int amount = (amt != null) ? amt.intValue() : 0;
                row.put("tranAmount", amount);

                convertedList.add(row);
            }

            Map<String, Object> sendData = new HashMap<>();
            sendData.put("account", account);
            sendData.put("history", convertedList);

            response.put("status", "success");
            response.put("data", sendData);

        } catch (Exception e) {
            e.printStackTrace();
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
        }

        return response;
    }


    // UI 나누기 위해!! dpst_transfer_1 매핑 새로 한다!!!!!
    private final DepositService depositService;

    @GetMapping("/dpst_addpay_1")
    public String dpstAddPayStep1(
            @RequestParam String dpstHdrAcctNo,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            Model model
    ) {
        DpstAcctHdrDTO dpst = mypageService.getDpstAcctHdr(dpstHdrAcctNo);
        String cur;
        if (dpst.getDpstHdrLinkedAcctType()==1){
            cur = "KRW";
        }else {
            cur = dpst.getDpstHdrCurrency();
        }
        DpstAcctHdrDTO dpstAcctDTO = mypageService.getDpstAcctHdrAndBal(dpstHdrAcctNo, cur);
        ProductDTO product = depositService.selectDpstProduct(dpstAcctDTO.getDpstHdrDpstId());

        CustTranHistDTO dto = new CustTranHistDTO();

        dto.setTranRecAcctNo(dpstHdrAcctNo);
        dto.setTranRecBkCode("888");
        dto.setTranType(2);
        dto.setTranAcctNo(dpstAcctDTO.getDpstHdrLinkedAcctNo());
        if (dpstAcctDTO.getDpstHdrLinkedAcctType()==1){
            dto.setTranCurrency("KRW");
            dto.setTranExpAcctNo(dto.getTranAcctNo());
        }else {
            dto.setTranCurrency(dpstAcctDTO.getDpstHdrCurrency());
            dto.setTranExpAcctNo(mypageService.getFrgnAcctBal(dpstAcctDTO.getDpstHdrLinkedAcctNo()).getBalFrgnAcctNo());
        }
        dto.setTranCustName(userDetails.getCustName());
        dto.setTranRecName(userDetails.getCustName());

        model.addAttribute("dpstAcctDTO", dpstAcctDTO);
        model.addAttribute("product", product);
        model.addAttribute("custTranHistDTO", dto);

        // 만기시점환율은 transfer1_C
        // 원화계좌 연결돼서 환율 계산 로직 필요한 2가지 경우는 transfer1_A
        // 외화계좌 연결돼서 환율 계산 필요없으면 transfer1_B
        if (product.getDpstRateType() == 2) {
            return "mypage/dpst_transfer1_C";
        }
        if (dpstAcctDTO.getDpstHdrLinkedAcctType() == 1) {
            return "mypage/dpst_transfer1_A";
        }
        return "mypage/dpst_transfer1_B";
    }

    @PostMapping("/calcRate")
    @ResponseBody
    public DepositExchangeDTO calc(@RequestBody Map<String, String> req) {
        System.out.println("⚡ POST /mypage/calcRate 호출됨!");

        String currency = req.get("currency");
        DepositExchangeDTO exDTO = new DepositExchangeDTO();

        BigDecimal bdAmt = new BigDecimal(req.get("amount"));
        String dpstAcctNo = req.get("dpstAcctNo");
        DpstAcctHdrDTO dpstAcctDTO = mypageService.getDpstAcctHdr(dpstAcctNo);

        exDTO.setAppliedRate(dpstAcctDTO.getDpstHdrRate());


        BigDecimal krwAmt = bdAmt.multiply(exDTO.getAppliedRate())
                .setScale(0, RoundingMode.FLOOR);

        exDTO.setKrwAmount(krwAmt);


        return exDTO;
    }

    // //////////////////////////////////////////////////////////


    //하나부터 열까지 다 수정해야 함

    @GetMapping("/dpst_transfer_1")
    public String dpst_transfer_1(Model model, @RequestParam("dpstHdrAcctNo") String dpstHdrAcctNo, @AuthenticationPrincipal CustomUserDetails userDetails) {

        // 계좌 정보 보내기
        DpstAcctHdrDTO dpstAcctDTO = mypageService.getDpstAcctHdr(dpstHdrAcctNo);

        // 이체 정보 받을 객체 보내기
        CustTranHistDTO custTranHistDTO = new CustTranHistDTO();
        double balance;

        if (dpstAcctDTO.getDpstHdrLinkedAcctType()==1){
            // 원화계좌 잔액 불러오기
            balance = mypageService.getKrwAcctBal(dpstAcctDTO.getDpstHdrLinkedAcctNo());
            custTranHistDTO.setTranExpAcctNo(dpstAcctDTO.getDpstHdrLinkedAcctNo());
        } else {
            // 외화자식계좌 잔액, 부모계좌번호 불러오기
            FrgnAcctBalanceDTO dto = mypageService.getFrgnAcctBal(dpstAcctDTO.getDpstHdrLinkedAcctNo());
            balance = dto.getBalBalance();
            custTranHistDTO.setTranExpAcctNo(dto.getBalFrgnAcctNo());
        }

        dpstAcctDTO.setDpstHdrLinkedAcctBal(BigDecimal.valueOf(balance));


        model.addAttribute("dpstAcctDTO", dpstAcctDTO);



        // 미리 설정할 거
        custTranHistDTO.setTranType(2); // 출금 : 2
        custTranHistDTO.setTranRecAcctNo(dpstHdrAcctNo); // 수취계좌번호
        custTranHistDTO.setTranRecBkCode("888");
        custTranHistDTO.setTranCurrency(dpstAcctDTO.getDpstHdrCurrencyExp());
        custTranHistDTO.setTranCustName(userDetails.getCustName());
        custTranHistDTO.setTranAcctNo(dpstAcctDTO.getDpstHdrLinkedAcctNo());
        custTranHistDTO.setTranRecName(userDetails.getCustName());


        model.addAttribute("custTranHistDTO", custTranHistDTO);


        return "mypage/dpst_transfer_1";
    }

    @PostMapping("/dpst_transfer_2")
    public String dpst_transfer_2(Model model,
                                @RequestParam String dpstHdrAcctNo,
                                @ModelAttribute CustTranHistDTO custTranHistDTO,
                                @AuthenticationPrincipal CustomUserDetails userDetails) {


        log.info("CustTranHistDTO:{}", custTranHistDTO.toString());
        if (custTranHistDTO.getDpstDtlAmount()==null){
            custTranHistDTO.setDpstDtlAmount(custTranHistDTO.getTranAmount());
        }

        // 4. 나머지 데이터(메모 등) 처리
        // '내통장표시'가 비어있으면 -> 사용자 이름(보내는 사람) or 조회된 받는분 이름 등 정책에 따라 설정
        if (custTranHistDTO.getTranCustName() == null || custTranHistDTO.getTranCustName().trim().isEmpty()) {
            // 예: 비어있으면 '나에게' 메모에는 '받는 사람 이름'을 기본으로 입력 등
            // 여기서는 기존 로직 유지 (로그인 유저 이름)
            custTranHistDTO.setTranCustName(userDetails.getCustName());
        }
        model.addAttribute("dpstHdrAcctNo", dpstHdrAcctNo);
        DpstAcctHdrDTO dpstAcctDTO = mypageService.getDpstAcctHdr(dpstHdrAcctNo);
        model.addAttribute("dpstAcctDTO", dpstAcctDTO);

        model.addAttribute("custTranHistDTO", custTranHistDTO);

        return "mypage/dpst_transfer_2";
    }


    @PostMapping("/dpst_transfer_3")
    public String dpst_transfer_3(@AuthenticationPrincipal CustomUserDetails userDetails, @ModelAttribute CustTranHistDTO custTranHistDTO, Model model, @RequestParam String dpstHdrAcctNo) {
        // 전자서명 임시 승인 수정해야함
        custTranHistDTO.setTranEsignYn("Y");

        log.info(custTranHistDTO.toString());

        DpstAcctHdrDTO dpstAcctDTO = mypageService.getDpstAcctHdr(dpstHdrAcctNo);
        DpstAcctDtlDTO dpstDtlDTO = new DpstAcctDtlDTO();
        // 계좌 잔액 업데이트
        CustAcctDTO custAcct;
        FrgnAcctBalanceDTO balAcct;

        if ("KRW".equals(custTranHistDTO.getTranCurrency())){
            custAcct  = mypageService.findCustAcct(custTranHistDTO.getTranAcctNo());
            mypageService.addPayKrwToFrgn(custAcct, dpstAcctDTO, custTranHistDTO, dpstDtlDTO);
        }else {
            balAcct = mypageService.getBalAcctByBalNo(custTranHistDTO.getTranAcctNo());
            log.info("balAcct:{}", balAcct.toString());
            mypageService.addPayFrgnToFrgn(balAcct,  dpstAcctDTO, custTranHistDTO, dpstDtlDTO);
        }

        /*
        CustAcctDTO custAcctDTO = new CustAcctDTO();

        if (custTranHistDTO.getTranEsignYn().equals("Y")) {
            // 이체 내역 db에 반영
            mypageService.modifyCustAcctBal(custTranHistDTO);
            model.addAttribute("custTranHistDTO", custTranHistDTO);
            custAcctDTO = mypageService.findCustAcct(custTranHistDTO.getTranAcctNo());
            model.addAttribute("custAcctDTO", custAcctDTO);
            model.addAttribute("state", "정상");
        } else {
            model.addAttribute("custTranHistDTO", custTranHistDTO);
            custAcctDTO = mypageService.findCustAcct(custTranHistDTO.getTranAcctNo());
            model.addAttribute("custAcctDTO", custAcctDTO);
            model.addAttribute("state", "실패");
        }
         */

        model.addAttribute("dpstAcctDTO", dpstAcctDTO);
        model.addAttribute("custTranHistDTO", custTranHistDTO);
        model.addAttribute("state", "정상");

        return "mypage/dpst_transfer_3";
    }


    @GetMapping("/dpst_cancel_1")
    public String dpst_cancel_1(Model model, @RequestParam String dpstHdrAcctNo) {

        DpstAcctHdrDTO dpstAcct = mypageService.getDpstAcctHdr(dpstHdrAcctNo);
        model.addAttribute("dpstAcct", dpstAcct);
        List<DpstAcctDtlDTO> dpstDtlList = mypageService.getDpstDtlHistList(dpstHdrAcctNo);
        BigDecimal totalInterest = mypageService.calculateCompoundInterest(dpstAcct, dpstDtlList);
        model.addAttribute("totalInterest", totalInterest);

        BigDecimal incomeTax = totalInterest.multiply(new BigDecimal("0.14"))
                .setScale(0, RoundingMode.DOWN);
        BigDecimal localTax = incomeTax.multiply(new BigDecimal("0.10"))
                .setScale(0, RoundingMode.DOWN);
        model.addAttribute("incomeTax", incomeTax);         // 이자소득세
        model.addAttribute("localTax", localTax);           // 지방소득세

        return "mypage/dpst_cancel_1";
    }

    @PostMapping("/dpst_cancel_2")
    public String dpst_cancel_1_post(@RequestParam String dpstHdrAcctNo,
                                @ModelAttribute DpstAcctHdrDTO dpstAcct,
                                DpstAcctDtlDTO dpstDtl,
                                     @AuthenticationPrincipal CustomUserDetails userDetails,
                                     Model model) {


        model.addAttribute("dpstAcct", dpstAcct);
        model.addAttribute("dpstDtl", dpstDtl);
        model.addAttribute("dpstHdrAcctNo", dpstHdrAcctNo);

        CustInfoDTO custInfo = mypageService.getRawCustInfo(userDetails.getUsername());
        String aesJumin = AesUtil.decrypt(custInfo.getCustJumin()).substring(0, 6) + "-*******";
        String aesHp = AesUtil.decrypt(custInfo.getCustHp());
        String aesSecHp = aesHp.substring(0, 3) + "-****-" + aesHp.substring(7, 11);
        custInfo.setCustJumin(aesJumin);
        custInfo.setCustHp(aesSecHp);

        model.addAttribute("custInfo", custInfo);


        return "mypage/dpst_cancel_2";
    }

    @GetMapping("/dpst_cancel_2")
    public String dpst_cancel_2(@RequestParam String dpstHdrAcctNo, Model model) {
        return "mypage/dpst_cancel_2";
    }


    @PostMapping("/dpst_cancel_3")
    public String dpst_cancel_3(
            Model model,
            @RequestParam String dpstHdrAcctNo,
            @ModelAttribute DpstAcctHdrDTO dpstAcct,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            DpstAcctDtlDTO dpstDtl
    ) {
        // DTO로 다시 묶을 수도 있음

        model.addAttribute("dpstHdrAcctNo", dpstHdrAcctNo);
        model.addAttribute("dpstAcct", dpstAcct);
        model.addAttribute("dpstDtl", dpstDtl);

        dpstAcct.setDpstHdrStatus(2);
        mypageService.updateHdrStatus(dpstAcct);

        FrgnAcctBalanceDTO balDTO = mypageService.getBalBalanceByAcctHdrNo(dpstHdrAcctNo);
        balDTO.setBalBalance(balDTO.getBalBalance() + dpstDtl.getDpstDtlAmount().doubleValue());
        mypageService.updateBalBalance(balDTO);

        dpstDtl.setDpstDtlType(2);
        dpstDtl.setDpstDtlAppliedRate(BigDecimal.valueOf(0));
        dpstDtl.setDpstDtlEsignYn("y");
        dpstDtl.setDpstDtlEsignDt(LocalDateTime.now());
        depositService.insertDpstDtl(dpstDtl);

        CustTranHistDTO histDTO = new CustTranHistDTO();
        histDTO.setTranAcctNo(dpstHdrAcctNo);
        histDTO.setTranCustName(userDetails.getCustName());
        histDTO.setTranType(1);
        histDTO.setTranAmount(dpstDtl.getDpstDtlAmount());
        histDTO.setTranRecAcctNo(balDTO.getBalNo());
        histDTO.setTranRecName(userDetails.getCustName());
        histDTO.setTranRecBkCode("888");
        histDTO.setTranEsignYn("Y");
        DateTimeFormatter formatter =
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
        histDTO.setTranEsignDt(LocalDateTime.now().format(formatter));
        histDTO.setTranCurrency(dpstDtl.getDpstHdrCurrencyExp());
        depositService.insertCustTranHist(histDTO);

        return "mypage/dpst_cancel_3";
    }

    @GetMapping("/dpst_cancel_3")
    public String dpst_cancel_3() {
        return "mypage/dpst_cancel_3";
    }

}
