package egovframework.fourth.homework.service;

import java.util.List;

//Service 인터페이스
public interface LineUserService {

	// 결재 라인의 결재할 사용자 생성
	void createLineUser(LineUserVO vo) throws Exception;
	  
	// 결재 라인의 결재할 사용자 목록 조회
	List<LineUserVO> getLineLineUserList(String lineIdx) throws Exception;
	  
	// 결재 라인의 결재할 사용자 조회
	LineUserVO getLineUser(String idx) throws Exception;
	
	// 결재 라인의 결재할 사용자 삭제
	void removeLineUser(String idx) throws Exception;
	  
	// 결재 라인에 소속된 결재할 사용자들 삭제
	void removeLineLineUser(String lineIdx) throws Exception;
  
}
