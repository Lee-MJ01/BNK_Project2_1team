package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.*;
import org.apache.ibatis.annotations.Mapper;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Mapper
public interface MypageMapper {
    // 원화 입출금 개설
    void insertAcct(CustAcctDTO custAcctDTO);

    // 외화 입출금 개설
    void insertFrgnAcct(CustFrgnAcctDTO custFrgnAcctDTO);

    // 외화 계좌 있는지 확인
    int selectCheckCntEnAcct(String custCode);

    // 고객 보유 전체 원화 계좌 확인
    List<CustAcctDTO> selectAllKoAcct(String custCode);

    // 고객 외환 계좌 확인
    CustFrgnAcctDTO selectFrgnAcct(String custCode);

    // 원화 계좌명 수정
    void updateAcctName(String acctName, String acctNo);

    // 외화 계좌명 수정
    void updateFrgnAcctName(String acctName, String acctNo);

    // 원화 계좌 조회
    CustAcctDTO selectCustAcct(String acctNo);

    // 계좌 이체 성공시 삽입
    void insertTranHist(CustTranHistDTO custTranHistDTO);

    // 입금
    void updatePlusAcct(BigDecimal amount, String acctNo);

    // 출금
    void updateMinusAcct(BigDecimal amount, String acctNo);

    // 원화 입출금 계좌 개수 확인
    Integer selectCntAcct(String custCode);

    // 외화 자식 계좌 생성
    void insertAllFrgnAcctBal(List<FrgnAcctBalanceDTO> item);

    // 외화 자식 계좌 조회
    List<FrgnAcctBalanceDTO> selectAllFrgnAcctBal(String frgnAcctNo);

    CustInfoDTO selectCustInfo(String custId);
    LocalDate selectCheckKoAcct(String custCode);
    int selectCheckCntKoAcct(String custCode);


    // 회원정보 수정 비밀번호 확인
    CustInfoDTO selectCustInfoByCode(String custCode);

    // 회원 정보 수정
    void updateCustInfo(CustInfoDTO custInfoDTO);

    // 거래내역 조회 메서드
    List<CustTranHistDTO> selectTranHist(String acctNo);

    // 쿠폰 목록 조회
    List<CouponDTO> selectCouponList(String custCode);

    public List<MypageDpstDTO> selectDpstAccts(String dpstHdrCustCode);
    public List<DpstAcctDtlDTO> selectDpstAcctDtls(String dpstHdrCustCode);

    public DpstAcctHdrDTO selectDpstAcctHdr(String dpstHdrAcctNo);
    public Double selectAcctBal(String dpstHdrLinkedAcctNo);
    public FrgnAcctBalanceDTO selectFrgnAcctBal(String dpstHdrAcctNo);

    public DpstAcctHdrDTO selectDpstKrwAcctHdr(String dpstHdrAcctNo);
    public DpstAcctHdrDTO selectDpstFrgnAcctHdr(String dpstHdrAcctNo, String dpstHdrCurrency);

    public void insertDpstCustTranHist(CustTranHistDTO custTranHistDTO);
    public void insertDpstAcctDtl(DpstAcctDtlDTO dpstDtlDTO);
    public void updateDpstAcctHdr(DpstAcctHdrDTO dpstAcctHdrDTO);
    public void updateKrwAcctBal(CustAcctDTO custAcct);
    public void updateFrgnAcctBal(FrgnAcctBalanceDTO balAcct);

    public List<DpstAcctDtlDTO> selectDpstAcctDtlHist(String dpstDtlHdrNo);
    public CustInfoDTO getRawCustInfo(String custCode);
    public FrgnAcctBalanceDTO getBalBalanceByAcctHdrNo(String dpstHdrAcctNo);
    public void updateBalBalance(FrgnAcctBalanceDTO balDTO);
    public void updateHdrStatus(DpstAcctHdrDTO dpstAcct);
}
