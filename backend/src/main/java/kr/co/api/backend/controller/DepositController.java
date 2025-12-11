package kr.co.api.backend.controller;

import jakarta.servlet.http.HttpServletResponse;
import kr.co.api.backend.dto.*;
import kr.co.api.backend.jwt.CustomUserDetails;
import kr.co.api.backend.service.DepositService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/deposit")
public class DepositController {
    private final DepositService depositService;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/deposit_step1")
    public String deposit_step1(Model model, @RequestParam String dpstId) {
        model.addAttribute("dpstId", dpstId);
        model.addAttribute("activeItem","product");

        List<TermsHistDTO> termsList = depositService.getTerms();
        ProductDTO product = depositService.selectDpstProduct(dpstId);
        model.addAttribute("product", product);
        model.addAttribute("termsList",termsList);

        return "deposit/deposit_step1";
    }

    @Value("${file.upload.pdf-terms-path}")
    private String termsUploadPath;

    @GetMapping("/terms/download")
    public void downloadTerms(@RequestParam String thistTermOrder, @RequestParam String thistTermCate, HttpServletResponse response) throws IOException {

        log.info("termUploadPath : " + termsUploadPath);

        String termPath = depositService.getTermContent(thistTermOrder, thistTermCate).getThistFile();
        String fileName = Paths.get(termPath).getFileName().toString();
        String fullPath = termsUploadPath + "/" + fileName;
        log.info("fileName : " + fileName);
        log.info("fullPath : " + fullPath);

        Path path = Paths.get(fullPath);

        if (!Files.exists(path)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "파일을 찾을 수 없습니다.");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader(
                "Content-Disposition",
                "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName
        );
        response.setHeader("Content-Length", String.valueOf(Files.size(path)));

        // 4) 파일을 스트림으로 직접 내려보냄
        try (OutputStream os = response.getOutputStream()) {
            Files.copy(path, os);
            os.flush();
        }

    }

    @Value("${file.upload.pdf-products-path}")
    private String productsUploadPath;

    @GetMapping("/info/download")
    public void downloadDepositInfo(@RequestParam String dpstId, HttpServletResponse response) throws IOException {

        String termPath = depositService.getProduct(dpstId).getDpstInfoPdf();
        String fileName = Paths.get(termPath).getFileName().toString();
        String fullPath = productsUploadPath + "/" + fileName;

        Path path = Paths.get(fullPath);

        if (!Files.exists(path)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "파일을 찾을 수 없습니다.");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader(
                "Content-Disposition",
                "inline; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName
        );
        response.setHeader("Content-Length", String.valueOf(Files.size(path)));
        // 4) 파일을 스트림으로 직접 내려보냄
        try (OutputStream os = response.getOutputStream()) {
            Files.copy(path, os);
            os.flush();
        }
    }

    @GetMapping("/deposit_step2")
    public String deposit_step2(Model model, @RequestParam String dpstId, @AuthenticationPrincipal CustomUserDetails user){
        model.addAttribute("activeItem","product");

        ProductDTO product = depositService.selectDpstProduct(dpstId);
        model.addAttribute("product",product);
        List<CustAcctDTO> accounts = depositService.getAcctList(user.getUsername());
        model.addAttribute("accounts",accounts);
        CustFrgnAcctDTO frgnAccount = depositService.getFrgnAcct(user.getUsername());
        model.addAttribute("frgnAccount",frgnAccount);
        List<FrgnAcctBalanceDTO> frgnAccountBals = depositService.getFrgnAcctBalList(frgnAccount.getFrgnAcctNo());
        model.addAttribute("frgnAccountBals",frgnAccountBals);

        Map<String, Integer> limitMinMap = new HashMap<>();
        Map<String, Integer> limitMaxMap = new HashMap<>();

        if (product.getLimits() != null) {
            limitMinMap = product.getLimits().stream().collect(Collectors.toMap(ProductLimitDTO::getLmtCurrency, ProductLimitDTO::getLmtMinAmt));
            limitMaxMap = product.getLimits().stream().collect(Collectors.toMap(ProductLimitDTO::getLmtCurrency, ProductLimitDTO::getLmtMaxAmt));
            log.info("limitMinMap:{}",limitMinMap);
            log.info("limitMaxMap:{}",limitMaxMap);
        }

        model.addAttribute("limitMinMap",limitMinMap);
        model.addAttribute("limitMaxMap",limitMaxMap);

        return "deposit/deposit_step2";
    }

    @PostMapping("/calc")
    @ResponseBody
    public DepositExchangeDTO calc(@RequestBody Map<String, String> req) {
        System.out.println("⚡ POST /deposit/calc 호출됨!");

        String currency = req.get("currency");
        DepositExchangeDTO exDTO = depositService.exchangeCalc(currency);
        BigDecimal bdAmt = new BigDecimal(req.get("amount"));
        BigDecimal krwAmt = bdAmt.multiply(exDTO.getAppliedRate())
                .setScale(0, RoundingMode.FLOOR);

        exDTO.setKrwAmount(krwAmt);

        return exDTO;
    }

