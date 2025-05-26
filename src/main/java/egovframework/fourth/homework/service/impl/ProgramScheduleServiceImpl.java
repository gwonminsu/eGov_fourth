package egovframework.fourth.homework.service.impl;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.ProgramScheduleService;
import egovframework.fourth.homework.service.ProgramScheduleVO;

@Service("programScheduleService")
public class ProgramScheduleServiceImpl extends EgovAbstractServiceImpl implements ProgramScheduleService {
	
	private static final Logger log = LoggerFactory.getLogger(ProgramScheduleServiceImpl.class);
	
	@Resource(name = "programScheduleDAO")
	private ProgramScheduleDAO programScheduleDAO;

	// 프로그램 일정 등록
	@Override
	public void createProgramSchedule(ProgramScheduleVO vo) throws Exception {
		programScheduleDAO.insertProgramSchedule(vo);
		String date = vo.getStartDatetime().toLocalDateTime().toLocalDate().toString();
		String startTime = vo.getStartDatetime().toLocalDateTime().toLocalTime().toString();
		String endTime = vo.getEndDatetime().toLocalDateTime().toLocalTime().toString();
		log.info("INSERT {}에 프로그램 일정({}) 등록 성공[{} - {}]", date, vo.getIdx(), startTime, endTime);
	}
	
	// 겹치는 프로그램 일정 개수 조회(검증용)
	@Override
	public int countOverlap(String programIdx, Timestamp startDatetime, Timestamp endDatetime) throws Exception {
        Map<String,Object> param = new HashMap<>();
        param.put("programIdx", programIdx);
        param.put("startDatetime", startDatetime);
        param.put("endDatetime", endDatetime);
        int conflict = programScheduleDAO.countOverlap(param);
		return conflict;
	}
	
	// 프로그램의 일정 목록 조회
	@Override
	public List<ProgramScheduleVO> getProgramScheduleList(String programIdx) throws Exception {
		List<ProgramScheduleVO> list = programScheduleDAO.selectProgramScheduleListByProgramIdx(programIdx);
		log.info("SELECT 프로그램의 일정 목록 조회 완료");
		return list;
	}
	
	// 특정 날짜의 프로그램 일정 목록 조회
	@Override
	public List<ProgramScheduleVO> getProgramDateScheduleList(String programIdx, Date date) throws Exception {
		Map<String,Object> param = new HashMap<>();
		param.put("programIdx", programIdx);
		param.put("date", date);
		List<ProgramScheduleVO> list = programScheduleDAO.selectProgramScheduleListByProgramIdxAndDate(param);
		log.info("SELECT {}에 있는 프로그램의 일정 목록 조회 완료", date.toString());
		return list;
	}
	
	// 특정 날짜의 프로그램 일정 목록 조회
	@Override
	public List<ProgramScheduleVO> getProgramMonthScheduleList(String programIdx, String month) throws Exception {
		Map<String,Object> param = new HashMap<>();
		param.put("programIdx", programIdx);
		param.put("month", month); // YYYY-MM 형식
		List<ProgramScheduleVO> list = programScheduleDAO.selectProgramScheduleListByProgramIdxAndMonth(param);
		log.info("SELECT {}에 있는 프로그램의 일정 목록 조회 완료", month);
		return list;
	}

	// 프로그램 일정 상세 조회
	@Override
	public ProgramScheduleVO getProgramSchedule(String idx) throws Exception {
		ProgramScheduleVO vo = programScheduleDAO.selectProgramSchedule(idx);
		log.info("SELECT 프로그램 일정({}) 조회 완료", idx);
		return vo;
	}

	// 프로그램 일정 수정
	@Override
	public void modifyProgramSchedule(ProgramScheduleVO vo) throws Exception {
		programScheduleDAO.updateProgramSchedule(vo);
		log.info("UPDATE 프로그램 일정({}) 수정 완료", vo.getIdx());
	}

	// 프로그램 일정 삭제
	@Override
	public void removeProgramSchedule(String idx) throws Exception {
		programScheduleDAO.deleteProgramSchedule(idx);
		log.info("DELETE 프로그램 일정({}) 삭제 완료", idx);
	}

}
