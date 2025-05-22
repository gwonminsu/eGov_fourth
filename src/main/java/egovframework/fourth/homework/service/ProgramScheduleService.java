package egovframework.fourth.homework.service;

import java.util.List;

//Service 인터페이스
public interface ProgramScheduleService {

	// 프로그램 일정 등록
	void createProgramSchedule(ProgramScheduleVO vo) throws Exception;
	  
	// 프로그램의 일정 목록 조회
	List<ProgramScheduleVO> getProgramScheduleList(String programIdx) throws Exception;
	  
	// 프로그램 일정 상세 조회
	ProgramScheduleVO getProgramSchedule(String idx) throws Exception;
	  
	// 프로그램 일정 수정
	void modifyProgramSchedule(ProgramScheduleVO vo) throws Exception;
	  
	// 프로그램 일정 삭제
	void removeProgramSchedule(String idx) throws Exception;
  
}
