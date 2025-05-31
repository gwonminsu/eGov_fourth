package egovframework.fourth.homework.service;

import java.util.List;
import java.util.Map;

//Service 인터페이스
public interface ApprovalResService {

	// 기안문 응답 생성
	void createApprovalRes(Map<String,String> req) throws Exception;
	
	// 기안문 응답 하나 조회
	ApprovalResVO getApprovalRes(String idx) throws Exception;
	  
	// 기안문에 대한 기안문 응답 목록 조회
	List<ApprovalResVO> getApprovalReqApprovalResList(String approvalReqIdx) throws Exception;
	  
	// 사용자의 기안문 응답 목록 조회
	List<ApprovalResVO> getUserApprovalResList(String userIdx) throws Exception;
	
	// 사용자가 특정 기안문에 응답한 데이터 조회
	List<ApprovalResVO> getUserAndApprovalReqApprovalRes(String userIdx, String approvalReqIdx) throws Exception;
	  
	// 기안문 응답 삭제
	void removeApprovalRes(String idx) throws Exception;
	
	// 기안문에 있는 모든 기안문 응답 삭제
	void removeApprovalReqApprovalRes(String approvalReqIdx) throws Exception;
  
}
