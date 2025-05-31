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
import egovframework.fourth.homework.service.ApprovalLineSnapshotService;
import egovframework.fourth.homework.service.ApprovalLineSnapshotVO;
import egovframework.fourth.homework.service.ApprovalLineVO;
import egovframework.fourth.homework.service.ApprovalReqService;
import egovframework.fourth.homework.service.ApprovalReqVO;
import egovframework.fourth.homework.service.ApprovalResService;
import egovframework.fourth.homework.service.ApprovalResVO;
import egovframework.fourth.homework.service.AttachService;
import egovframework.fourth.homework.service.AttachVO;
import egovframework.fourth.homework.service.LineUserService;
import egovframework.fourth.homework.service.LineUserVO;
import egovframework.fourth.homework.service.ProgramVO;

@RestController
@RequestMapping("/api/approval")
public class ApprovalController {
	private static final Logger log = LoggerFactory.getLogger(ApprovalController.class);

	@Resource
	private ObjectMapper objectMapper;
	
	@Resource(name = "approvalReqService")
	private ApprovalReqService approvalReqService;
	
	@Resource(name = "approvalResService")
	private ApprovalResService approvalResService;

	@Resource(name = "approvalLineService")
	private ApprovalLineService approvalLineService;
	
	@Resource(name = "approvalLineSnapshotService")
	private ApprovalLineSnapshotService approvalLineSnapshotService;
	
	@Resource(name = "lineUserService")
	private LineUserService lineUserService;
	
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
    
    // 기안문 삭제
    @PostMapping(value="/deleteReq.do", consumes="application/json", produces="application/json")
    public Map<String,String> reqDelete(@RequestBody Map<String,String> req) throws Exception {
    	String idx = req.get("idx");
    	// 먼저 기안문에 결재 응답 목록 조회해서 검사
        List<ApprovalResVO> list = approvalResService.getApprovalReqApprovalResList(idx);
        if (!list.isEmpty()) {
        	// 결재 응답이 있으면 튕굼
        	return Collections.singletonMap("error","한명 이상의 결재자가 결재하여 삭제할 수 없습니다");
        }
    	approvalReqService.removeApprovalReq(idx); // 기안문과 소속된 첨부파일들 + 결재자 유저들 삭제
        return Collections.singletonMap("status","OK");
    }
    
    // 관리자에게 결재 요청받은 예약 마감 기안문 목록 조회
    @PostMapping(value="/getSnapUserReqList.do", consumes="application/json", produces="application/json")
    public Map<String, Object> getSnapUserReqList(@RequestBody Map<String,Object> req) throws Exception {
    	String userIdx = (String) req.get("userIdx");
        int pageIndex = (Integer) req.get("pageIndex") <= 0 ? 1 : (Integer) req.get("pageIndex");
        int recordCountPerPage = (Integer) req.get("recordCountPerPage");
        int firstIndex = (pageIndex - 1) * recordCountPerPage;

        int totalCount = approvalReqService.getSnapApprovalReqCount(userIdx);
    	List<ApprovalReqVO> reqList = approvalReqService.getSnapUserApprovalReqList(userIdx, recordCountPerPage, firstIndex);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", reqList);
        result.put("totalCount", totalCount);

        return result;
    }
    
    // 특정 기안문 상세 정보 조회
    @PostMapping(value="/getApprovalReq.do", consumes="application/json", produces="application/json")
    public ApprovalReqVO getApprovalReq(@RequestBody Map<String,String> req) throws Exception {
        String idx = req.get("idx");
        ApprovalReqVO vo = approvalReqService.getApprovalReq(idx);
        return vo;
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
    
    // 결재 기안문의 라인 유저 목록 조회
    @PostMapping(value="/getSnapUserList.do", consumes="application/json", produces="application/json")
    public List<ApprovalLineSnapshotVO> getSnapUserList(@RequestBody Map<String,String> req) throws Exception {
        String approvalReqIdx = req.get("approvalReqIdx");
        List<ApprovalLineSnapshotVO> list = approvalLineSnapshotService.getApprovalReqApprovalLineSnapshotList(approvalReqIdx);
        return list;
    }
    
    // 기안문에 있는 모든 결재 응답 데이터 조회
    @PostMapping(value="/getReqRes.do", consumes="application/json", produces="application/json")
    public List<ApprovalResVO> getReqRes(@RequestBody Map<String,String> req) throws Exception {
        String approvalReqIdx = req.get("approvalReqIdx");
        List<ApprovalResVO> list = approvalResService.getApprovalReqApprovalResList(approvalReqIdx);
        return list;
    }
    
    // 사용자가 특정 기안문에 응답한 데이터 조회
    @PostMapping(value="/getUserAndReqRes.do", consumes="application/json", produces="application/json")
    public List<ApprovalResVO> getUserAndReqRes(@RequestBody Map<String,String> req) throws Exception {
        String approvalReqIdx = req.get("approvalReqIdx");
        String userIdx = req.get("userIdx");
        List<ApprovalResVO> list = approvalResService.getUserAndApprovalReqApprovalRes(userIdx, approvalReqIdx);
        return list;
    }
    
    // 결재 라인의 라인 유저 목록 조회
	/*
	 * @PostMapping(value="/getLineUserList.do", consumes="application/json",
	 * produces="application/json") public List<LineUserVO>
	 * getLineUserList(@RequestBody Map<String,String> req) throws Exception {
	 * String lineIdx = req.get("lineIdx"); List<LineUserVO> list =
	 * lineUserService.getLineLineUserList(lineIdx); return list; }
	 */
    
    // 결재 라인 삭제
    @PostMapping(value="/deleteLine.do", consumes="application/json", produces="application/json")
    public Map<String,String> lineDelete(@RequestBody Map<String,String> req) throws Exception {
    	approvalLineService.removeApprovalLine(req.get("idx")); // 라인과 소속된 라인 유저들 삭제
        return Collections.singletonMap("status","OK");
    }
    
	// 기안문에 응답 등록
	@PostMapping(value = "/createApprovalRes.do", consumes = "application/json", produces = "application/json")
	public Map<String, String> createApprovalRes(@RequestBody Map<String,String> req) throws Exception {
		String approvalReqIdx = req.get("approvalReqIdx");
		String userIdx = req.get("userIdx");
		log.info("approvalReqIdx: {}, userIdx: {}", approvalReqIdx, userIdx);
		String lineSnapshotIdx = approvalLineSnapshotService.getReqAndUserApprovalLineSnapshotIdx(approvalReqIdx, userIdx);
		
	    // 본인 차례 아니면 등록 못함
	    if (!approvalLineSnapshotService.isCurrentTurn(approvalReqIdx, userIdx)) {
	        return Collections.singletonMap("error", "더 이상 결재할 수 없습니다");
	    }
		
	    req.put("lineSnapshotIdx", lineSnapshotIdx);
		approvalResService.createApprovalRes(req); // 결재 응답 등록
		return Collections.singletonMap("status", "OK");
	}

}
