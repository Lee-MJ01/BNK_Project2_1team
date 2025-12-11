package kr.co.api.backend.mapper.admin;


import kr.co.api.backend.dto.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ProductMapper {

    // 상품 정보 INSERT (RETURNING으로 상품코드 OUT 받을 예정)
    int insertProduct(ProductDTO dto);

    // ★ 통화별 최소/최대 INSERT — Map으로 받아야 함
    int insertProductLimits(Map<String, Object> param);

    // ★ 가입 기간 INSERT — Map으로 받아야 함
    int insertProductPeriods(Map<String, Object> param);

    // ★ 통화별 최소 출금금액 — Map으로 받아야 함
    int insertWithdrawalAmounts(Map<String, Object> param);

    // 분할 인출 규정 (단건이라 Map 필요 없음)
    void insertWithdrawalRule(ProductWithdrawRuleDTO rule);

    // 상태 업데이트
    void updateStatus(@Param("dpstId") String dpstId, @Param("status") int status);

    // 상태별 상품 리스트
    List<ProductDTO> getProductsByStatus(@Param("status") int status);

    // 상품 조회
    ProductDTO getProductById(@Param("dpstId") String dpstId);

    // 기간 리스트 조회
    List<ProductPeriodDTO> getPeriods(@Param("dpstId") String dpstId);

    // 분할 인출 규정 조회
    ProductWithdrawRuleDTO getWithdrawRule(@Param("dpstId") String dpstId);

    // 분할 인출 금액 조회
    List<ProductWithdrawAmtDTO> getWithdrawAmts(@Param("dpstId") String dpstId);

    // 최소/최대 금액 조회
    List<ProductLimitDTO> getLimits(@Param("dpstId") String dpstId);


    // 매일 밤 12시 상품 업데이트
    void updateStatusToOpened();

    // 상품명으로 최신 약관 파일 경로 가져오기
    String findTermsFileByTitle(@Param("productName") String productName);



}
