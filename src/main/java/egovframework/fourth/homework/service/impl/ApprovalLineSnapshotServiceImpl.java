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

@Service("approvalLineSnapshotService")
public class ApprovalLineSnapshotServiceImpl extends EgovAbstractServiceImpl implements ApprovalLineSnapshotService {
	
	private static final Logger log = LoggerFactory.getLogger(ApprovalLineSnapshotServiceImpl.class);
	
	@Resource(name = "approvalLineSnapshotDAO")
	private ApprovalLineSnapshotDAO approvalLineSnapshotDAO;
	
	@Resource(name = "approvalResService")
	private ApprovalResService approvalResService;

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
	
	// 기안문idx와 사용자idx로 결재할 사용자 idx 조회
	@Override
	public String getReqAndUserApprovalLineSnapshotIdx(String approvalReqIdx, String userIdx) throws Exception {
		Map<String,Object> param = new HashMap<>();
		param.put("approvalReqIdx", approvalReqIdx);
		param.put("userIdx", userIdx);
		String lineSnapshotIdx = approvalLineSnapshotDAO.selectLineSnapshotIdxByReqAndUser(param);
		System.out.println("lineSnapshotIdx = " + lineSnapshotIdx);
		return lineSnapshotIdx;
	}
	
	// 결재자 잠금 해제
	@Override
	public void unlockSnapUser(String idx) throws Exception {
		approvalLineSnapshotDAO.updateIsLocked(idx);
		log.info("UPDATE 결재할 관리자({}) 잠금 해제 완료", idx);
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
	
	// 기안문 등록할 차례인지 확인
	@Override
	public boolean isCurrentTurn(String approvalReqIdx, String userIdx) throws Exception {
		// 기안문의 모든 결재자 조회
	    List<ApprovalLineSnapshotVO> all = approvalLineSnapshotDAO.selectApprovalLineSnapshotListByApprovalReqIdx(approvalReqIdx);
	    
	    List<ApprovalLineSnapshotVO> approvList = new ArrayList<>();
	    List<ApprovalLineSnapshotVO> coopList = new ArrayList<>();
	    List<ApprovalLineSnapshotVO> refList = new ArrayList<>();
	    
	    // 타입에 따라 분류
	    for (ApprovalLineSnapshotVO vo : all) {
	        switch (vo.getType()) {
	            case "coop": coopList.add(vo); break;
	            case "approv": approvList.add(vo); break;
	            case "ref": refList.add(vo); break;
	        }
	    }

	    // 각 리스트 seq 오름차순 정렬
	    Comparator<ApprovalLineSnapshotVO> seqComparator = Comparator.comparingInt(ApprovalLineSnapshotVO::getSeq);
	    coopList.sort(seqComparator);
	    approvList.sort(seqComparator);
	    refList.sort(seqComparator);

	    // 전체 결재 순서대로 합치기
	    List<ApprovalLineSnapshotVO> ordered = new ArrayList<>();
	    ordered.addAll(coopList);
	    ordered.addAll(approvList);
	    ordered.addAll(refList);

	    // 내 차례인지 확인
	    for (int i = 0; i < ordered.size(); i++) {
	        ApprovalLineSnapshotVO vo = ordered.get(i);

	        if (!vo.getIsLocked() && vo.getUserIdx().equals(userIdx)) {

	            // ✅ 이미 응답한 적 있는지 체크
	            List<ApprovalResVO> myResList = approvalResService.getUserAndApprovalReqApprovalRes(userIdx, approvalReqIdx);
	            if (!myResList.isEmpty()) {
	                return false; // 이미 응답했으면 차례가 아님
	            }

	            if (i == 0) return true;

	            ApprovalLineSnapshotVO prev = ordered.get(i - 1);
	            List<ApprovalResVO> resList = approvalResService.getUserAndApprovalReqApprovalRes(prev.getUserIdx(), approvalReqIdx);
	            if (!resList.isEmpty()) {
	                String status = resList.get(0).getApprovalStatus();
	                if (status.equals("APPROVED")) {
	                    return true;
	                } else if (status.equals("REJECTED")) {
	                    return false;
	                }
	            }

	            return false;
	        }
	    }

	    // 아무도 내 차례가 아니면 false
	    return false;
	}

}
