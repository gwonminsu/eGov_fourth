package egovframework.fourth.homework.service;

import java.util.List;

//Service 인터페이스
public interface ApprovalLineSnapshotService {

	// 결재 기안문의 결재 라인에 등록된 결재할 사용자 생성
	void createApprovalLineSnapshot(ApprovalLineSnapshotVO vo) throws Exception;
	  
	// 결재 기안문의 결재할 사용자 목록 조회
	List<ApprovalLineSnapshotVO> getApprovalReqApprovalLineSnapshotList(String approvalReqIdx) throws Exception;
	  
	// 결재 기안문에 등록된 결재할 특정 사용자 조회
	ApprovalLineSnapshotVO getApprovalLineSnapshot(String idx) throws Exception;
	
	// 결재 기안문에 등록된 결재할 특정 사용자 하나 삭제
	void removeApprovalLineSnapshot(String idx) throws Exception;
	  
	// 결재 기안문에 등록된 결재할 사용자들 삭제
	void removeApprovalReqApprovalLineSnapshot(String approvalReqIdx) throws Exception;
  
}
