package egovframework.fourth.homework.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.fourth.homework.service.ApprovalLineSnapshotService;
import egovframework.fourth.homework.service.ApprovalLineSnapshotVO;
import egovframework.fourth.homework.service.ApprovalReqService;
import egovframework.fourth.homework.service.ApprovalReqVO;
import egovframework.fourth.homework.service.AttachService;
import egovframework.fourth.homework.service.LineUserService;
import egovframework.fourth.homework.service.LineUserVO;

@Service("approvalReqService")
public class ApprovalReqServiceImpl extends EgovAbstractServiceImpl implements ApprovalReqService {
	
	private static final Logger log = LoggerFactory.getLogger(ApprovalReqServiceImpl.class);
	
	@Resource(name = "approvalReqDAO")
	private ApprovalReqDAO approvalReqDAO;
	
    @Resource(name="lineUserService")
    private LineUserService lineUserService;
    
    @Resource(name="approvalLineSnapshotService")
    private ApprovalLineSnapshotService approvalLineSnapshotService;
	
    @Resource(name="attachService")
    private AttachService attachService;

	// 예약 마감 기안문 생성 + 기안문을 결재할 사용자들 생성
	@Override
	public void createApprovalReq(ApprovalReqVO vo, List<MultipartFile> files) throws Exception {
		approvalReqDAO.insertApprovalReq(vo); // 기안문 생성하고
		attachService.createApprovalReqAttach(vo.getIdx(), files); // 기안문에 대한 파일들 생성하고
		
		// 기안문이 사용한 라인의 라인 유저 목록 조회하여
		List<LineUserVO> lineUserList = lineUserService.getLineLineUserList(vo.getApprovalLineIdx());
		
		// 리스트에 협조자 있는지 검사
		boolean hasCoop = false;
		for (LineUserVO lineUser : lineUserList) {
			if (lineUser.getType().equals("coop")) {
				hasCoop = true;
				break;
			}
		}
		
		for (LineUserVO lineUser : lineUserList) {
			ApprovalLineSnapshotVO snapUser = new ApprovalLineSnapshotVO();
			// 데이터 세팅 후
			snapUser.setApprovalReqIdx(vo.getIdx());
			snapUser.setUserIdx(lineUser.getApprovalUserIdx());
			snapUser.setSeq(lineUser.getSeq());
			snapUser.setType(lineUser.getType());
			if ("coop".equals(lineUser.getType()) && lineUser.getSeq() == 0) {
				snapUser.setIsLocked(false); // coop + seq 0 -> 잠금 해제
			} else if (!hasCoop && "approv".equals(lineUser.getType()) && lineUser.getSeq() == 0) {
				snapUser.setIsLocked(false); // coop 없고 approv + seq 0 -> 잠금 해제
			} else {
				snapUser.setIsLocked(true); // 그 외는 잠금
			}
			approvalLineSnapshotService.createApprovalLineSnapshot(snapUser); // 기안문을 결재할 사용자 생성
		}
		log.info("INSERT 에약 일정({})에 예약 마감 기안문({}) 등록 성공", vo.getProgramScheduleIdx(), vo.getIdx());
	}
	
	// 관리자에게 결재 요청받은 예약 마감 기안문 목록 조회
	@Override
	public List<ApprovalReqVO> getSnapUserApprovalReqList(String userIdx, int recordCountPerPage, int firstIndex) throws Exception {
		Map<String,Object> param = new HashMap<>();
		param.put("userIdx", userIdx);
		param.put("recordCountPerPage", recordCountPerPage);
		param.put("firstIndex", firstIndex);
		List<ApprovalReqVO> list = approvalReqDAO.selectApprovalReqListBySnapUserIdx(param);
		log.info("SELECT 사용자({})에게 요청받은 예약 마감 기안문 목록 조회 완료", userIdx);
		return list;
	}
	
	// 관리자에게 결재 요청받은 예약 마감 기안문 목록 조회
	@Override
	public int getSnapApprovalReqCount(String userIdx) throws Exception {
		return approvalReqDAO.selectSnapApprovalReqCount(userIdx);
	}
	
	// 관리자의 예약 마감 기안문 목록 조회
	@Override
	public List<ApprovalReqVO> getUserApprovalReqList(String reqUserIdx) throws Exception {
		List<ApprovalReqVO> list = approvalReqDAO.selectApprovalReqListByReqUserIdx(reqUserIdx);
		log.info("SELECT 사용자({})의 예약 마감 기안문 목록 조회 완료", reqUserIdx);
		return list;
	}
	
	// 특정 예약 마감 기안문 상세 조회
	@Override
	public ApprovalReqVO getApprovalReq(String idx) throws Exception {
		ApprovalReqVO vo = approvalReqDAO.selectApprovalReq(idx);
		log.info("SELECT 예약 마감 기안문({}) 조회 완료", vo.getIdx());
		return vo;
	}

	// 프로그램 일정의 예약 마감 기안문 상세 조회
	@Override
	public ApprovalReqVO getProgramScheduleApprovalReq(String programScheduleIdx) throws Exception {
		ApprovalReqVO vo = approvalReqDAO.selectApprovalReqByProgramScheduleIdx(programScheduleIdx);
	    if (vo == null) {
	        log.info("SELECT 프로그램 일정({})의 예약 마감 기안문 없음", programScheduleIdx);
	        return null;
	    }
		log.info("SELECT 프로그램 일정({})의 예약 마감 기안문({}) 조회 완료", programScheduleIdx, vo.getIdx());
		return vo;
	}

	// 예약 마감 기안문 수정(상태)
	@Override
	public void editApprovalReq(String idx, String status) throws Exception {
		ApprovalReqVO vo = new ApprovalReqVO();
		vo.setIdx(idx);
		vo.setStatus(status);
		approvalReqDAO.updateApprovalReq(vo);
		log.info("UPDATE 예약 마감 기안문({}) 상태 수정 완료", idx);
	}
	
	// 예약 마감 기안문 + 소속된 첨부파일들 + 결재자 유저들 삭제
	@Override
	public void removeApprovalReq(String idx) throws Exception {
		attachService.removeAttachByApprovalReqIdx(idx); // 첨부 파일들 삭제하고
		approvalLineSnapshotService.removeApprovalReqApprovalLineSnapshot(idx); // 결재자 유저들 삭제하고
		approvalReqDAO.deleteApprovalReq(idx); // 기안문 삭제
		log.info("DELETE 예약 마감 기안문({}) 삭제 완료", idx);
	}

}
