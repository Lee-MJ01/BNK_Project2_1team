package kr.co.api.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import kr.co.api.backend.dto.CustInfoDTO;
import kr.co.api.backend.dto.DpstAcctDraftDTO;
import kr.co.api.backend.dto.DpstAcctDraftRequestDTO;
import kr.co.api.backend.dto.DpstAcctDraftResponseDTO;
import kr.co.api.backend.jwt.JwtTokenProvider;
import kr.co.api.backend.mapper.DpstAcctDraftMapper;
import kr.co.api.backend.mapper.MemberMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping("/api/mobile/deposit/drafts")
@RequiredArgsConstructor
public class DepositDraftController {

    private final DpstAcctDraftMapper draftMapper;
    private final MemberMapper memberMapper;
    private final JwtTokenProvider jwtTokenProvider;

    @GetMapping("/{dpstId}")
    public ResponseEntity<DpstAcctDraftResponseDTO> getDepositDraft(
            @PathVariable String dpstId,
            HttpServletRequest request
    ) {
        CustInfoDTO user = resolveUser(request);
        log.info("[DepositDraft] Fetching draft | dpstId={}, custCode={}", dpstId, user.getCustCode());

        DpstAcctDraftDTO draft = draftMapper.findLatestDraft(dpstId, user.getCustCode());
        if (draft == null) {
            log.warn("[DepositDraft] Draft not found | dpstId={}, custCode={}", dpstId, user.getCustCode());
            return ResponseEntity.notFound().build();
        }

        logDraftState("[DepositDraft] Loaded draft", draft);
        return ResponseEntity.ok(toResponse(draft));
    }