    @GetMapping("/deposit_step3")
    public String deposit_step3(Model model, @RequestParam String dpstId){
        model.addAttribute("activeItem","product");
        return "deposit/deposit_step3";
    }

    @PostMapping("/deposit_step3")
    public String depositStep3(DepositRequestDTO dto, @RequestParam String dpstId, Model model,  @AuthenticationPrincipal CustomUserDetails user) {

        boolean isValidPw = false;
        String pw = "";
        if (dto.getWithdrawType().equals("krw")){
            pw = depositService.getKAcctPw(dto.getAcctNo());
            isValidPw = passwordEncoder.matches(dto.getAcctPw(), pw);
        }else{
            pw = depositService.getFAcctPw(dto.getFrgnAcctNo());
            isValidPw = passwordEncoder.matches(dto.getFrgnAcctPw(), pw);
        }

        if (dto.getAutoRenewYn() == null){
            dto.setAutoRenewYn("n");
        }

        ProductDTO product = depositService.selectDpstProduct(dpstId);
        model.addAttribute("product",product);
        List<CustAcctDTO> accounts = depositService.getAcctList(user.getUsername());
        model.addAttribute("accounts",accounts);
        CustFrgnAcctDTO frgnAccount = depositService.getFrgnAcct(user.getUsername());
        model.addAttribute("frgnAccount",frgnAccount);
        List<FrgnAcctBalanceDTO> frgnAccountBals = depositService.getFrgnAcctBalList(frgnAccount.getFrgnAcctNo());
        model.addAttribute("frgnAccountBals",frgnAccountBals);


        Map<String, Integer> limitMinMap = new HashMap<>();
        Map<String, Integer> limitMaxMap = new HashMap<>();

        if (product.getLimits() != null) {
            limitMinMap = product.getLimits().stream().collect(Collectors.toMap(ProductLimitDTO::getLmtCurrency, ProductLimitDTO::getLmtMinAmt));
            limitMaxMap = product.getLimits().stream().collect(Collectors.toMap(ProductLimitDTO::getLmtCurrency, ProductLimitDTO::getLmtMaxAmt));
        }

        model.addAttribute("limitMinMap",limitMinMap);
        model.addAttribute("limitMaxMap",limitMaxMap);

        if (!isValidPw) {
            model.addAttribute("errorPw", "비밀번호가 일치하지 않습니다.");
            model.addAttribute("activeItem","product");

            return "deposit/deposit_step2";
        }

        LocalDate maturityDate = LocalDate.now().plusMonths(dto.getDpstHdrMonth());
        model.addAttribute("maturityDate",maturityDate); //만기일

        InterestRateDTO interestRateDTO = depositService.getRecentInterest(dto.getDpstHdrCurrency());
        BigDecimal appliedInterest;

        switch (dto.getDpstHdrMonth()) {
            case 1:
                appliedInterest = interestRateDTO.getRate1M();
                break;
            case 2:
                appliedInterest = interestRateDTO.getRate2M();
                break;
            case 3:
                appliedInterest = interestRateDTO.getRate3M();
                break;
            case 4:
                appliedInterest = interestRateDTO.getRate4M();
                break;
            case 5:
                appliedInterest = interestRateDTO.getRate5M();
                break;
            case 6:
                appliedInterest = interestRateDTO.getRate6M();
                break;
            case 7:
                appliedInterest = interestRateDTO.getRate7M();
                break;
            case 8:
                appliedInterest = interestRateDTO.getRate8M();
                break;
            case 9:
                appliedInterest = interestRateDTO.getRate9M();
                break;
            case 10:
                appliedInterest = interestRateDTO.getRate10M();
                break;
            case 11:
                appliedInterest = interestRateDTO.getRate11M();
                break;
            default:
                appliedInterest = interestRateDTO.getRate12M();
                break;
        }
        model.addAttribute("appliedInterest",appliedInterest);


        model.addAttribute("dto", dto);
        model.addAttribute("dpstId", dpstId);



        return "deposit/deposit_step3";
    }

    @GetMapping("/deposit_step4")
    public String deposit_step4(Model model, @RequestParam String dpstId){
        model.addAttribute("activeItem","product");
        return "deposit/deposit_step4";
    }

