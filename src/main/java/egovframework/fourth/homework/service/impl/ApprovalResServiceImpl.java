package egovframework.fourth.homework.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.ApprovalResService;
import egovframework.fourth.homework.service.ApprovalResVO;

@Service("approvalResService")
public class ApprovalResServiceImpl extends EgovAbstractServiceImpl implements ApprovalResService {
	
	private static final Logger log = LoggerFactory.getLogger(ApprovalResServiceImpl.class);
	
	@Resource(name = "approvalResDAO")
	private ApprovalResDAO approvalResDAO;
	

	// 기안문 응답 생성
	@Override
	public void createApprovalRes(ApprovalResVO vo) throws Exception {
		approvalResDAO.insertApprovalRes(vo);
		log.info("INSERT 기안문({})에 대한 기안문 응답({}) 등록 성공", vo.getApprovalReqIdx(), vo.getIdx());
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