    @PutMapping("/{dpstId}")
    @Transactional
    public ResponseEntity<DpstAcctDraftResponseDTO> saveDepositDraft(
            @PathVariable String dpstId,
            @RequestBody DpstAcctDraftRequestDTO request,
            HttpServletRequest servletRequest
    ) {
        CustInfoDTO user = resolveUser(servletRequest);

        log.info(
                "[DepositDraft] Received save request | dpstId={}, custCode={}, payload={}",
                dpstId,
                user.getCustCode(),
                sanitizeDraftRequest(request)
        );

        DpstAcctDraftDTO existing = Optional.ofNullable(
                draftMapper.findLatestDraft(dpstId, user.getCustCode())
        ).orElse(null);

        DpstAcctDraftDTO draft = mergeDraft(existing, request, dpstId, user.getCustCode());
        logDraftState("[DepositDraft] Prepared draft for persistence", draft);

        if (draft.getDpstDraftNo() == null) {
            int inserted = draftMapper.insertDraft(draft);
            log.info("[DepositDraft] Insert attempt | insertedRows={}", inserted);
        } else {
            int updated = draftMapper.updateDraft(draft);
            log.info("[DepositDraft] Update attempt | updatedRows={}", updated);
        }

        DpstAcctDraftDTO saved = draftMapper.findLatestDraft(dpstId, user.getCustCode());
        logDraftState("[DepositDraft] Persisted draft", saved);

        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(saved));
    }

    @DeleteMapping("/{dpstId}")
    @Transactional
    public ResponseEntity<Void> deleteDepositDraft(
            @PathVariable String dpstId,
            HttpServletRequest servletRequest
    ) {
        CustInfoDTO user = resolveUser(servletRequest);
        log.info("[DepositDraft] Deleting draft | dpstId={}, custCode={}", dpstId, user.getCustCode());
        int deleted = draftMapper.deleteDraft(dpstId, user.getCustCode());
        log.info(
                "[DepositDraft] Delete result | dpstId={}, custCode={}, deletedRows={}",
                dpstId,
                user.getCustCode(),
                deleted
        );
        return ResponseEntity.noContent().build();
    }

    private DpstAcctDraftDTO mergeDraft(
            DpstAcctDraftDTO current,
            DpstAcctDraftRequestDTO request,
            String dpstId,
            String custCode
    ) {
        DpstAcctDraftDTO draft = Optional.ofNullable(current).orElseGet(DpstAcctDraftDTO::new);

        draft.setDpstDraftDpstId(dpstId);
        draft.setDpstDraftCustCode(custCode);
        draft.setDpstDraftMonth(coalesceInt(request.getMonth(), draft.getDpstDraftMonth(), 0));
        draft.setDpstDraftStep(coalesceInt(request.getStep(), draft.getDpstDraftStep(), 0));
        draft.setDpstDraftCurrency(coalesceCurrency(request.getCurrency(), draft.getDpstDraftCurrency()));
        draft.setDpstDraftFxWithdrawCcy(coalesceCurrency(request.getFxWithdrawCurrency(), draft.getDpstDraftFxWithdrawCcy()));
        draft.setDpstDraftLinkedAcctNo(coalesceString(request.getLinkedAccountNo(), draft.getDpstDraftLinkedAcctNo()));
        draft.setDpstDraftAutoRenewYn(coalesceFlag(request.getAutoRenewYn(), draft.getDpstDraftAutoRenewYn()));
        draft.setDpstDraftAutoRenewTerm(coalesceInt(request.getAutoRenewTerm(), draft.getDpstDraftAutoRenewTerm(), 0));
        draft.setDpstDraftAutoTermiYn(coalesceFlag(request.getAutoTerminationYn(), draft.getDpstDraftAutoTermiYn()));
        draft.setDpstDraftAmount(coalesceAmount(request.getAmount(), draft.getDpstDraftAmount()));
        draft.setDpstDraftAppliedRate(coalesceAmount(request.getAppliedRate(), draft.getDpstDraftAppliedRate()));
        draft.setDpstDraftAppliedFxRate(coalesceAmount(request.getAppliedFxRate(), draft.getDpstDraftAppliedFxRate()));
        return draft;
    }

    private DpstAcctDraftResponseDTO toResponse(DpstAcctDraftDTO draft) {
        DpstAcctDraftResponseDTO response = new DpstAcctDraftResponseDTO();
        if (draft == null) {
            return response;
        }
        response.setDraftNo(draft.getDpstDraftNo());
        response.setDpstId(draft.getDpstDraftDpstId());
        response.setCustomerCode(draft.getDpstDraftCustCode());
        response.setCurrency(nullIfBlank(draft.getDpstDraftCurrency()));
        response.setFxWithdrawCurrency(nullIfBlank(draft.getDpstDraftFxWithdrawCcy()));
        response.setMonth(nullIfZero(draft.getDpstDraftMonth()));
        response.setStep(nullIfZero(draft.getDpstDraftStep()));
        response.setLinkedAccountNo(nullIfBlank(draft.getDpstDraftLinkedAcctNo()));
        response.setAutoRenewYn(defaultFlag(draft.getDpstDraftAutoRenewYn()));
        response.setAutoRenewTerm(nullIfZero(draft.getDpstDraftAutoRenewTerm()));
        response.setAutoTerminationYn(defaultFlag(draft.getDpstDraftAutoTermiYn()));
        response.setAmount(nullIfZero(draft.getDpstDraftAmount()));
        response.setAppliedRate(nullIfZero(draft.getDpstDraftAppliedRate()));
        response.setAppliedFxRate(nullIfZero(draft.getDpstDraftAppliedFxRate()));
        response.setUpdatedAt(draft.getDpstDraftUpdatedDt());
        return response;
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

    private Map<String, Object> sanitizeDraftRequest(DpstAcctDraftRequestDTO request) {
        Map<String, Object> sanitized = new HashMap<>();
        sanitized.put("currency", request.getCurrency());
        sanitized.put("fxWithdrawCurrency", request.getFxWithdrawCurrency());
        sanitized.put("month", request.getMonth());
        sanitized.put("step", request.getStep());
        sanitized.put("linkedAccountNo", request.getLinkedAccountNo());
        sanitized.put("autoRenewYn", request.getAutoRenewYn());
        sanitized.put("autoRenewTerm", request.getAutoRenewTerm());
        sanitized.put("autoTerminationYn", request.getAutoTerminationYn());
        sanitized.put("amount", request.getAmount());
        sanitized.put("appliedRate", request.getAppliedRate());
        sanitized.put("appliedFxRate", request.getAppliedFxRate());
        return sanitized;
    }

    private void logDraftState(String label, DpstAcctDraftDTO draft) {
        if (draft == null) {
            log.warn("{} | draft is null", label);
            return;
        }

        log.info(
                "{} | draftNo={}, dpstId={}, custCode={}, month={}, step={}, currency={}, fxWithdrawCcy={}, linkedAcct={}, autoRenewYn={}, autoRenewTerm={}, autoTermiYn={}, amount={}, appliedRate={}, appliedFxRate={}",
                label,
                draft.getDpstDraftNo(),
                draft.getDpstDraftDpstId(),
                draft.getDpstDraftCustCode(),
                draft.getDpstDraftMonth(),
                draft.getDpstDraftStep(),
                draft.getDpstDraftCurrency(),
                draft.getDpstDraftFxWithdrawCcy(),
                draft.getDpstDraftLinkedAcctNo(),
                draft.getDpstDraftAutoRenewYn(),
                draft.getDpstDraftAutoRenewTerm(),
                draft.getDpstDraftAutoTermiYn(),
                draft.getDpstDraftAmount(),
                draft.getDpstDraftAppliedRate(),
                draft.getDpstDraftAppliedFxRate()
        );
    }

    private String coalesceString(String incoming, String existing) {
        if (incoming != null && !incoming.isBlank()) {
            return incoming;
        }
        return existing != null ? existing : "";
    }

    private String coalesceCurrency(String incoming, String existing) {
        if (incoming != null && !incoming.isBlank()) {
            return incoming.trim().toUpperCase();
        }
        if (existing != null && !existing.isBlank()) {
            return existing;
        }
        return "";
    }

    private String coalesceFlag(Boolean incoming, String existing) {
        if (incoming != null) {
            return incoming ? "Y" : "N";
        }
        if (existing != null && !existing.isBlank()) {
            return existing;
        }
        return "N";
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

    private String defaultFlag(String value) {
        return (value == null || value.isBlank()) ? "N" : value;
    }
}
