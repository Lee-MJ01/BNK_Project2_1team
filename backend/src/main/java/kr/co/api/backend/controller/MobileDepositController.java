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

import kr.co.api.backend.service.RateQueryService;
import java.math.RoundingMode;

@Slf4j
@RestController
@RequestMapping("/api/mobile/deposit")
@RequiredArgsConstructor
public class MobileDepositController {

    private final DepositMapper depositMapper;
    private final MemberMapper memberMapper;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;
    private final RateQueryService rateQueryService;

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

    @GetMapping("/drafts/{dpstId}")
    public ResponseEntity<Map<String, Object>> getDepositDraft(
            @PathVariable String dpstId,
            HttpServletRequest request
    ) {
        CustInfoDTO user = resolveUser(request);

        log.info(
                "[DepositDraft] Incoming draft fetch | dpstId={}, custCode={}",
                dpstId,
                user.getCustCode()
        );

        log.info("[DepositDraft] Fetching draft | dpstId={}, custCode={}", dpstId, user.getCustCode());

        DpstAcctDraftDTO draft = depositMapper.findDepositDraft(dpstId, user.getCustCode());

        if (draft == null) {
            log.warn("[DepositDraft] Draft not found | dpstId={}, custCode={}", dpstId, user.getCustCode());

            return ResponseEntity.notFound().build();
        }

        logDraftState("[DepositDraft] Loaded draft", draft);
        return ResponseEntity.ok(toDraftPayload(draft));
    }



