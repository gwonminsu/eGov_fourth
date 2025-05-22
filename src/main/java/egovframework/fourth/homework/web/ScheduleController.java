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
public class ScheduleController {
	private static final Logger log = LoggerFactory.getLogger(ScheduleController.class);
	
	@Resource
	private ObjectMapper objectMapper;

	@Resource(name="programScheduleService")
	private ProgramScheduleService programScheduleService;
	
    // 프로그램 일정 등록
    @PostMapping(value="/createSchedule.do", consumes="application/json", produces="application/json")
    public Map<String, String> writeSchedule(@RequestBody ProgramScheduleVO vo) throws Exception {
    	programScheduleService.createProgramSchedule(vo);
        return Collections.singletonMap("status","OK");
    }
    
    // 특정 날짜의 프로그램 일정 조회
    @PostMapping(value="/getDateSchedule.do", consumes="application/json", produces="application/json")
    public List<ProgramScheduleVO> getDateSchedule(@RequestBody Map<String,String> req) throws Exception {
        String programIdx = req.get("programIdx");
        String dateStr = req.get("date");
        Date date = Date.valueOf(dateStr);
        List<ProgramScheduleVO> list = programScheduleService.getProgramDateScheduleList(programIdx, date);
        return list;
    }
}
