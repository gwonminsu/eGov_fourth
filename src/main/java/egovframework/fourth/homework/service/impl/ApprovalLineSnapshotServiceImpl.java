package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.ApprovalLineSnapshotService;
import egovframework.fourth.homework.service.ApprovalLineSnapshotVO;

@Service("approvalLineSnapshotService")
public class ApprovalLineSnapshotServiceImpl extends EgovAbstractServiceImpl implements ApprovalLineSnapshotService {
	
	private static final Logger log = LoggerFactory.getLogger(ApprovalLineSnapshotServiceImpl.class);
	
	@Resource(name = "approvalLineSnapshotDAO")
	private ApprovalLineSnapshotDAO approvalLineSnapshotDAO;

	// 결재 기안문의 결재 라인에 등록된 결재할 사용자 생성
	@Override
	public void createApprovalLineSnapshot(ApprovalLineSnapshotVO vo) throws Exception {
		approvalLineSnapshotDAO.insertApprovalLineSnapshot(vo);
		log.info("INSERT 결재 기안문({})에 결재할 관리자({}) 등록 성공", vo.getApprovalReqIdx(), vo.getIdx());
	}

	// 결재 기안문의 결재할 사용자 목록 조회
	@Override
	public List<ApprovalLineSnapshotVO> getApprovalReqApprovalLineSnapshotList(String approvalReqIdx) throws Exception {
		List<ApprovalLineSnapshotVO> list = approvalLineSnapshotDAO.selectApprovalLineSnapshotListByApprovalReqIdx(approvalReqIdx);
		log.info("SELECT 결재 기안문({})의 결재할 관리자 목록 조회 완료", approvalReqIdx);
		return list;
	}

	// 결재 기안문에 등록된 결재할 특정 사용자 조회
	@Override
	public ApprovalLineSnapshotVO getApprovalLineSnapshot(String idx) throws Exception {
		ApprovalLineSnapshotVO vo = approvalLineSnapshotDAO.selectApprovalLineSnapshot(idx);
		log.info("SELECT 결재할 관리자({}) 조회 완료", vo.getIdx());
		return vo;
	}

	// 결재 기안문에 등록된 결재할 특정 사용자 하나 삭제
	@Override
	public void removeApprovalLineSnapshot(String idx) throws Exception {
		approvalLineSnapshotDAO.deleteApprovalLineSnapshot(idx);
		log.info("DELETE 결재할 관리자({}) 삭제 완료", idx);
	}

	// 결재 기안문에 등록된 결재할 사용자들 삭제
	@Override
	public void removeApprovalReqApprovalLineSnapshot(String approvalReqIdx) throws Exception {
		approvalLineSnapshotDAO.deleteApprovalLineSnapshotByApprovalReqIdx(approvalReqIdx);
		List<ApprovalLineSnapshotVO> list = approvalLineSnapshotDAO.selectApprovalLineSnapshotListByApprovalReqIdx(approvalReqIdx);
		log.info("DELETE 결재 기안문({})에 소속된 결재할 관리자들 삭제 완료(총 {}건)", approvalReqIdx, list.size());
	}


}
