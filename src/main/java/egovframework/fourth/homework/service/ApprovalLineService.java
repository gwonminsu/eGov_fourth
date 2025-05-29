package egovframework.fourth.homework.service;

import java.util.List;

//Service 인터페이스
public interface ApprovalLineService {

	// 결재 라인 생성
	void createApprovalLine(ApprovalLineVO vo) throws Exception;
	  
	// 관리자의 결재 라인 목록 조회
	List<ApprovalLineVO> getUserApprovalLineList(String createUserIdx) throws Exception;
	  
	// 결재 라인 하나 조회
	ApprovalLineVO getApprovalLine(String idx) throws Exception;
	
	// 결재 라인 수정(라인 이름)
	void editApprovalLine(String idx) throws Exception;
	  
	// 결재 라인 삭제
	void removeApprovalLine(String idx) throws Exception;
  
}