    @PostMapping("/deposit_step4")
    public String depositStep4(DepositRequestDTO dto, @RequestParam String dpstId, Model model,  @AuthenticationPrincipal CustomUserDetails user) {

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

        // 1. 화면 렌더링을 위한 기본 데이터 조회 및 설정
        ProductDTO product = depositService.selectDpstProduct(dpstId);
        model.addAttribute("product", product);

        List<CustAcctDTO> accounts = depositService.getAcctList(user.getUsername());
        model.addAttribute("accounts", accounts);

        CustFrgnAcctDTO frgnAccount = depositService.getFrgnAcct(user.getUsername());
        model.addAttribute("frgnAccount", frgnAccount);

        List<FrgnAcctBalanceDTO> frgnAccountBals = depositService.getFrgnAcctBalList(frgnAccount.getFrgnAcctNo());
        model.addAttribute("frgnAccountBals", frgnAccountBals);

        model.addAttribute("custName", user.getCustName());
        model.addAttribute("dto", dto);
        model.addAttribute("dpstId", dpstId);


        // 2. DpstAcctHdrDTO 생성 및 공통 필드 설정
        DpstAcctHdrDTO dpstAcctHdrDTO = new DpstAcctHdrDTO();

        dpstAcctHdrDTO.setDpstHdrDpstId(dpstId);
        dpstAcctHdrDTO.setDpstHdrPw(passwordEncoder.encode(dto.getDpstPw()));
        dpstAcctHdrDTO.setDpstHdrCustCode(user.getUsername());
        dpstAcctHdrDTO.setDpstHdrMonth(dto.getDpstHdrMonth());



        // 통화 및 금리 설정
        dpstAcctHdrDTO.setDpstHdrCurrency(dto.getDpstHdrCurrency());
        dpstAcctHdrDTO.setDpstHdrInterest(dto.getAppliedInterest());

        // [중요] 부분 인출 횟수 초기화 (Null 에러 방지)
        dpstAcctHdrDTO.setDpstHdrPartWdrwCnt(0);

        // 잔액 설정 (기본 로직)
        if (product.getDpstType() == 1) {
            dpstAcctHdrDTO.setDpstHdrBalance(dto.getDpstAmount());
        } else {
            dpstAcctHdrDTO.setDpstHdrBalance(BigDecimal.valueOf(0));
        }

        // 적용 금리 설정
        if (product.getDpstType() == 1 && product.getDpstRateType() == 1) {
            dpstAcctHdrDTO.setDpstHdrRate(dto.getAppliedRate());
        } else {
            dpstAcctHdrDTO.setDpstHdrRate(BigDecimal.valueOf(0));
        }

        // 출금 통화 설정
        if (product.getDpstType() == 1) {
            dpstAcctHdrDTO.setDpstHdrCurrencyExp(dto.getDpstHdrCurrency());
        } else {
            dpstAcctHdrDTO.setDpstHdrCurrencyExp("KRW");
        }

        // [중요] 연결 계좌 및 출금 계좌 설정 (Null 방지 처리)
        String linkedAcctNo = "krw".equals(dto.getWithdrawType()) ? dto.getAcctNo() : dto.getBalNo();
        dpstAcctHdrDTO.setDpstHdrLinkedAcctNo(linkedAcctNo != null ? linkedAcctNo : "");

        String expAcctNo = "krw".equals(dto.getWithdrawType()) ? dto.getAcctNo() : dto.getFrgnAcctNo();
        dpstAcctHdrDTO.setDpstHdrExpAcctNo(expAcctNo != null ? expAcctNo : "");

        // 자동연장 설정
        dpstAcctHdrDTO.setDpstHdrAutoRenewYn("y".equals(dto.getAutoRenewYn()) ? "y" : "n");
        if ("y".equals(dto.getAutoRenewYn())) {
            dpstAcctHdrDTO.setDpstHdrAutoRenewTerm(dto.getAutoRenewTerm());
            dpstAcctHdrDTO.setDpstHdrAutoRenewCnt(0);
        }

        // 연결 계좌 타입 설정
        if ("krw".equals(dto.getWithdrawType()) || product.getDpstRateType() == 2) {
            dpstAcctHdrDTO.setDpstHdrLinkedAcctType(1);
        } else {
            dpstAcctHdrDTO.setDpstHdrLinkedAcctType(2);
        }

        // 기타 약관 동의 정보
        dpstAcctHdrDTO.setDpstHdrInfoAgreeYn("y");
        dpstAcctHdrDTO.setDpstHdrInfoAgreeDt(LocalDateTime.now());


        // 3. 상품 타입에 따른 분기 처리 (이벤트 vs 일반)
        boolean isEventProduct = "FXD079".equals(dpstId);
        DpstAcctHdrDTO insertDTO;

        if (isEventProduct) {
            // === [CASE 1] 이벤트 상품 (사전 신청) ===

            // 날짜 설정
            dpstAcctHdrDTO.setDpstHdrStartDy(LocalDate.now().format(formatter));
            dpstAcctHdrDTO.setDpstHdrFinDy(LocalDate.now().plusMonths(dto.getDpstHdrMonth()).format(formatter));

            // 상태값 0 (사전신청/대기) 설정
            dpstAcctHdrDTO.setDpstHdrStatus(0);

            // 잔액 정보는 유지하되, 실제 입출금 트랜잭션이 없는 서비스 호출
            // (openDepositFreeAcctTransaction은 오직 Header INSERT만 수행함)
            insertDTO = depositService.openDepositFreeAcctTransaction(dpstAcctHdrDTO);

        } else {
            // === [CASE 2] 일반 상품 (정상 가입) ===
            // 날짜 설정
            dpstAcctHdrDTO.setDpstHdrStartDy(LocalDate.now().format(formatter));
            dpstAcctHdrDTO.setDpstHdrFinDy(LocalDate.now().plusMonths(dto.getDpstHdrMonth()).format(formatter));

            // 상태값 1 (정상) 설정
            dpstAcctHdrDTO.setDpstHdrStatus(1);

            // 거래내역 DTO 준비 (입금이 수반되는 경우)
            DpstAcctDtlDTO dtlDTO = new DpstAcctDtlDTO();
            CustTranHistDTO custTranHistDTO = new CustTranHistDTO();

            if (product.getDpstType() == 1) {
                // 예금 상세(Detail) 내역 설정
                dtlDTO.setDpstDtlType(1);
                if (product.getDpstRateType() == 1) {
                    dtlDTO.setDpstDtlAmount(dto.getDpstAmount());
                } else {
                    dtlDTO.setDpstDtlAmount(dto.getKrwAmount());
                }
                dtlDTO.setDpstDtlEsignYn("y");
                dtlDTO.setDpstDtlEsignDt(LocalDateTime.now());
                dtlDTO.setDpstDtlAppliedRate(dto.getAppliedRate());

                // 고객 거래내역(History) 설정
                custTranHistDTO.setTranCustName(user.getCustName());
                custTranHistDTO.setTranType(2);
                if ("krw".equals(dto.getWithdrawType())) {
                    custTranHistDTO.setTranAmount(dto.getKrwAmount());
                    custTranHistDTO.setTranCurrency("KRW");
                } else {
                    custTranHistDTO.setTranAmount(dto.getDpstAmount());
                    custTranHistDTO.setTranCurrency(dpstAcctHdrDTO.getDpstHdrCurrency());
                }
                custTranHistDTO.setTranRecName(user.getCustName());
                custTranHistDTO.setTranRecBkCode("888");
                custTranHistDTO.setTranEsignYn("Y");

                DateTimeFormatter dt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
                custTranHistDTO.setTranEsignDt(LocalDateTime.now().format(dt));
            }

            // 실제 트랜잭션 수행 (돈이 빠져나감)
            if (product.getDpstType() == 1) {
                insertDTO = depositService.openDepositAcctTransaction(dpstAcctHdrDTO, dtlDTO, custTranHistDTO, dto.getWithdrawType());
            } else {
                insertDTO = depositService.openDepositFreeAcctTransaction(dpstAcctHdrDTO);
            }
        }

        model.addAttribute("insertDTO", insertDTO);

        return "deposit/deposit_step4";
    }


