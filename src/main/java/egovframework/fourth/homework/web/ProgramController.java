package egovframework.fourth.homework.web;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.fourth.homework.service.ProgramService;
import egovframework.fourth.homework.service.ProgramVO;

@RestController
@RequestMapping("/api/program")
public class ProgramController {
	private static final Logger log = LoggerFactory.getLogger(ProgramController.class);
	
	@Resource
	private ObjectMapper objectMapper;
	
	@Resource(name="programService")
	private ProgramService programService;
	
    // 프로그램 등록
    @PostMapping(value="/create.do", consumes = "multipart/form-data", produces="application/json")
    public Map<String, String> write(
    		@RequestPart("program") ProgramVO vo,
			@RequestPart(value = "file", required = false) MultipartFile file) throws Exception {
    	programService.createprogram(vo);
        return Collections.singletonMap("status","OK");
    }
    
    // 프로그램 수정
    @PostMapping(value="/edit.do", consumes = "multipart/form-data", produces="application/json")
    public Map<String,String> edit(
    		@RequestPart("program") ProgramVO vo,
			@RequestPart(value = "file", required = false) MultipartFile file) throws Exception {
        programService.modifyProgram(vo);
        return Collections.singletonMap("status","OK");
    }
	
    // 프로그램 상세 조회(설문 기본 정보)
    @PostMapping(value="/detail.do", consumes="application/json", produces="application/json")
    public ProgramVO detail(@RequestBody Map<String,String> param) throws Exception {
        return programService.getProgram(param.get("idx"));
    }
    
	// 프로그램 목록 조회
    @PostMapping(value="/list.do", consumes="application/json", produces="application/json")
	public List<ProgramVO> programs(@RequestBody Map<String, String> param) throws Exception {
		return programService.getProgramList();
	}


    // 설문 삭제
    @PostMapping(value="/delete.do", consumes="application/json", produces="application/json")
    public Map<String,String> delete(@RequestBody Map<String,String> param) throws Exception {
    	programService.removeProgram(param.get("idx"));
        return Collections.singletonMap("status","OK");
    }
}
