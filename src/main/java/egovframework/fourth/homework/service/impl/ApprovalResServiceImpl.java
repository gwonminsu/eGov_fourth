package egovframework.fourth.homework.service.impl;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.ApprovalLineSnapshotService;
import egovframework.fourth.homework.service.ApprovalLineSnapshotVO;
import egovframework.fourth.homework.service.ApprovalResService;
import egovframework.fourth.homework.service.ApprovalResVO;

@Service("approvalResService")
public class ApprovalResServiceImpl extends EgovAbstractServiceImpl implements ApprovalResService {
	
	private static final Logger log = LoggerFactory.getLogger(ApprovalResServiceImpl.class);
	
	@Resource(name = "approvalResDAO")
	private ApprovalResDAO approvalResDAO;
	
	@Resource(name = "approvalLineSnapshotService")
	private ApprovalLineSnapshotService approvalLineSnapshotService;
	

	// 기안문 응답 생성 + 다음 차례의 결재자 잠금 풀기
	@Override
	public void createApprovalRes(Map<String,String> req) throws Exception {
		String approvalReqIdx = req.get("approvalReqIdx");
		String userIdx = req.get("userIdx");
		String approvalStatus = req.get("approvalStatus");
		String comment = req.get("comment");
		String lineSnapshotIdx = req.get("lineSnapshotIdx");
		
		ApprovalResVO vo = new ApprovalResVO();
		vo.setApprovalReqIdx(approvalReqIdx);
		vo.setLineSnapshotIdx(lineSnapshotIdx);
		vo.setComment(comment);
		vo.setApprovalStatus(approvalStatus);
		
		approvalResDAO.insertApprovalRes(vo);
		
		// 다음 차례 결재자 잠금 풀기
		List<ApprovalLineSnapshotVO> all = approvalLineSnapshotService.getApprovalReqApprovalLineSnapshotList(approvalReqIdx);

		// coop -> approv -> ref 정렬
		List<ApprovalLineSnapshotVO> coopList = new ArrayList<>();
		List<ApprovalLineSnapshotVO> approvList = new ArrayList<>();
		List<ApprovalLineSnapshotVO> refList = new ArrayList<>();

		for (ApprovalLineSnapshotVO snap : all) {
		    switch (snap.getType()) {
		        case "coop": coopList.add(snap); break;
		        case "approv": approvList.add(snap); break;
		        case "ref": refList.add(snap); break;
		    }
		}

		Comparator<ApprovalLineSnapshotVO> seqComp = Comparator.comparingInt(ApprovalLineSnapshotVO::getSeq);
		coopList.sort(seqComp);
		approvList.sort(seqComp);
		refList.sort(seqComp);

		// 순서대로 병합
		List<ApprovalLineSnapshotVO> ordered = new ArrayList<>();
		ordered.addAll(coopList);
		ordered.addAll(approvList);
		ordered.addAll(refList);

		// 현재 위치 찾아서 다음 차례 unlock
		for (int i = 0; i < ordered.size(); i++) {
		    if (ordered.get(i).getIdx().equals(lineSnapshotIdx)) {
		        if (i + 1 < ordered.size()) {
		            ApprovalLineSnapshotVO nextSnapUser = ordered.get(i + 1);
		            approvalLineSnapshotService.unlockSnapUser(nextSnapUser.getIdx()); // 다음 차례 결재자 unlock
		            log.info("UPDATE 기안문({})의 다음 차례 결재자({}) is_locked = false", approvalReqIdx, nextSnapUser.getUserIdx());
		        }
		        break;
		    }
		}
		
		log.info("INSERT 기안문({})에 대한 기안문 응답({}) 등록 성공", approvalReqIdx, vo.getIdx());
	}
	
	// 기안문 응답 하나 조회
	@Override
	public ApprovalResVO getApprovalRes(String idx) throws Exception {
		ApprovalResVO vo = approvalResDAO.selectApprovalRes(idx);
		log.info("SELECT 기안문 응답({}) 조회 완료", vo.getIdx());
		return vo;
	}
	
	// 기안문에 대한 기안문 응답 목록 조회
	@Override
	public List<ApprovalResVO> getApprovalReqApprovalResList(String approvalReqIdx) throws Exception {
		List<ApprovalResVO> list = approvalResDAO.selectApprovalResListByApprovalReqIdx(approvalReqIdx);
		log.info("SELECT 기안문({})의 모든 기안문 응답 목록 조회 완료", approvalReqIdx);
		return list;
	}
	
	// 사용자의 기안문 응답 목록 조회
	@Override
	public List<ApprovalResVO> getUserApprovalResList(String userIdx) throws Exception {
		List<ApprovalResVO> list = approvalResDAO.selectApprovalResListByUserIdx(userIdx);
		log.info("SELECT 사용자({})가 생성한 모든 기안문 응답 목록 조회 완료", userIdx);
		return list;
	}
	
	// 사용자가 특정 기안문에 응답한 데이터 조회
	@Override
	public List<ApprovalResVO> getUserAndApprovalReqApprovalRes(String userIdx, String approvalReqIdx) throws Exception {
		Map<String,Object> param = new HashMap<>();
		param.put("userIdx", userIdx);
		param.put("approvalReqIdx", approvalReqIdx);
		List<ApprovalResVO> list = approvalResDAO.selectApprovalResListByUserIdxAndApprovalReqIdx(param);
		log.info("SELECT 사용자({})가 생성한 모든 기안문 응답 목록 조회 완료", userIdx);
		return list;
	}
	
	// 기안문 응답 삭제
	@Override
	public void removeApprovalRes(String idx) throws Exception {
		approvalResDAO.deleteApprovalRes(idx);
		log.info("DELETE 기안문 응답({}) 삭제 완료", idx);
	}
	
	// 기안문에 있는 모든 기안문 응답 삭제
	@Override
	public void removeApprovalReqApprovalRes(String approvalReqIdx) throws Exception {
		approvalResDAO.deleteApprovalResByApprovalReqIdx(approvalReqIdx);
		log.info("DELETE 기안문({})에 대한 모든 기안문 응답 목록 삭제 완료", approvalReqIdx);
	}

}