    @GetMapping("/info")
    public String info(Model model){
        model.addAttribute("activeItem","info");
        return "deposit/info";
    }

    @GetMapping("/list")
    public String list(Model model){
        model.addAttribute("activeItem", "product");

        List<ProductDTO> list = depositService.getActiveProducts();
        int count = depositService.getActiveProductCount();
        model.addAttribute("activeItem", "product");

        model.addAttribute("list", list);
        model.addAttribute("count", count);

        return "deposit/list";
    }

    @GetMapping("/view")
    public String view(@RequestParam("dpstId") String dpstId, Model model) {
        ProductDTO product = depositService.getProduct(dpstId);

        String termsFilePath = depositService.getTermsFileByTitle(product.getDpstName());

        LocalDate delibDate = LocalDate.parse(product.getDpstDelibDy(), DateTimeFormatter.ofPattern("yyyyMMdd"));
        LocalDate startDate = LocalDate.parse(product.getDpstDelibStartDy(), DateTimeFormatter.ofPattern("yyyyMMdd"));
        model.addAttribute("product", product);
        model.addAttribute("activeItem", "product");
        model.addAttribute("delibDate", delibDate);
        model.addAttribute("startDate", startDate);
        model.addAttribute("termsFilePath", termsFilePath);

        return "deposit/view";
    }

    @GetMapping("/rates")
    @ResponseBody
    public List<DepositRateDTO> getExchangeRates(
            @RequestParam("baseDate") @DateTimeFormat(pattern = "yyyy-MM-dd") Date baseDate) {

        List<DepositRateDTO> rates = depositService.getRatesByBaseDate(baseDate);

        return rates;
    }

}
