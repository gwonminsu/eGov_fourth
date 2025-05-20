package egovframework.fourth.homework.service;

//Service 인터페이스
public interface AttachService {

	// 첨부 파일 등록
	void createAttach(AttachVO vo) throws Exception;
	  
	// 프로그램 idx로 첨부 이미지 파일 조회
	AttachVO getAttachByProgramIdx(String programIdx) throws Exception;
	  
	// 첨부 파일 단일 조회
	AttachVO getAttach(String idx) throws Exception;
	  
	// 첨부 파일 삭제
	void removeAttach(String idx) throws Exception;
	  
	// 프로그램에 있는 이미지 첨부파일 삭제
	void removeAttachByProgramIdx(String programIdx) throws Exception;
  
}
