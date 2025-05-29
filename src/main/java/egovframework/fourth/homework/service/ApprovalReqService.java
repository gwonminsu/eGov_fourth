package egovframework.fourth.homework.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

//Service 인터페이스
public interface ApprovalReqService {

	// 예약 마감 기안문 생성
	void createApprovalReq(ApprovalReqVO vo, List<MultipartFile> files) throws Exception;
	  
	// 관리자의 예약 마감 기안문 목록 조회
	List<ApprovalReqVO> getUserApprovalReqList(String reqUserIdx) throws Exception;
	  
	// 프로그램 일정의 예약 마감 기안문 상세 조회
	ApprovalReqVO getProgramScheduleApprovalReq(String programScheduleIdx) throws Exception;
	
	// 예약 마감 기안문 수정(상태)
	void editApprovalReq(String idx) throws Exception;
	  
	// 예약 마감 기안문 삭제
	void removeApprovalReq(String idx) throws Exception;
  
}
