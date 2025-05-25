package egovframework.fourth.homework.web;

import java.sql.Date;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.fourth.homework.service.ProgramScheduleService;
import egovframework.fourth.homework.service.ProgramScheduleVO;

@RestController
@RequestMapping("/api/schedule")
public class BookingController {
	private static final Logger log = LoggerFactory.getLogger(BookingController.class);
	
	@Resource
	private ObjectMapper objectMapper;

	@Resource(name="programScheduleService")
	private ProgramScheduleService programScheduleService;
	
    // 프로그램 일정 등록
    @PostMapping(value="/createSchedule.do", consumes="application/json", produces="application/json")
    public Map<String, String> writeSchedule(@RequestBody ProgramScheduleVO vo) throws Exception {
    	// 먼저 겹치는 일정 있는지 검증
    	int conflict = programScheduleService.countOverlap(vo.getProgramIdx(), vo.getStartDatetime(), vo.getEndDatetime());
        if (conflict > 0) {
        	log.info("충돌되는 일정 존재: 일정 등록 거부");
        	return Collections.singletonMap("error","REJECTED");
        } else {
        	log.info("충돌되는 일정 없음: 일정 등록 승인");
        	programScheduleService.createProgramSchedule(vo);
        	return Collections.singletonMap("status","OK");
        }
    }
    
    // 프로그램 일정 수정
    @PostMapping(value="/updateSchedule.do", consumes="application/json", produces="application/json")
    public Map<String, String> modifySchedule(@RequestBody ProgramScheduleVO vo) throws Exception {
    	programScheduleService.modifyProgramSchedule(vo);
    	return Collections.singletonMap("status","OK");
    }
    
    // 특정 날짜의 프로그램 일정 조회
    @PostMapping(value="/getDateScheduleList.do", consumes="application/json", produces="application/json")
    public List<ProgramScheduleVO> getDateScheduleList(@RequestBody Map<String,String> req) throws Exception {
        String programIdx = req.get("programIdx");
        String dateStr = req.get("date");
        Date date = Date.valueOf(dateStr);
        List<ProgramScheduleVO> list = programScheduleService.getProgramDateScheduleList(programIdx, date);
        return list;
    }
    
    // 프로그램 전체 일정 조회
    @PostMapping(value="/getProgramScheduleList.do", consumes="application/json", produces="application/json")
    public List<ProgramScheduleVO> getProgramScheduleList(@RequestBody Map<String,String> req) throws Exception {
        String programIdx = req.get("programIdx");
        List<ProgramScheduleVO> list = programScheduleService.getProgramScheduleList(programIdx);
        return list;
    }
    
    // 프로그램 일정 상세 조회
    @PostMapping(value="/getProgramSchedule.do", consumes="application/json", produces="application/json")
    public ProgramScheduleVO getProgramSchedule(@RequestBody Map<String,String> req) throws Exception {
        String idx = req.get("idx");
        ProgramScheduleVO vo = programScheduleService.getProgramSchedule(idx);
        return vo;
    }
}
