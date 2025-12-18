package kr.co.api.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import kr.co.api.backend.dto.*;
import kr.co.api.backend.mapper.DepositMapper;
import kr.co.api.backend.mapper.MemberMapper;
import kr.co.api.backend.jwt.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/mobile/deposit")
@RequiredArgsConstructor
public class MobileDepositController {

    private final DepositMapper depositMapper;
    private final MemberMapper memberMapper;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/context")
    public ResponseEntity<Map<String, Object>> getDepositContext(HttpServletRequest request) {
        CustInfoDTO user = resolveUser(request);

        List<CustAcctDTO> krwAccounts = Optional.ofNullable(
                depositMapper.getKRWAccts(user.getCustCode())
        ).orElse(Collections.emptyList());

        CustFrgnAcctDTO fxAccount = depositMapper.getFrgnAcct(user.getCustCode());
        List<Map<String, Object>> fxAccounts = new ArrayList<>();

        if (fxAccount != null) {
            List<FrgnAcctBalanceDTO> balances = Optional.ofNullable(
                    depositMapper.getFrgnAcctBalList(fxAccount.getFrgnAcctNo())
            ).orElse(Collections.emptyList());

            fxAccounts.add(Map.of(
                    "acctNo", fxAccount.getFrgnAcctNo(),
                    "balances", balances.stream()
                            .map(b -> Map.of(
                                    "balNo", b.getBalNo(),
                                    "currency", b.getBalCurrency(),
                                    "balance", b.getBalBalance()
                            ))
                            .toList()
            ));
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("customerName", user.getCustName());
        payload.put("custCode", user.getCustCode());
        payload.put("krwAccounts", krwAccounts.stream()
                .map(a -> Map.of(
                        "acctNo", a.getAcctNo(),
                        "balance", a.getAcctBalance()
                ))
                .toList());
        payload.put("fxAccounts", fxAccounts);

        return ResponseEntity.ok(payload);
    }

    @PostMapping("/applications")
    @Transactional
    public ResponseEntity<Map<String, Object>> applyDeposit(
            @RequestBody Map<String, Object> request,
            HttpServletRequest servletRequest
    ) {
        CustInfoDTO user = resolveUser(servletRequest);

        String dpstId = asString(request.get("dpstId"));
        if (dpstId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "상품 정보가 없습니다.");
        }

        ProductDTO product = depositMapper.findProductById(dpstId);
        if (product == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 상품입니다.");
        }

        String withdrawType = asString(request.get("withdrawType"), "krw");
        String withdrawAccount = "fx".equalsIgnoreCase(withdrawType)
                ? asString(request.get("selectedFxAccount"))
                : asString(request.get("selectedKrwAccount"));

        String withdrawPassword = asString(request.get("withdrawPassword"));
        String fxWithdrawCurrency = asString(request.get("fxWithdrawCurrency"), "");
        String newCurrency = asString(request.get("newCurrency"));
        Integer periodMonths = parseInt(request.get("newPeriodMonths"));
        BigDecimal amount = parseBigDecimal(request.get("newAmount"));

        if (withdrawAccount.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "출금 계좌를 선택해주세요.");
        }
        if (withdrawPassword.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "출금계좌 비밀번호가 필요합니다.");
        }
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "가입 금액을 다시 확인해주세요.");
        }

        String effectiveWithdrawCurrency = "fx".equalsIgnoreCase(withdrawType)
                ? (!fxWithdrawCurrency.isBlank() ? fxWithdrawCurrency : newCurrency)
                : "KRW";

        if ("krw".equalsIgnoreCase(withdrawType)) {
            validateAndWithdrawKrw(user.getCustCode(), withdrawAccount, withdrawPassword, amount);
        } else {
            validateAndWithdrawFx(user.getCustCode(), withdrawAccount, withdrawPassword, effectiveWithdrawCurrency, amount);
        }

        BigDecimal appliedRate = resolveRate(
                depositMapper.getRecentInterest(newCurrency),
                periodMonths
        );

        LocalDate startDate = LocalDate.now();
        LocalDate endDate = (periodMonths != null)
                ? startDate.plusMonths(periodMonths)
                : startDate.plusMonths(1);

        DpstAcctHdrDTO header = new DpstAcctHdrDTO();
        header.setDpstHdrDpstId(dpstId);
        header.setDpstHdrPw(passwordEncoder.encode(asString(request.get("depositPassword"))));
        header.setDpstHdrCustCode(user.getCustCode());
        header.setDpstHdrMonth(periodMonths != null ? periodMonths : 1);
        header.setDpstHdrStartDy(startDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        header.setDpstHdrFinDy(endDate.format(DateTimeFormatter.BASIC_ISO_DATE));
        header.setDpstHdrCurrency(newCurrency);
        header.setDpstHdrCurrencyExp(newCurrency);
        header.setDpstHdrBalance(amount);
        header.setDpstHdrInterest(BigDecimal.ZERO);
        header.setDpstHdrStatus(1);
        header.setDpstHdrLinkedAcctNo(withdrawAccount);
        header.setDpstHdrLinkedAcctType("fx".equalsIgnoreCase(withdrawType) ? 2 : 1);
        header.setDpstHdrAutoRenewYn("apply".equalsIgnoreCase(asString(request.get("autoRenew"))) ? "Y" : "N");
        header.setDpstHdrAutoRenewCnt(0);
        header.setDpstHdrAutoRenewTerm(parseInt(request.get("autoRenewCycle")));
        header.setDpstHdrPartWdrwCnt(0);
        header.setDpstHdrInfoAgreeYn("Y");
        header.setDpstHdrInfoAgreeDt(LocalDateTime.now());
        header.setDpstHdrRate(appliedRate);
        header.setDpstHdrExpAcctNo(withdrawAccount);
        header.setDpstHdrLinkedAcctBal(amount);

        depositMapper.insertDpstAcctHdr(header);
        DpstAcctHdrDTO inserted = depositMapper.selectInsertedAcct(user.getCustCode(), dpstId);

        boolean hasSignature = request.get("signature") != null;

        DpstAcctDtlDTO detail = new DpstAcctDtlDTO();
        detail.setDpstDtlType(1);
        detail.setDpstDtlAppliedRate(appliedRate);
        detail.setDpstDtlAmount(amount);
        detail.setDpstDtlHdrNo(inserted.getDpstHdrAcctNo());
        detail.setDpstDtlEsignYn(hasSignature ? "Y" : "N");
        detail.setDpstDtlEsignDt(hasSignature ? LocalDateTime.now() : null);
        depositMapper.insertDpstAcctDtl(detail);

        CustTranHistDTO history = new CustTranHistDTO();
        history.setTranAcctNo(withdrawAccount);
        history.setTranCustName(user.getCustName());
        history.setTranType(1);
        history.setTranAmount(amount);
        history.setTranRecAcctNo(inserted.getDpstHdrAcctNo());
        history.setTranRecName(product.getDpstName());
        history.setTranRecBkCode("BNK");
        history.setTranEsignYn(detail.getDpstDtlEsignYn());
        history.setTranEsignDt(detail.getDpstDtlEsignDt() != null
                ? detail.getDpstDtlEsignDt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS"))
                : null);
        history.setTranCurrency(effectiveWithdrawCurrency);
        depositMapper.insertCustTranHist(history);

        Map<String, Object> response = new HashMap<>();
        response.put("dpstId", dpstId);
        response.put("customerName", user.getCustName());
        response.put("productName", product.getDpstName());
        response.put("newAccountNo", inserted.getDpstHdrAcctNo());
        response.put("currency", newCurrency);
        response.put("amount", formatAmount(amount, newCurrency));
        response.put("withdrawalAccount", withdrawAccount);
        response.put("withdrawCurrency", effectiveWithdrawCurrency);
        response.put("withdrawAmount", formatAmount(amount, effectiveWithdrawCurrency));
        response.put("rate", appliedRate != null ? appliedRate + "%" : null);
        response.put("maturityDate", inserted.getDpstHdrFinDy());
        response.put("periodLabel", periodMonths != null ? periodMonths + "개월" : "-");
        response.put("contractDateTime", LocalDateTime.now().toString());

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    private void validateAndWithdrawKrw(String custCode, String acctNo, String password, BigDecimal amount) {
        List<CustAcctDTO> accounts = Optional.ofNullable(
                depositMapper.getKRWAccts(custCode)
        ).orElse(Collections.emptyList());

        CustAcctDTO account = accounts.stream()
                .filter(a -> acctNo.equals(a.getAcctNo()))
                .findFirst()
                .orElseThrow(() ->
                        new ResponseStatusException(HttpStatus.BAD_REQUEST, "출금 계좌를 확인해주세요.")
                );

        if (!matchesAccountPassword(password, account.getAcctPw())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "출금계좌 비밀번호가 일치하지 않습니다.");
        }

        BigDecimal balance = BigDecimal.valueOf(account.getAcctBalance());
        if (balance.compareTo(amount) < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "출금가능금액을 초과했습니다.");
        }

        account.setAcctBalance(balance.subtract(amount).intValue());
        depositMapper.updateAcctBalance(account);
    }

    private void validateAndWithdrawFx(String custCode, String acctNo, String password, String currency, BigDecimal amount) {
        CustFrgnAcctDTO account = depositMapper.getFrgnAcct(custCode);
        if (account == null || !acctNo.equals(account.getFrgnAcctNo())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "외화 출금계좌를 확인해주세요.");
        }

        if (!matchesAccountPassword(password, account.getFrgnAcctPw())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "외화계좌 비밀번호가 일치하지 않습니다.");
        }

        List<FrgnAcctBalanceDTO> balances = Optional.ofNullable(
                depositMapper.getFrgnAcctBalList(account.getFrgnAcctNo())
        ).orElse(Collections.emptyList());

        FrgnAcctBalanceDTO balance = balances.stream()
                .filter(b -> currency.equalsIgnoreCase(b.getBalCurrency()))
                .findFirst()
                .orElseThrow(() ->
                        new ResponseStatusException(HttpStatus.BAD_REQUEST, "해당 통화의 잔액이 없습니다.")
                );

        BigDecimal current = BigDecimal.valueOf(balance.getBalBalance());
        if (current.compareTo(amount) < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "출금가능금액을 초과했습니다.");
        }

        balance.setBalBalance(current.subtract(amount).doubleValue());
        depositMapper.updateBalBalance(balance);
    }

    private boolean matchesAccountPassword(String inputPw, String storedPw) {
        if (inputPw == null || storedPw == null) {
            return false;
        }
        if (storedPw.startsWith("$2a$") || storedPw.startsWith("$2b$")) {
            return passwordEncoder.matches(inputPw, storedPw);
        }
        return inputPw.equals(storedPw);
    }

    private CustInfoDTO resolveUser(HttpServletRequest request) {
        String token = resolveToken(request);
        if (token == null || !jwtTokenProvider.validateToken(token)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증 정보가 올바르지 않습니다.");
        }

        Authentication authentication = jwtTokenProvider.getAuthentication(token);
        String custCode = authentication.getName();
        CustInfoDTO user = memberMapper.findByCodeCustInfo(custCode);

        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "사용자 정보를 찾을 수 없습니다.");
        }
        return user;
    }

    private String resolveToken(HttpServletRequest request) {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return jwtTokenProvider.resolveToken(request);
    }

    private BigDecimal resolveRate(InterestRateDTO rateInfo, Integer months) {
        if (rateInfo == null || months == null) {
            return null;
        }
        return switch (months) {
            case 1 -> rateInfo.getRate1M();
            case 2 -> rateInfo.getRate2M();
            case 3 -> rateInfo.getRate3M();
            case 4 -> rateInfo.getRate4M();
            case 5 -> rateInfo.getRate5M();
            case 6 -> rateInfo.getRate6M();
            case 7 -> rateInfo.getRate7M();
            case 8 -> rateInfo.getRate8M();
            case 9 -> rateInfo.getRate9M();
            case 10 -> rateInfo.getRate10M();
            case 11 -> rateInfo.getRate11M();
            case 12 -> rateInfo.getRate12M();
            default -> rateInfo.getRate12M();
        };
    }

    private String formatAmount(BigDecimal amount, String currency) {
        if (amount == null) {
            return "-";
        }
        NumberFormat formatter = NumberFormat.getNumberInstance(Locale.KOREA);
        return currency.isBlank()
                ? formatter.format(amount)
                : currency + " " + formatter.format(amount);
    }

    private String asString(Object value) {
        return asString(value, "");
    }

    private String asString(Object value, String defaultValue) {
        return value == null ? defaultValue : value.toString();
    }

    private Integer parseInt(Object value) {
        if (value == null) return null;
        try {
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(Object value) {
        if (value == null) return BigDecimal.ZERO;
        try {
            return new BigDecimal(value.toString());
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }
}
