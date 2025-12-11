package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.PdfAiDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PdfAiMapper {

    void insertPdf(PdfAiDTO dto);

    Long findInsertedId(PdfAiDTO dto);

    List<PdfAiDTO> findByStatus(String status);

    List<PdfAiDTO> findAll();

    PdfAiDTO findById(Long pdfId);

    void updateStatus(@Param("pdfId") Long pdfId,
                      @Param("status") String status);

    void deleteById(Long pdfId);
}
