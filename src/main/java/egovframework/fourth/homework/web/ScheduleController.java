package egovframework.fourth.homework.web;

import java.sql.Date;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
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
public class ScheduleController {
	private static final Logger log = LoggerFactory.getLogger(ScheduleController.class);
	
	@Resource
	private ObjectMapper objectMapper;

	@Resource(name="programScheduleService")
	private ProgramScheduleService programScheduleService;
	
    // 프로그램 일정 등록(일괄 등록)
    @PostMapping(value="/createSchedule.do", consumes="application/json", produces="application/json")
    public Map<String, Object> writeSchedule(@RequestBody List<ProgramScheduleVO> scheduleList) throws Exception {
    	List<String> skipped = new ArrayList<>(); // 스킵된 일정 알림용
    	for (ProgramScheduleVO vo : scheduleList) {
        	// 먼저 겹치는 일정 있는지 검증
        	int conflict = programScheduleService.countOverlap(vo.getProgramIdx(), vo.getStartDatetime(), vo.getEndDatetime());
            if (conflict > 0) {
            	log.info("일정 등록 거부: 충돌되는 일정({}) 존재", vo.getIdx());
            	skipped.add(vo.getStartDatetime().toString() + " ~ " + vo.getEndDatetime().toString());
            	continue;
            }
            programScheduleService.createProgramSchedule(vo); // 일정 등록
    	}
    	
        Map<String, Object> result = new HashMap<>();
        result.put("status", "OK");
        result.put("skipped", skipped); // 프론트에 충돌 건 알려주기
        	
    	return result;
    }
    
    // 프로그램 일정 수정
    @PostMapping(value="/updateSchedule.do", consumes="application/json", produces="application/json")
    public Map<String, String> modifySchedule(@RequestBody ProgramScheduleVO vo) throws Exception {
		ProgramScheduleVO schedule = programScheduleService.getProgramSchedule(vo.getIdx());
		// 일정의 새로운 capacity가 기존 예약인 수보다 적으면 튕굼
		if (vo.getCapacity() < schedule.getBookerCount()) {
			log.info("예약 수정 거부: 제한 인원 수 초과");
			return Collections.singletonMap("error","수정하려는 제한 인원 수가 현재 예약된 인원 수보다 적습니다.");
		}
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
    
    // 특정 달의 프로그램 일정 조회
    @PostMapping(value="/getMonthScheduleList.do", consumes="application/json", produces="application/json")
    public List<ProgramScheduleVO> getMonthScheduleList(@RequestBody Map<String,String> req) throws Exception {
        String programIdx = req.get("programIdx");
        String month = req.get("month");
        List<ProgramScheduleVO> list = programScheduleService.getProgramMonthScheduleList(programIdx, month);
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
