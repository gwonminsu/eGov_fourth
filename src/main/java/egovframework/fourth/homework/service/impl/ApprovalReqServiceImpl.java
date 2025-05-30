package egovframework.fourth.homework.service.impl;

import java.util.List;

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
		for (LineUserVO lineUser : lineUserList) {
			ApprovalLineSnapshotVO snapUser = new ApprovalLineSnapshotVO();
			// 데이터 세팅 후
			snapUser.setApprovalReqIdx(vo.getIdx());
			snapUser.setUserIdx(lineUser.getApprovalUserIdx());
			snapUser.setSeq(lineUser.getSeq());
			snapUser.setType(lineUser.getType());
			approvalLineSnapshotService.createApprovalLineSnapshot(snapUser); // 기안문을 결재할 사용자 생성
		}
		log.info("INSERT 에약 일정({})에 예약 마감 기안문({}) 등록 성공", vo.getProgramScheduleIdx(), vo.getIdx());
	}
	
	// 관리자의 예약 마감 기안문 목록 조회
	@Override
	public List<ApprovalReqVO> getUserApprovalReqList(String reqUserIdx) throws Exception {
		List<ApprovalReqVO> list = approvalReqDAO.selectApprovalReqListByReqUserIdx(reqUserIdx);
		log.info("SELECT 사용자({})의 예약 마감 기안문 목록 조회 완료", reqUserIdx);
		return list;
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
	public void editApprovalReq(String idx) throws Exception {
		approvalReqDAO.updateApprovalReq(idx);
		log.info("UPDATE 예약 마감 기안문({}) 상태 수정 완료", idx);
	}
	
	// 예약 마감 기안문 삭제
	@Override
	public void removeApprovalReq(String idx) throws Exception {
		approvalReqDAO.deleteApprovalReq(idx);
		log.info("DELETE 예약 마감 기안문({}) 삭제 완료", idx);
	}

}
