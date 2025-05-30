package egovframework.fourth.homework.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

//Service 인터페이스
public interface AttachService {

	// 첨부 파일 등록(프로그램)
	void createProgramAttach(String programIdx, MultipartFile file) throws Exception;
	
	// 첨부 파일 등록(기안문)
	void createApprovalReqAttach(String approvalReqIdx, List<MultipartFile> files) throws Exception;
	  
	// 프로그램 idx로 첨부 이미지 파일 조회
	AttachVO getAttachByProgramIdx(String programIdx) throws Exception;
	
	// 기안문 idx로 첨부 파일 목록 조회
	List<AttachVO> getAttachListByApprovalReqIdx(String approvalReqIdx) throws Exception;
	  
	// 첨부 파일 단일 조회
	AttachVO getAttach(String idx) throws Exception;
	  
	// 첨부 파일 삭제
	void removeAttach(String idx) throws Exception;
	  
	// 프로그램에 있는 이미지 첨부파일 삭제
	void removeAttachByProgramIdx(String programIdx) throws Exception;
	
	// 기안문에 있는 모등 첨부파일 삭제
	void removeAttachByApprovalReqIdx(String approvalReqIdx) throws Exception;
  
}