    @GetMapping("/products/{dpstId}/rate")
    public ResponseEntity<Map<String, Object>> getDepositRate(
            @PathVariable String dpstId,
            @RequestParam(required = false) String currency,
            @RequestParam(required = false) Integer month,
            HttpServletRequest request
    ) {
        resolveUser(request); // 인증만 확인

        ProductDTO product = depositMapper.findProductById(dpstId);
        if (product == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        String targetCurrency = asString(currency, product.getDpstCurrency());
        Integer targetMonth = month != null ? month : product.getPeriodMinMonth();
        if (targetMonth == null) {
            targetMonth = 12;
        }

        InterestRateDTO rateInfo = depositMapper.getRecentInterest(targetCurrency);
        BigDecimal rate = resolveRate(rateInfo, targetMonth);
        if (rate == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("dpstId", dpstId);
        payload.put("currency", targetCurrency);
        payload.put("month", targetMonth);
        payload.put("rate", rate);

        return ResponseEntity.ok(payload);
    }

    @PutMapping("/drafts/{dpstId}")
    @Transactional
    public ResponseEntity<Map<String, Object>> saveDepositDraft(
            @PathVariable String dpstId,
            @RequestBody Map<String, Object> request,
            HttpServletRequest servletRequest
    ) {
        try {
            log.info("==== [DepositDraft] PUT /drafts 호출됨 ====");
            log.info("RAW REQUEST BODY = {}", request);

            CustInfoDTO user = resolveUser(servletRequest);

            DpstAcctDraftDTO draft = Optional.ofNullable(
                    depositMapper.findDepositDraft(dpstId, user.getCustCode())
            ).orElseGet(DpstAcctDraftDTO::new);

            Integer requestedStep = parseInt(request.get("step"));

            log.info(
                    "[DepositDraft] Received save request | dpstId={}, custCode={}, payload={}",
                    dpstId,
                    user.getCustCode(),
                    sanitizeDraftRequest(request)
            );

            log.info(
                    "[DepositDraft] Saving draft | dpstId={}, custCode={}, incomingStep={}, existingDraftNo={}",
                    dpstId,
                    user.getCustCode(),
                    requestedStep,
                    draft.getDpstDraftNo()
            );

            Integer requestedMonth = parseInt(request.get("month"));
            Integer requestedAutoRenewTerm = parseInt(request.get("autoRenewTerm"));
            BigDecimal requestedAmount = parseNullableBigDecimal(request.get("amount"));

            Integer persistedStep = coalesceInt(requestedStep, draft.getDpstDraftStep(), 0);
            Integer persistedMonth = coalesceInt(requestedMonth, draft.getDpstDraftMonth(), 0);
            Integer persistedAutoRenewTerm = coalesceInt(requestedAutoRenewTerm, draft.getDpstDraftAutoRenewTerm(), 0);
            BigDecimal persistedAmount = coalesceAmount(requestedAmount, draft.getDpstDraftAmount());

            draft.setDpstDraftDpstId(dpstId);
            draft.setDpstDraftCustCode(user.getCustCode());
            draft.setDpstDraftPw(coalesceString(asString(request.get("depositPassword")), draft.getDpstDraftPw()));
            draft.setDpstDraftMonth(persistedMonth);
            draft.setDpstDraftStep(persistedStep);
            draft.setDpstDraftCurrency(coalesceString(asString(request.get("currency")), draft.getDpstDraftCurrency()));
            draft.setDpstDraftLinkedAcctNo(coalesceString(asString(request.get("linkedAccountNo")), draft.getDpstDraftLinkedAcctNo()));
            draft.setDpstDraftAutoRenewYn(coalesceFlag(asBooleanFlag(request.get("autoRenewYn")), draft.getDpstDraftAutoRenewYn()));
            draft.setDpstDraftAutoRenewTerm(persistedAutoRenewTerm);
            draft.setDpstDraftAutoTermiYn(coalesceFlag(asBooleanFlag(request.get("autoTerminationYn")), draft.getDpstDraftAutoTermiYn()));
            draft.setDpstDraftWdrwPw(coalesceString(asString(request.get("withdrawPassword")), draft.getDpstDraftWdrwPw()));
            draft.setDpstDraftAmount(persistedAmount);

            logDraftState("[DepositDraft] Prepared draft for persistence", draft);

            if (draft.getDpstDraftNo() == null) {
                int inserted = depositMapper.insertDepositDraft(draft);
                log.info("[DepositDraft] Insert attempt | insertedRows={}", inserted);
            } else {
                int updated = depositMapper.updateDepositDraft(draft);
                log.info("[DepositDraft] Update attempt | updatedRows={}", updated);
            }

            DpstAcctDraftDTO saved = depositMapper.findDepositDraft(dpstId, user.getCustCode());
            logDraftState("[DepositDraft] Persisted draft", saved);

            return ResponseEntity.status(HttpStatus.CREATED).body(toDraftPayload(saved));

        } catch (Exception e) {
            log.error("[DepositDraft] ERROR OCCURRED", e);
            throw e;
        }
    }



    /**
     * 전자서명 완료 후 이어가기 임시 저장본을 완전히 제거한다.
     * <p>
     * 프런트엔드에서 가입 완료 시점에 이 엔드포인트를 호출하며,
     * 고객 코드까지 함께 체크해서 다른 사용자의 초안이 지워지지 않도록 방지한다.
     */
    @DeleteMapping("/drafts/{dpstId}")
    @Transactional
    public ResponseEntity<Void> deleteDepositDraft(
            @PathVariable String dpstId,
            HttpServletRequest servletRequest
    ) {
        CustInfoDTO user = resolveUser(servletRequest);
        log.info("[DepositDraft] Deleting draft | dpstId={}, custCode={}", dpstId, user.getCustCode());
        int deleted = depositMapper.deleteDepositDraft(dpstId, user.getCustCode());
        log.info(
                "[DepositDraft] Delete result | dpstId={}, custCode={}, deletedRows={}",
                dpstId,
                user.getCustCode(),
                deleted
        );
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/applications")
    @Transactional
    public ResponseEntity<Map<String, Object>> applyDeposit(
            @RequestBody Map<String, Object> request,
            HttpServletRequest servletRequest
    ) {
        CustInfoDTO user = resolveUser(servletRequest);
        log.info(
                "[APPLY] request sanitized | custCode={}, payload={}",
                user.getCustCode(),
                sanitizeApplyRequest(request)
        );

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
        BigDecimal withdrawAmount = amount;

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
            if (!"KRW".equalsIgnoreCase(newCurrency)) {
                withdrawAmount = convertToKrw(newCurrency, amount);
            }
            validateAndWithdrawKrw(user.getCustCode(), withdrawAccount, withdrawPassword, withdrawAmount);
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
        Integer autoRenewTerm = parseInt(request.get("autoRenewCycle"));
        header.setDpstHdrAutoRenewTerm(
                autoRenewTerm != null ? autoRenewTerm : 0
        );


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
        header.setDpstHdrLinkedAcctBal(withdrawAmount);

        log.info("[APPLY] header insert data={}", header);
        depositMapper.insertDpstAcctHdr(header);
        log.info("[APPLY] header insert success");
        DpstAcctHdrDTO inserted = depositMapper.selectInsertedAcct(user.getCustCode(), dpstId);
        log.info("[APPLY] inserted acct={}", inserted);


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
        history.setTranAmount("krw".equalsIgnoreCase(withdrawType)
                ? withdrawAmount
                : amount);

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
        response.put("withdrawAmount", formatAmount(
                "krw".equalsIgnoreCase(withdrawType) ? withdrawAmount : amount,
                effectiveWithdrawCurrency
        ));
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

        account.setAcctBalance((long) balance.subtract(amount).intValue());
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

        balance.setBalBalance((long) current.subtract(amount).doubleValue());
        depositMapper.updateBalBalance(balance);
    }

    private Map<String, Object> toDraftPayload(DpstAcctDraftDTO draft) {
        Map<String, Object> payload = new HashMap<>();
        if (draft == null) {
            return payload;
        }

        payload.put("draftNo", draft.getDpstDraftNo());
        payload.put("dpstId", draft.getDpstDraftDpstId());
        payload.put("customerCode", draft.getDpstDraftCustCode());
        payload.put("currency", nullIfBlank(draft.getDpstDraftCurrency()));
        payload.put("month", nullIfZero(draft.getDpstDraftMonth()));
        payload.put("step", nullIfZero(draft.getDpstDraftStep()));
        payload.put("linkedAccountNo", nullIfBlank(draft.getDpstDraftLinkedAcctNo()));
        payload.put("autoRenewYn", coalesceFlag(draft.getDpstDraftAutoRenewYn(), "N"));
        payload.put("autoRenewTerm", nullIfZero(draft.getDpstDraftAutoRenewTerm()));
        payload.put("autoTerminationYn", coalesceFlag(draft.getDpstDraftAutoTermiYn(), "N"));
        payload.put("withdrawPassword", nullIfBlank(draft.getDpstDraftWdrwPw()));
        payload.put("depositPassword", nullIfBlank(draft.getDpstDraftPw()));
        payload.put("amount", nullIfZero(draft.getDpstDraftAmount()));
        payload.put("updatedAt", draft.getDpstDraftUpdatedDt() != null
                ? draft.getDpstDraftUpdatedDt().toString()
                : null);

        return payload;
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



    /**
     * TB_EXCH_RATE_HIST 에 적재된 최신 매매기준율(rhist_base_rate)을 사용해
     * 예금 가입 금액을 원화 출금액으로 환산한다.
     * - 가장 최근 고시일 데이터를 조회하여 적용하며,
     * - 환율 데이터가 없을 경우 고객에게 재시도를 요청하는 오류를 반환한다.
     */
    private BigDecimal convertToKrw(String currency, BigDecimal amount) {
        RateDTO rate = rateQueryService.getLatestRateForCurrency(currency);
        if (rate == null || rate.getRhistBaseRate() == null) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "환율 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요."
            );
        }

        BigDecimal baseRate = BigDecimal.valueOf(rate.getRhistBaseRate());
        return amount.multiply(baseRate).setScale(0, RoundingMode.HALF_UP);
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

    private BigDecimal parseNullableBigDecimal(Object value) {
        if (value == null) return null;
        try {
            return new BigDecimal(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String asBooleanFlag(Object value) {
        if (value == null) return "N";
        String normalized = value.toString().trim();
        return ("Y".equalsIgnoreCase(normalized) || "TRUE".equalsIgnoreCase(normalized) || "1".equals(normalized))
                ? "Y"
                : "N";
    }

    private String coalesceString(String incoming, String existing) {
        if (incoming != null && !incoming.isBlank()) {
            return incoming;
        }
        return existing != null ? existing : "";
    }

    private String coalesceFlag(String incoming, String existing) {
        if (incoming != null && !incoming.isBlank()) {
            return incoming;
        }
        return existing != null && !existing.isBlank() ? existing : "N";
    }

    private Integer coalesceInt(Integer incoming, Integer existing, int defaultValue) {
        if (incoming != null) {
            return incoming;
        }
        if (existing != null) {
            return existing;
        }
        return defaultValue;
    }

    private BigDecimal coalesceAmount(BigDecimal incoming, BigDecimal existing) {
        if (incoming != null) {
            return incoming;
        }
        if (existing != null) {
            return existing;
        }
        return BigDecimal.ZERO;
    }

    private Integer nullIfZero(Integer value) {
        if (value == null) return null;
        return value == 0 ? null : value;
    }

    private BigDecimal nullIfZero(BigDecimal value) {
        if (value == null) return null;
        return value.compareTo(BigDecimal.ZERO) == 0 ? null : value;
    }

    private String nullIfBlank(String value) {
        return (value == null || value.isBlank()) ? null : value;
    }

    private void logDraftState(String label, DpstAcctDraftDTO draft) {
        if (draft == null) {
            log.warn("{} | draft is null", label);
            return;
        }

        log.info(
                "{} | draftNo={}, dpstId={}, custCode={}, month={}, step={}, currency={}, linkedAcct={}, autoRenewYn={}, autoRenewTerm={}, autoTermiYn={}, amount={}",
                label,
                draft.getDpstDraftNo(),
                draft.getDpstDraftDpstId(),
                draft.getDpstDraftCustCode(),
                draft.getDpstDraftMonth(),
                draft.getDpstDraftStep(),
                draft.getDpstDraftCurrency(),
                draft.getDpstDraftLinkedAcctNo(),
                draft.getDpstDraftAutoRenewYn(),
                draft.getDpstDraftAutoRenewTerm(),
                draft.getDpstDraftAutoTermiYn(),
                draft.getDpstDraftAmount()
        );
    }

    private Map<String, Object> sanitizeDraftRequest(Map<String, Object> request) {
        Map<String, Object> sanitized = new HashMap<>();
        sanitized.put("currency", request.get("currency"));
        sanitized.put("month", request.get("month"));
        sanitized.put("step", request.get("step"));
        sanitized.put("linkedAccountNo", request.get("linkedAccountNo"));
        sanitized.put("autoRenewYn", request.get("autoRenewYn"));
        sanitized.put("autoRenewTerm", request.get("autoRenewTerm"));
        sanitized.put("autoTerminationYn", request.get("autoTerminationYn"));
        sanitized.put("amount", request.get("amount"));
        sanitized.put("withdrawPassword", maskSensitive(asString(request.get("withdrawPassword"))));
        sanitized.put("depositPassword", maskSensitive(asString(request.get("depositPassword"))));
        return sanitized;
    }

    private Map<String, Object> sanitizeApplyRequest(Map<String, Object> request) {
        Map<String, Object> sanitized = new HashMap<>(request);
        sanitized.put("withdrawPassword", maskSensitive(asString(request.get("withdrawPassword"))));
        sanitized.put("depositPassword", maskSensitive(asString(request.get("depositPassword"))));
        return sanitized;
    }

    private String maskSensitive(String value) {
        if (value == null || value.isBlank()) {
            return value;
        }
        int visible = Math.min(1, value.length());
        String maskedSection = "*".repeat(Math.max(4, value.length() - visible));
        return maskedSection + value.substring(value.length() - visible);
    }

}
