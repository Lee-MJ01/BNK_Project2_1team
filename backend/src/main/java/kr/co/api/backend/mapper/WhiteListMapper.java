package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.DepositRateDTO;
import kr.co.api.flobankapi.dto.InterestInfoDTO;
import kr.co.api.flobankapi.dto.ProductDTO;
import kr.co.api.flobankapi.dto.TermsHistDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface WhiteListMapper {
    public List<ProductDTO> dpstAllInfo(String dpstId);
    public List<String> dpstIdList();
    public List<InterestInfoDTO> interestInfo();
    public List<DepositRateDTO> interestsInfo();
    public List<TermsHistDTO> selectLatestTermsByCate(int termCate);
}
