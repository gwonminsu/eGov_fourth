package egovframework.fourth.homework.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

//Service 인터페이스
public interface ProgramService {

	// 프로그램 등록
	void createProgram(ProgramVO vo, MultipartFile file) throws Exception;
	  
	// 프로그램 목록 조회
	List<ProgramVO> getProgramList() throws Exception;
	  
	// 프로그램 단일 조회
	ProgramVO getProgram(String idx) throws Exception;
	  
	// 프로그램 수정
	void modifyProgram(ProgramVO vo, MultipartFile file) throws Exception;
	  
	// 프로그램 삭제
	void removeProgram(String idx) throws Exception;
  
}
