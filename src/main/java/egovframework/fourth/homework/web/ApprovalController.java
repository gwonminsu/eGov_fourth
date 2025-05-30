package egovframework.fourth.homework.web;

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
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.fourth.homework.service.ApprovalLineService;
import egovframework.fourth.homework.service.ApprovalLineVO;
import egovframework.fourth.homework.service.ApprovalReqService;
import egovframework.fourth.homework.service.ApprovalReqVO;
import egovframework.fourth.homework.service.AttachService;
import egovframework.fourth.homework.service.AttachVO;
import egovframework.fourth.homework.service.ProgramVO;

@RestController
@RequestMapping("/api/approval")
public class ApprovalController {
	private static final Logger log = LoggerFactory.getLogger(ApprovalController.class);

	@Resource
	private ObjectMapper objectMapper;
	
	@Resource(name = "approvalReqService")
	private ApprovalReqService approvalReqService;

	@Resource(name = "approvalLineService")
	private ApprovalLineService approvalLineService;
	
	@Resource(name="attachService")
	private AttachService attachService;
	
    // 기안문 등록
    @PostMapping(value="/createReq.do", consumes = "multipart/form-data", produces="application/json")
    public Map<String, String> write(
    		@RequestPart("approvalReq") ApprovalReqVO vo,
			@RequestPart(value = "files", required = false) List<MultipartFile> files) throws Exception {
    	approvalReqService.createApprovalReq(vo, files);
        return Collections.singletonMap("status","OK");
    }
    
    // 프로그램 일정의 기안문 정보 조회
    @PostMapping(value="/getScheduleReq.do", consumes="application/json", produces="application/json")
    public Map<String, Object> getScheduleApprovalReq(@RequestBody Map<String,String> req) throws Exception {
        String programScheduleIdx = req.get("programScheduleIdx");
        ApprovalReqVO vo = approvalReqService.getProgramScheduleApprovalReq(programScheduleIdx);
        Map<String, Object> result = new HashMap<>();
        if (vo != null) {
        	result.put("approvalReq", vo); // 빈 객체로 리턴
        }
        return result;
    }
    
    // 기안문의 모든 첨부파일 목록 조회
    @PostMapping(value="/getReqAttachList.do", consumes="application/json", produces="application/json")
    public List<AttachVO> getReqAttachList(@RequestBody Map<String,String> req) throws Exception {
        String approvalReqIdx = req.get("approvalReqIdx");
        List<AttachVO> list = attachService.getAttachListByApprovalReqIdx(approvalReqIdx);
        return list;
    }

	// 관리자 결재 라인 등록
	@PostMapping(value = "/createLine.do", consumes = "application/json", produces = "application/json")
	public Map<String, String> writeApprovalLine(@RequestBody ApprovalLineVO vo) throws Exception {
		log.info("결재 라인 등록 승인");
		approvalLineService.createApprovalLine(vo); // 결재 라인과 결재할 사용자 목록 생성
		return Collections.singletonMap("status", "OK");
	}
	
	// 관리자 결재 라인 수정
	@PostMapping(value = "/editLine.do", consumes = "application/json", produces = "application/json")
	public Map<String, String> editApprovalLine(@RequestBody ApprovalLineVO vo) throws Exception {
		log.info("결재 라인 수정 승인");
		approvalLineService.editApprovalLine(vo); // 결재 라인과 결재할 사용자 목록 수정
		return Collections.singletonMap("status", "OK");
	}
	
    // 관리자의 결재 라인 목록 정보 조회
    @PostMapping(value="/getLineList.do", consumes="application/json", produces="application/json")
    public List<ApprovalLineVO> getUserLineList(@RequestBody Map<String,String> req) throws Exception {
        String createUserIdx = req.get("createUserIdx");
        List<ApprovalLineVO> list = approvalLineService.getUserApprovalLineList(createUserIdx);
        return list;
    }
    
    // 결재 라인 삭제
    @PostMapping(value="/deleteLine.do", consumes="application/json", produces="application/json")
    public Map<String,String> lineDelete(@RequestBody Map<String,String> param) throws Exception {
    	approvalLineService.removeApprovalLine(param.get("idx")); // 라인과 소속된 라인 유저들 삭제
        return Collections.singletonMap("status","OK");
    }

}
